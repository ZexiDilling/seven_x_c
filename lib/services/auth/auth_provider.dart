import 'package:seven_x_c/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  
  Future<void> logout();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset ({required String toEmail});
}
