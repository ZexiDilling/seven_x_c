import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:seven_x_c/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText =
        "WE ARE WAITING!!! COME ON!!!... FFS!!! how can it take so long, to do suchs a simple task? it makes ZERO sense",
  });
}

class AuthStateUninitialzed extends AuthState {
  const AuthStateUninitialzed({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required super.isLoading});
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required super.isLoading});
}

class AuthStateNeedsVerifications extends AuthState {
  const AuthStateNeedsVerifications({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateUser extends AuthState {
  final bool setter;
  final bool setting;
  final bool competing;
  const AuthStateUser({required this.setter, required this.setting, required this.competing, required super.isLoading});
}