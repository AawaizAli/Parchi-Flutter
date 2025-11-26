import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

// This line allows the generator to create the file 'user_provider.g.dart'
part 'user_provider.g.dart';

// keepAlive: true ensures the data isn't deleted when you switch tabs
@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  FutureOr<User?> build() async {
    // 1. Attempt to fetch fresh data from API
    try {
      final profile = await authService.getProfile();
      return profile.user;
    } catch (e) {
      // 2. Fallback to local storage if offline/error
      return await authService.getUser();
    }
  }

  // Use this to manually refresh data (e.g. Pull-to-Refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await authService.getProfile();
      return profile.user;
    });
  }

  // Use this after Login/Logout to update UI instantly
  void setUser(User? user) {
    state = AsyncValue.data(user);
  }
}