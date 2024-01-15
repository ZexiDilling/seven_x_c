class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}

class CouldNotDeleteBoulderException extends CloudStorageException {}

class CouldNotUpdateBoulderException extends CloudStorageException {}

class CouldNotDeleteUserException extends CloudStorageException {}

class CouldNotUpdateUserException extends CloudStorageException {}

class CouldNotCreateUserException extends CloudStorageException {}

class CouldNotCheckDisplayNameException extends CloudStorageException {}

class CouldNotGetSetterProfile extends CloudStorageException {}

class CouldNotUpdateComp extends CloudStorageException {}

class CouldNotUpdateChallenge extends CloudStorageException {}
