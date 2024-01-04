import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/notes/cloud_note.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_exceptions.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");
  final boulders = FirebaseFirestore.instance.collection("boulders");
  final profile = FirebaseFirestore.instance.collection("profile");

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
    final fetchNote = await document.get();
    return CloudNote(
      documentId: fetchNote.id,
      ownerUserId: ownerUserId,
      text: "",
    );
  }

  Future<void> deletBoulder({required String boulderID}) async {
    try {
      await boulders.doc(boulderID).delete();
    } catch (e) {
      throw CouldNotDeleteBoulderException();
    }
  }

  Future<void> updatBoulder({
    required String boulderID,
    String? setter,
    int? cordX,
    int? cordY,
    String? wall,
    String? holdColour,
    String? gradeColour,
    int? gradeNumberSetter,
    bool? topOut,
    bool? active,
    Map<String, dynamic>? challenge,
    Map<String, dynamic>? gradeNumberClimbers,
    Map<String, dynamic>? climberTopped,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      // Add non-null fields to the map
      if (setter != null) updatedData[setterFieldName] = setter;
      if (cordX != null) updatedData[coordinateXFieldName] = cordX;
      if (cordY != null) updatedData[coordinateYFieldName] = cordY;
      if (wall != null) updatedData[wallFieldName] = wall;
      if (holdColour != null) updatedData[holdColourFieledName] = holdColour;
      if (gradeColour != null) updatedData[gradeColourFieledName] = gradeColour;
      if (gradeNumberSetter != null) {
        updatedData[gradingSetterFieldName] = gradeNumberSetter;
      }
      if (topOut != null) updatedData[topOutFieldName] = topOut;
      if (active != null) updatedData[activefieldName] = active;
      if (challenge != null) updatedData[challengeFieldName] = challenge;
      if (gradeNumberClimbers != null) {
        updatedData[gradingClimbersFieldName] = gradeNumberClimbers;
      }
      if (climberTopped != null) {
        updatedData[climberToppedFieldName] = climberTopped;
      }

      // Update the document with the non-null fields
      await boulders.doc(boulderID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateBoulderException();
    }
  }

  Stream<Iterable<CloudBoulder>> getAllBoulders() {
    final allBoulders = boulders
        .where(activefieldName, isEqualTo: true)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudBoulder.fromSnapshot(doc)));
    return allBoulders;
  }

  Stream<Iterable<CloudBoulder>> getBoulder({required String boulderID}) {
    final allBoulders = boulders
        .where(boulderID, isEqualTo: boulderID)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudBoulder.fromSnapshot(doc)));
    return allBoulders;
  }

  Future<CloudBoulder> createNewBoulder({
    required String setter,
    required double cordX,
    required double cordY,
    required String wall,
    required String holdColour,
    required String gradeColour,
    required int gradeNumberSetter,
    required bool topOut,
    required bool active,
    Map<String, dynamic>? challenge,
    Map<String, dynamic>? gradeNumberClimber,
    Map<String, dynamic>? climberTopped,
  }) async {
    final document = await boulders.add({
      setterFieldName: setter,
      coordinateXFieldName: cordX,
      coordinateYFieldName: cordY,
      wallFieldName: wall,
      holdColourFieledName: holdColour,
      gradeColourFieledName: gradeColour,
      gradingSetterFieldName: gradeNumberSetter,
      topOutFieldName: topOut,
      activefieldName: active,
      if (challenge != null) challengeFieldName: challenge,
      if (gradeNumberClimber != null)
        gradingClimbersFieldName: gradeNumberClimber,
      if (climberTopped != null) climberToppedFieldName: climberTopped
    });
    final fetchBoulder = await document.get();
    return CloudBoulder(
      challenge,
      gradeNumberClimber,
      climberTopped,
      setter,
      cordX,
      cordY,
      wall,
      holdColour,
      gradeColour,
      gradeNumberSetter,
      topOut,
      active,
      boulderID: fetchBoulder.id,
    );
  }

  Future<void> deleteUser({required String ownerUserId}) async {
    try {
      await profile.doc(ownerUserId).delete();
    } catch (e) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<void> updateUser({
    required CloudProfile currentProfile,
    double? boulderPoints,
    double? setterPoints,
    bool? isSetter,
    bool? isAdmin,
    bool? isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? setBoulders,
    Map<String, dynamic>? comp,
    String? email,
    String? displayName,
    String? gradingSystem,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      // Add non-null fields to the map
      if (boulderPoints != null) {
        updatedData[boulderPointsFieldName] = boulderPoints;
      }
      if (setterPoints != null) {
        updatedData[setterPointsFieldName] = setterPoints;
      }
      if (isSetter != null) updatedData[isSetterFieldName] = isSetter;
      if (isAdmin != null) updatedData[isAdminFieldName] = isAdmin;
      if (isAnonymous != null) updatedData[isAnonymousFieldName] = isAnonymous;
      if (climbedBoulders != null) {
        updatedData[climbedBouldersFieldName] = climbedBoulders;
      }
      if (setBoulders != null) updatedData[setBouldersFieldName] = setBoulders;
      if (comp != null) updatedData[compFieldName] = comp;
      if (email != null) updatedData[emailFieldName] = email;
      if (displayName != null) updatedData[displayNameFieldName] = displayName;
      if (gradingSystem != null) {
        updatedData[gradingSystemFieldName] = gradingSystem;
      }
      // Update the document with the non-null fields
      await profile.doc(currentProfile.profileID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  Future<CloudProfile> createNewUser({
    required double boulderPoints,
    required double setterPoints,
    required bool isSetter,
    required bool isAdmin,
    required bool isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? setBoulders,
    Map<String, dynamic>? comp,
    required String email,
    required String displayName,
    required String gradingSystem,
    required String userID,
  }) async {
    final document = await profile.add({
      boulderPointsFieldName: boulderPoints,
      setterPointsFieldName: setterPoints,
      isSetterFieldName: isSetter,
      isAdminFieldName: isAdmin,
      isAnonymousFieldName: isAnonymous,
      if (climbedBoulders != null) climbedBouldersFieldName: climbedBoulders,
      if (setBoulders != null) setBouldersFieldName: setBoulders,
      if (comp != null) compFieldName: comp,
      emailFieldName: email,
      displayNameFieldName: displayName,
      gradingSystemFieldName: gradingSystem,
      userIDfieldName: userID,
    });
    final fetchUser = await document.get();
    return CloudProfile(
      boulderPoints,
      setterPoints,
      isSetter,
      isAdmin,
      isAnonymous,
      climbedBoulders,
      setBoulders,
      comp,
      email,
      displayName,
      gradingSystem,
      userID,
      profileID: fetchUser.id,
    );
  }

  Stream<Iterable<CloudProfile>> getSetters() {
    final setters = profile
        .where(isSetterFieldName, isEqualTo: true)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return setters;
  }

  Stream<Iterable<CloudProfile>> getUser({required String userID}) {
    final currentProfile = profile
        .where(userIDfieldName, isEqualTo: userID)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return currentProfile;
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._shareIstance();
  FirebaseCloudStorage._shareIstance();
  factory FirebaseCloudStorage() => _shared;
}
