import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(
    this.email,
    this.password,
  );
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventReister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventReister({
    required this.email,
    required this.password,
  });
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}
