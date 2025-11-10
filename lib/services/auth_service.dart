import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SignInResult { success, emailNotVerified, failed }

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();

  AuthService._();

  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  String? get email => currentUser?.email;
  String? get name => currentUser?.userMetadata?['name'] as String?;
  String? get userId => currentUser?.id;

  bool get isLoggedIn => currentUser != null;

  Future<SignInResult> signIn(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        notifyListeners();

        // Check if email is verified
        if (response.user!.emailConfirmedAt != null) {
          return SignInResult.success;
        } else {
          return SignInResult.emailNotVerified;
        }
      }
      return SignInResult.failed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign in error: $e');
      }
      return SignInResult.failed;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: null, // This ensures email verification is required
      );

      if (response.user != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign up error: $e');
      }
      return false;
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Resend verification error: $e');
      }
      return false;
    }
  }

  // Refresh user session to get latest data
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Refresh session error: $e');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign out error: $e');
      }
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? state,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (city != null) updates['city'] = city;
      if (state != null) updates['state'] = state;

      await _supabase.auth.updateUser(UserAttributes(data: updates));

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Update profile error: $e');
      }
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Change password error: $e');
      }
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Reset password error: $e');
      }
      return false;
    }
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfileData() async {
    if (currentUser == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Get user profile error: $e');
      }
      return null;
    }
  }

  // Update user profile in database
  Future<bool> updateUserProfileData(Map<String, dynamic> profileData) async {
    if (currentUser == null) return false;

    try {
      await _supabase.from('profiles').upsert({
        'id': currentUser!.id,
        'email': currentUser!.email,
        ...profileData,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Update user profile data error: $e');
      }
      return false;
    }
  }
}
