import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  FutureOr<User?> build() async {
    try {
      // 1. Try to get fresh profile from API
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

  // Use this after Login to update UI instantly
  void setUser(User? user) {
    state = AsyncValue.data(user);
  }

  // [THIS WAS MISSING] Use this on Logout to clear the state
  void clearUser() {
    state = const AsyncValue.data(null);
  }
}