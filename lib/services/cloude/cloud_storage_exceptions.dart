class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotDeleteBoulderException extends CloudStorageException {}

class CouldNotUpdateBoulderException extends CloudStorageException {}

class CouldNotDeleteUserException extends CloudStorageException {}

class CouldNotUpdateUserException extends CloudStorageException {}

class CouldNotCreateUserException extends CloudStorageException {}

class CouldNotCheckDisplayNameException extends CloudStorageException {}

class CouldNotGetSetterProfile extends CloudStorageException {}

class CouldNotUpdateComp extends CloudStorageException {}

class CouldNotUpdateChallenge extends CloudStorageException {}

class CouldNotUpdateSettings extends CloudStorageException {}

class NoChallenges extends CloudStorageException {}