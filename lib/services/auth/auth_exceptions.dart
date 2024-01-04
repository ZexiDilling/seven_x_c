
// login
class UserNotFoundAuthException implements Exception {}
class WrongPasswordAuthException implements Exception {}
class InvalidCredentialAuthException implements Exception {}

// register
class WeakPasswordAuthException implements Exception {}
class EmailAlreadyInUserAuthException implements Exception {}
class InvalidEmailAuthException implements Exception {}

// generic
class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}
