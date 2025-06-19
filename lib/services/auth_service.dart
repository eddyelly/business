import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          data: data,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  static Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // Get user session
  static Session? get currentSession => _client.auth.currentSession;

  // Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response;
    } catch (e) {
      rethrow;
    }
  }
} 