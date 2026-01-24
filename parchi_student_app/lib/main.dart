import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [NEW] Import Riverpod
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/reset_password/reset_password_screen.dart';
import 'config/supabase_config.dart';
import 'utils/colours.dart';
import 'screens/home/home_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/redemption_history/redemption_history_screen.dart'; // [NEW] History Screen
import 'screens/auth/login_screens/login_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_handler_service.dart';
import 'firebase_options.dart'; // [NEW] Import generated options
import 'screens/auth/sign_up_screens/signup_verification_screen.dart'; // [NEW] Import Verification Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // [NEW] Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // [NEW] Initialize Notification Service (Subscribes to 'students_all')
  await NotificationHandlerService().initialize();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    // [NEW] Wrap entire app in ProviderScope
    const ProviderScope(
      child: ParchiApp(),
    ),
  );
}

class ParchiApp extends StatelessWidget {
  const ParchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parchi MVP',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        primaryColor: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        // [NEW] Global Cursor & Selection Color
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      home: const AuthWrapper(),
      // [NEW] robust route handler for deep links
      // [NEW] robust route handler for deep links
      onGenerateRoute: (settings) {
        // Check if the route is related to auth-callback OR contains an access token fragment
        final uri = Uri.tryParse(settings.name ?? '');
        final hasAccessToken = settings.name?.contains('access_token') ?? false;

        if (hasAccessToken ||
            (uri != null &&
                (uri.path.contains('auth-callback') ||
                    uri.host.contains('auth-callback') ||
                    uri.path.contains('reset-password') ||
                    uri.host.contains('reset-password')))) {
          String? accessToken;
          String? refreshToken;
          String? type; // [NEW] Track the type (signup vs recovery)

          // Try to parse tokens from fragment
          try {
            // If settings.name starts with /, prepending http://dummy.com makes it a valid URI to parse fragment
            // Example: /#access_token=...&type=recovery
            final parsingUri = Uri.parse("http://dummy.com${settings.name}");
            final fragment = parsingUri.fragment;
            if (fragment.isNotEmpty) {
              final queryParams = Uri.splitQueryString(fragment);
              accessToken = queryParams['access_token'];
              refreshToken = queryParams['refresh_token'];
              type = queryParams['type']; // 'recovery', 'signup', etc.
            }
          } catch (e) {
            debugPrint("Error parsing tokens: $e");
          }

          // Check path/host for explicit markers too
          if (uri != null) {
            if (uri.path.contains('reset-password') ||
                uri.host.contains('reset-password')) {
              type = 'recovery';
            }
          }

          // [NEW] Logic to differentiate Password Reset vs Signup Verification
          if (type == 'recovery') {
            return MaterialPageRoute(
              builder: (context) => const ResetPasswordScreen(),
            );
          }

          // Default: Signup Verification
          return MaterialPageRoute(
            builder: (context) => SignupVerificationScreen(
              accessToken: accessToken,
              refreshToken: refreshToken,
            ),
          );
        }

        // Default fallback
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        if (session.accessToken.isNotEmpty) {
          try {
            await authService.setToken(session.accessToken);
            if (session.refreshToken != null) {
              await authService.setRefreshToken(session.refreshToken!);
            }

            // Sync user profile from backend
            await authService.getProfile();

            if (mounted) {
              // Re-check auth state to update UI
              await _checkAuthState();
            }
          } catch (e) {
            debugPrint("Error syncing auth state: $e");
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          _checkAuthState();
        }
      } else if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const ResetPasswordScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    try {
      final isStudentAuth = await authService.isStudentAuthenticated();
      if (mounted) {
        setState(() {
          _isAuthenticated = isStudentAuth;
          _isLoading = false;
        });
      }

      if (!isStudentAuth) {
        final isAuth = await authService.isAuthenticated();
        if (isAuth) {
          await authService.logout();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LeaderboardScreen(),
    const RedemptionHistoryScreen(), // [NEW] History instead of Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        // [UPDATED] Wrapped in Theme to remove splash effects
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            enableFeedback: false, // Disables vibration/sound
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard), label: "Leaderboard"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "History"), // [NEW] History Icon
            ],
          ),
        ),
      ),
    );
  }
}
