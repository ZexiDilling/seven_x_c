import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/notes/cloud_note.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_exceptions.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

class FirebaseCloudStorage {
  // Todo Remove notes from this
  final notes = FirebaseFirestore.instance.collection("notes");
  final boulders = FirebaseFirestore.instance.collection("boulders");
  final profile = FirebaseFirestore.instance.collection("profile");
  final compCollection = FirebaseFirestore.instance.collection("comp");

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

// Boulder data
  Future<void> deleteBoulder({required String boulderID}) async {
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
    bool? hiddenGrade,
    bool? compBoulder,
    Timestamp? updateDateBoulder,
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
      if (active != null) updatedData[activeFieldName] = active;
      if (hiddenGrade != null) updatedData[hiddenGradeFieldName] = hiddenGrade;
      if (compBoulder != null) updatedData[compBoulderFieldName] = compBoulder;
      if (updateDateBoulder != null) {
        updatedData[updateDateBoulderFiledName] = updateDateBoulder;
      }
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
        .where(activeFieldName, isEqualTo: true)
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
    required bool hiddenGrade,
    required bool compBoulder,
    required Timestamp setDateBoulder,
    Timestamp? updateDateBoulder,
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
      activeFieldName: active,
      hiddenGradeFieldName: hiddenGrade,
      compBoulderFieldName: compBoulder,
      setDateBoulderFiledName: setDateBoulder,
      updateDateBoulderFiledName: setDateBoulder,
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
      hiddenGrade,
      compBoulder,
      setDateBoulder,
      setDateBoulder,
      boulderID: fetchBoulder.id,
    );
  }

// User data
  Stream<Iterable<CloudProfile>> getAllUsers() {
    final allUsers = profile
        .where(boulderPointsFieldName, isGreaterThan: 0)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return allUsers;
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
    double? challengePoints,
    bool? isSetter,
    bool? isAdmin,
    bool? isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? setBoulders,
    Map<String, dynamic>? challengeProfile,
    Map<String, dynamic>? comp,
    String? email,
    String? displayName,
    String? gradingSystem,
    int? maxFlahsedGrade,
    int? maxToppedGrade,
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
      if (challengePoints != null) {
        updatedData[challengePointsFieldName] = setterPoints;
      }

      if (isSetter != null) updatedData[isSetterFieldName] = isSetter;
      if (isAdmin != null) updatedData[isAdminFieldName] = isAdmin;
      if (isAnonymous != null) updatedData[isAnonymousFieldName] = isAnonymous;
      if (climbedBoulders != null) {
        updatedData[climbedBouldersFieldName] = climbedBoulders;
      }
      if (setBoulders != null) updatedData[setBouldersFieldName] = setBoulders;
      if (challengeProfile != null) {
        updatedData[challengeProfileFieldName] = challengeProfile;
      }
      if (comp != null) updatedData[compBoulderFieldName] = comp;
      if (email != null) updatedData[emailFieldName] = email;
      if (displayName != null) updatedData[displayNameFieldName] = displayName;
      if (gradingSystem != null) {
        updatedData[gradingSystemFieldName] = gradingSystem;
      }
      if (maxFlahsedGrade != null) {
        updatedData[maxFlashedGradeFieldName] = maxFlahsedGrade;
      }
      if (maxToppedGrade != null) {
        updatedData[maxToppedGradeFieldName] = maxToppedGrade;
      }

      updatedData[updateDateProfileFieldName] = Timestamp.now();
      // Update the document with the non-null fields
      await profile.doc(currentProfile.profileID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  Future<CloudProfile> createNewUser({
    required double boulderPoints,
    required double setterPoints,
    required double challengePoints,
    required bool isSetter,
    required bool isAdmin,
    required bool isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? setBoulders,
    Map<String, dynamic>? challengeProfile,
    Map<String, dynamic>? comp,
    required String email,
    required String displayName,
    required String gradingSystem,
    required String userID,
    required int maxToppedGrade,
    required int maxFlahsedGrade,
    required Timestamp createdDateProfile,
    required Timestamp updateDateProfile,
  }) async {
    final document = await profile.add({
      boulderPointsFieldName: boulderPoints,
      setterPointsFieldName: setterPoints,
      challengePointsFieldName: challengePoints,
      isSetterFieldName: isSetter,
      isAdminFieldName: isAdmin,
      isAnonymousFieldName: isAnonymous,
      if (climbedBoulders != null) climbedBouldersFieldName: climbedBoulders,
      if (setBoulders != null) setBouldersFieldName: setBoulders,
      if (challengeProfile != null) challengeProfileFieldName: challengeProfile,
      if (comp != null) compBoulderFieldName: comp,
      emailFieldName: email,
      displayNameFieldName: displayName,
      gradingSystemFieldName: gradingSystem,
      userIDFieldName: userID,
      maxToppedGradeFieldName: maxToppedGrade,
      maxFlashedGradeFieldName: maxFlahsedGrade,
      createdDateProfileFieldName: createdDateProfile,
      updateDateProfileFieldName: updateDateProfile,
    });
    final fetchUser = await document.get();
    return CloudProfile(
      boulderPoints,
      setterPoints,
      challengePoints,
      isSetter,
      isAdmin,
      isAnonymous,
      climbedBoulders,
      setBoulders,
      challengeProfile,
      comp,
      email,
      displayName,
      gradingSystem,
      userID,
      maxToppedGrade,
      maxFlahsedGrade,
      createdDateProfile,
      updateDateProfile,
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

  Stream<Iterable<CloudProfile>> getUserFromEmail(String profileEmail) {
    try {
      final currentProfile = profile
          .where(emailFieldName, isEqualTo: profileEmail)
          .snapshots()
          .map((event) =>
              event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
      return currentProfile;
    } catch (e) {
      throw CouldNotGetSetterProfile();
    }
  }

  Stream<Iterable<CloudProfile>> getUserFromDisplayName(
      String profileDisplayName) {
    try {
      final currentProfile = profile
          .where(displayNameFieldName, isEqualTo: profileDisplayName)
          .snapshots()
          .map((event) =>
              event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
      return currentProfile;
    } catch (e) {
      throw CouldNotGetSetterProfile();
    }
  }

  Stream<Iterable<CloudProfile>> getUser({required String userID}) {
    final currentProfile = profile
        .where(userIDFieldName, isEqualTo: userID)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return currentProfile;
  }

  Future<bool> isDisplayNameUnique(
      String displayName, String currentUserId) async {
    try {
      final querySnapshot = await profile
          .where(displayNameFieldName, isEqualTo: displayName)
          .where(userIDFieldName, isNotEqualTo: currentUserId)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Handle any errors that might occur during the process
      print('Error checking displayName uniqueness: $e');
      throw CouldNotCheckDisplayNameException();
    }
  }

// Comp Data
  Future<CloudComp> createNewComp({
    required String compName,
    required bool activeComp,
    required bool signUpActiveComp,
    required Timestamp startDateComp,
    required Timestamp endDateComp,
    int? maxParticipants,
    Map<String, dynamic>? bouldersComp,
    Map<String, dynamic>? climbersComp,
  }) async {
    final document = await compCollection.add({
      compNameFieldName: compName,
      activeCompFieldName: activeComp,
      signUpActiveCompFieldName: signUpActiveComp,
      startDateCompFieldName: startDateComp,
      endDateCompFieldName: endDateComp,
      if (maxParticipants != null) maxParticipantsFieldName: maxParticipants,
      if (bouldersComp != null) bouldersCompFieldName: bouldersComp,
      if (climbersComp != null) climbersCompFieldName: climbersComp,
    });
    final fetchComp = await document.get();
    return CloudComp(
      compName,
      activeComp,
      signUpActiveComp,
      startDateComp,
      endDateComp,
      maxParticipants,
      bouldersComp,
      climbersComp,
      compID: fetchComp.id
    );
  }

  Future<void> updatComp({
    required String compID,
    bool? activeComp,
    bool? signUpActiveComp,
    Timestamp? startDateComp,
    Timestamp? endDateComp,
    int? maxParticipants,
    Map<String, dynamic>? bouldersComp,
    Map<String, dynamic>? climbersComp,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      // Add non-null fields to the map
      if (activeComp != null) updatedData[activeCompFieldName] = activeComp;
      if (signUpActiveComp != null) updatedData[signUpActiveCompFieldName] = signUpActiveComp;
      if (startDateComp != null) updatedData[startDateCompFieldName] = startDateComp;
      if (endDateComp != null) updatedData[endDateCompFieldName] = endDateComp;
      if (maxParticipants != null) updatedData[maxParticipantsFieldName] = maxParticipants;
      if (bouldersComp != null) updatedData[bouldersCompFieldName] = bouldersComp;
      if (climbersComp != null) updatedData[climbersCompFieldName] = climbersComp;
      
      // Update the document with the non-null fields
      await compCollection.doc(compID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateComp();
    }
  }

  Stream<Iterable<CloudComp>> getComp() {
    final activeComp = compCollection
        .where(activeCompFieldName, isEqualTo: true)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudComp.fromSnapshot(doc)));
    return activeComp;
  }

  Future<void> deleteComp({required String compID}) async {
    try {
      await compCollection.doc(compID).delete();
    } catch (e) {
      throw CouldNotDeleteUserException();
    }
  }


  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._shareIstance();
  FirebaseCloudStorage._shareIstance();
  factory FirebaseCloudStorage() => _shared;
}
