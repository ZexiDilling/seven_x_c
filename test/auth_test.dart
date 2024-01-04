import 'package:seven_x_c/services/auth/auth_exceptions.dart';
import 'package:seven_x_c/services/auth/auth_provider.dart';
import 'package:seven_x_c/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("should not be init to begin with", () {
      expect(provider.isInitialized, false);
    });
    test("can't log out if not init", () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("should be able to be init", () async {
      await provider.initialize();
      expect(provider._isInitialized, true);
    });
    test("User should be null after init", () {
      expect(provider.currentUser, null);
    });
    test(
      "should be able to init within 2 sec",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test("Create user should delegte to logIn functions", () async {
      final badEmailUser = provider.createUser(
        email: "arg@google.com",
        password: "anypassword",
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
      final badPassordUser = provider.createUser(
        email: "someone@google.com",
        password: "arg",
      );
      expect(
        badPassordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );
      final user = await provider.createUser(
        email: "any",
        password: "any",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("login user should be able to get verified ", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("should be able to log out and log in again", () async {
      await provider.logout();
      await provider.logIn(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == "arg@google.com") throw UserNotFoundAuthException();
    if (password == "arg") throw WrongPasswordAuthException();
    await Future.delayed(const Duration(seconds: 1));
    const user = AuthUser(isEmailVerified: false, email: '', id: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: '', id: '');
    _user = newUser;
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }
}
