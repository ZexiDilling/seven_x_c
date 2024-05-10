import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/challenges/cloud_challenges.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_exceptions.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_location_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_outdoor_data.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';

class FirebaseCloudStorage {
  final bouldersCollection = FirebaseFirestore.instance.collection("boulders");
  final profileCollection = FirebaseFirestore.instance.collection("profile");
  final compCollection = FirebaseFirestore.instance.collection("comp");
  final challengeCollection =
      FirebaseFirestore.instance.collection("challenges");
  final settingsCollection = FirebaseFirestore.instance.collection("settings");
  final gymDataCollection = FirebaseFirestore.instance.collection("gymData");
  final outdoorDataCollection =
      FirebaseFirestore.instance.collection("outdoorData");
  final gymLocationCollection =
      FirebaseFirestore.instance.collection("gymLocation");

// Boulder data
  Future<void> deleteBoulder({required String boulderID}) async {
    try {
      await bouldersCollection.doc(boulderID).delete();
    } catch (e) {
      throw CouldNotDeleteBoulderException();
    }
  }

  Future<void> updateBoulder({
    required String boulderID,
    String? setter,
    double? cordX,
    double? cordY,
    String? wall,
    String? holdColour,
    String? gradeColour,
    int? gradeNumberSetter,
    int? gradeDifficulty,
    bool? topOut,
    bool? active,
    bool? hiddenGrade,
    bool? compBoulder,
    bool? gotZone,
    List? tags,
    double? setterPoint,
    String? boulderName,
    Timestamp? updateDateBoulder,
    Map<String, dynamic>? boulderChallenges,
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
      if (gradeDifficulty != null) {
        updatedData[gradeDifficultyFieldName] = gradeDifficulty;
      }
      if (topOut != null) updatedData[topOutFieldName] = topOut;
      if (active != null) updatedData[activeFieldName] = active;
      if (hiddenGrade != null) updatedData[hiddenGradeFieldName] = hiddenGrade;
      if (compBoulder != null) updatedData[compBoulderFieldName] = compBoulder;
      if (gotZone != null) updatedData[gotZoneFieldName] = gotZone;
      if (tags != null) updatedData[tagsFieldName] = tags;
      if (setterPoint != null) updatedData[setterPointFieldName] = setterPoint;
      if (boulderName != null) updatedData[boulderNameFieldName] = boulderName;
      if (updateDateBoulder != null) {
        updatedData[updateDateBoulderFiledName] = updateDateBoulder;
      }
      if (boulderChallenges != null) {
        updatedData[boulderChallengesFieldName] = boulderChallenges;
      }
      if (gradeNumberClimbers != null) {
        updatedData[gradingClimbersFieldName] = gradeNumberClimbers;
      }
      if (climberTopped != null) {
        updatedData[climberToppedFieldName] = climberTopped;
      }
      // Update the document with the non-null fields
      await bouldersCollection.doc(boulderID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateBoulderException();
    }
  }

  Stream<Iterable<CloudBoulder>> getAllBoulders(bool showDeactivatedBoulders) {
    final Stream<Iterable<CloudBoulder>> allBoulders;
    if (showDeactivatedBoulders) {
      allBoulders = bouldersCollection.snapshots().map(
          (event) => event.docs.map((doc) => CloudBoulder.fromSnapshot(doc)));
    } else {
      allBoulders = bouldersCollection
          .where(activeFieldName, isEqualTo: true)
          .snapshots()
          .map((event) =>
              event.docs.map((doc) => CloudBoulder.fromSnapshot(doc)));
    }
    return allBoulders;
  }

  Stream<Iterable<CloudBoulder>> getBoulder({required String boulderID}) {
    final allBoulders = bouldersCollection
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
    required int gradeDifficulty,
    required bool topOut,
    required bool active,
    required bool hiddenGrade,
    required bool compBoulder,
    required bool gotZone,
    required Timestamp setDateBoulder,
    required double setterPoint,
    List? tags,
    Timestamp? updateDateBoulder,
    Map<String, dynamic>? boulderChallenges,
    Map<String, dynamic>? gradeNumberClimber,
    Map<String, dynamic>? climberTopped,
    String? boulderName,
  }) async {
    final document = await bouldersCollection.add({
      setterFieldName: setter,
      coordinateXFieldName: cordX,
      coordinateYFieldName: cordY,
      wallFieldName: wall,
      holdColourFieledName: holdColour,
      gradeColourFieledName: gradeColour,
      gradingSetterFieldName: gradeNumberSetter,
      gradeDifficultyFieldName: gradeDifficulty,
      topOutFieldName: topOut,
      activeFieldName: active,
      hiddenGradeFieldName: hiddenGrade,
      compBoulderFieldName: compBoulder,
      gotZoneFieldName: gotZone,
      boulderNameFieldName: boulderName,
      setDateBoulderFiledName: setDateBoulder,
      updateDateBoulderFiledName: setDateBoulder,
      setterPointFieldName: setterPoint,
      if (tags != null) tagsFieldName: tags,
      if (boulderChallenges != null)
        boulderChallengesFieldName: boulderChallenges,
      if (gradeNumberClimber != null)
        gradingClimbersFieldName: gradeNumberClimber,
      if (climberTopped != null) climberToppedFieldName: climberTopped
    });
    final fetchBoulder = await document.get();
    return CloudBoulder(
      boulderChallenges,
      gradeNumberClimber,
      climberTopped,
      setter,
      cordX,
      cordY,
      wall,
      holdColour,
      gradeColour,
      gradeNumberSetter,
      gradeDifficulty,
      topOut,
      active,
      hiddenGrade,
      compBoulder,
      gotZone,
      tags,
      setterPoint,
      boulderName,
      setDateBoulder,
      setDateBoulder,
      boulderID: fetchBoulder.id,
    );
  }

  Future<List<String>> grabBoulderChallenges({
    required String boulderID,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> boulderSnapshots =
        await bouldersCollection
            .where(FieldPath.documentId, isEqualTo: boulderID)
            .get();
    try {
      // Extract challenges from non-null challenge field
      final List<String> challenges = boulderSnapshots.docs
          .where((doc) => doc['boulderChallenges'] != null)
          .map((doc) =>
              (doc['boulderChallenges'] as Map<String, dynamic>).keys.toList())
          .expand(
              (keys) => keys) // flatten the list of lists into a single list
          .toList();
      return challenges;
    } catch (e) {
      return <String>[];
    }
  }

// User data
  Stream<Iterable<CloudProfile>> getAllUsers() {
    final allUsers = profileCollection
        .where(boulderPointsFieldName, isGreaterThan: 0)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return allUsers;
  }

  Future<void> deleteUser({required String ownerUserId}) async {
    try {
      await profileCollection.doc(ownerUserId).delete();
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
    String? settingsID,
    bool? isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? repeatBoulders,
    Map<String, dynamic>? dateBoulderTopped,
    Map<String, dynamic>? dateBoulderSet,
    Map<String, dynamic>? setBoulders,
    Map<String, dynamic>? challengeProfile,
    Map<String, dynamic>? compProfile,
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
      if (settingsID != null) updatedData[settingsIDFieldName] = settingsID;
      if (isAnonymous != null) updatedData[isAnonymousFieldName] = isAnonymous;
      if (climbedBoulders != null) {
        updatedData[climbedBouldersFieldName] = climbedBoulders;
      }
      if (repeatBoulders != null) {
        updatedData[repeatBouldersFieldName] = repeatBoulders;
      }

      if (dateBoulderTopped != null) {
        updatedData[dateBoulderToppedFieldName] = dateBoulderTopped;
      }
      if (dateBoulderSet != null) {
        updatedData[dateBoulderSetFieldName] = dateBoulderSet;
      }
      if (setBoulders != null) updatedData[setBouldersFieldName] = setBoulders;
      if (challengeProfile != null) {
        updatedData[challengeProfileFieldName] = challengeProfile;
      }
      if (compProfile != null) updatedData[compProfileFieldName] = compProfile;
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
      await profileCollection.doc(currentProfile.profileID).update(updatedData);
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
    required String settingsID,
    required bool isAnonymous,
    Map<String, dynamic>? climbedBoulders,
    Map<String, dynamic>? repeatBoulders,
    Map<String, dynamic>? dateBoulderTopped,
    Map<String, dynamic>? dateBoulderSet,
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
    final document = await profileCollection.add({
      boulderPointsFieldName: boulderPoints,
      setterPointsFieldName: setterPoints,
      challengePointsFieldName: challengePoints,
      isSetterFieldName: isSetter,
      isAdminFieldName: isAdmin,
      settingsIDFieldName: settingsID,
      isAnonymousFieldName: isAnonymous,
      if (climbedBoulders != null) climbedBouldersFieldName: climbedBoulders,
      if (repeatBoulders != null) repeatBouldersFieldName: repeatBoulders,
      if (dateBoulderTopped != null)
        dateBoulderToppedFieldName: dateBoulderTopped,
      if (dateBoulderSet != null) dateBoulderSetFieldName: dateBoulderSet,
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
      settingsID,
      isAnonymous,
      climbedBoulders,
      repeatBoulders,
      dateBoulderTopped,
      dateBoulderSet,
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
    final setters = profileCollection
        .where(isSetterFieldName, isEqualTo: true)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return setters;
  }

  Future<CloudProfile?> getSetter(setterName) async {
    final querySnapshot = await profileCollection
        .where(displayNameFieldName, isEqualTo: setterName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudProfile.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Stream<Iterable<CloudProfile>> getUserFromEmail(String profileEmail) {
    try {
      final currentProfile = profileCollection
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
      final currentProfile = profileCollection
          .orderBy(displayNameFieldName)
          .startAt([profileDisplayName])
          .endAt([
            profileDisplayName + '\uf8ff'
          ]) // \uf8ff is a Unicode character that is higher than any other character in the Unicode set
          .snapshots()
          .map((event) =>
              event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
      return currentProfile;
    } catch (e) {
      throw CouldNotGetSetterProfile();
    }
  }

  Stream<Iterable<CloudProfile>> getUser({required String userID}) {
    final currentProfile = profileCollection
        .where(userIDFieldName, isEqualTo: userID)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => CloudProfile.fromSnapshot(doc)));
    return currentProfile;
  }

  Future<bool> isDisplayNameUnique(
      String displayName, String currentUserId) async {
    try {
      final querySnapshot = await profileCollection
          .where(displayNameFieldName, isEqualTo: displayName)
          .where(userIDFieldName, isNotEqualTo: currentUserId)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw CouldNotCheckDisplayNameException();
    }
  }

// Comp Data
  Future<CloudComp> createNewComp({
    required String compName,
    required String compStyle,
    required String compRules,
    required bool startedComp,
    required bool activeComp,
    required bool signUpActiveComp,
    required Timestamp startDateComp,
    required Timestamp endDateComp,
    required bool includeZones,
    required bool includeFinals,
    required bool includeSemiFinals,
    required bool genderBased,
    int? maxParticipants,
    Map<String, dynamic>? bouldersComp,
    Map<String, dynamic>? climbersComp,
    Map<String, dynamic>? compResults,
    List? randomWinners,
  }) async {
    final document = await compCollection.add({
      compNameFieldName: compName,
      compStyleFieldName: compStyle,
      compRulesFieldName: compRules,
      startedCompFieldName: startedComp,
      activeCompFieldName: activeComp,
      signUpActiveCompFieldName: signUpActiveComp,
      startDateCompFieldName: startDateComp,
      endDateCompFieldName: endDateComp,
      includeZonesFieldName: includeZones,
      includeFinalsFieldName: includeFinals,
      includeSemiFinalsFieldName: includeSemiFinals,
      genderBasedFieldName: genderBased,
      if (maxParticipants != null) maxParticipantsFieldName: maxParticipants,
      if (bouldersComp != null) bouldersCompFieldName: bouldersComp,
      if (climbersComp != null) climbersCompFieldName: climbersComp,
      if (compResults != null) compResultsFieldName: compResults,
      if (randomWinners != null) randomWinnersFieldName: randomWinners
    });
    final fetchComp = await document.get();
    return CloudComp(
        compName,
        compStyle,
        compRules,
        startedComp,
        activeComp,
        signUpActiveComp,
        startDateComp,
        endDateComp,
        maxParticipants,
        includeZones,
        includeFinals,
        includeSemiFinals,
        genderBased,
        bouldersComp,
        climbersComp,
        compResults,
        randomWinners,
        compID: fetchComp.id);
  }

  Future<void> updatComp({
    required String compID,
    String? compName,
    String? compStyle,
    String? compRules,
    bool? startedComp,
    bool? activeComp,
    bool? signUpActiveComp,
    Timestamp? startDateComp,
    Timestamp? endDateComp,
    int? maxParticipants,
    bool? includeZones,
    bool? includeFinals,
    bool? includeSemiFinals,
    bool? genderBased,
    Map<String, dynamic>? bouldersComp,
    Map<String, dynamic>? climbersComp,
    Map<String, dynamic>? compResults,
    List? randomWinners,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      // Add non-null fields to the map
      if (compName != null) updatedData[compNameFieldName] = compName;
      if (compStyle != null) updatedData[compStyleFieldName] = compStyle;
      if (compRules != null) updatedData[compRulesFieldName] = compRules;
      if (startedComp != null) updatedData[startedCompFieldName] = startedComp;
      if (activeComp != null) updatedData[activeCompFieldName] = activeComp;
      if (signUpActiveComp != null) {
        updatedData[signUpActiveCompFieldName] = signUpActiveComp;
      }
      if (startDateComp != null) {
        updatedData[startDateCompFieldName] = startDateComp;
      }
      if (endDateComp != null) updatedData[endDateCompFieldName] = endDateComp;
      if (maxParticipants != null) {
        updatedData[maxParticipantsFieldName] = maxParticipants;
      }
      if (includeZones != null) {
        updatedData[includeZonesFieldName] = includeZones;
      }
      if (includeFinals != null) {
        updatedData[includeFinalsFieldName] = includeFinals;
      }
      if (includeSemiFinals != null) {
        updatedData[includeSemiFinalsFieldName] = includeSemiFinals;
      }
      if (genderBased != null) updatedData[genderBasedFieldName] = genderBased;
      if (bouldersComp != null) {
        updatedData[bouldersCompFieldName] = bouldersComp;
      }
      if (climbersComp != null) {
        updatedData[climbersCompFieldName] = climbersComp;
      }
      if (compResults != null) {
        updatedData[compResultsFieldName] = compResults;
      }
      if (randomWinners != null) {
        updatedData[randomWinnersFieldName] = randomWinners;
      }

      // Update the document with the non-null fields
      await compCollection.doc(compID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateComp();
    }
  }

  Future<CloudComp?> getComp(compName) async {
    final querySnapshot = await compCollection
        .where(compNameFieldName, isEqualTo: compName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudComp.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Stream<Iterable<CloudComp>> getAllComps() {
    final activeComp = compCollection
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudComp.fromSnapshot(doc)));
    return activeComp;
  }

  Stream<Iterable<CloudComp>> getActiveComps() {
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

  Future<CloudChallenge> createNewChallenge({
    required String challengeName,
    required String challengeCreator,
    required String challengeType,
    required String challengeDescription,
    required double challengeOwnPoints,
    required List challengeBoulders,
    required bool challengeCounter,
    required int challengeCounterRunning,
    required int challengeDifficulty,
  }) async {
    final document = await challengeCollection.add({
      challengeNameFieldName: challengeName,
      challengeCreatorFieldName: challengeCreator,
      challengeTypeFieldName: challengeType,
      challengeDescriptionFieldName: challengeDescription,
      challengeOwnPointsFieldName: challengeOwnPoints,
      challengeBouldersFieldName: challengeBoulders,
      challengeCounterFieldName: challengeCounter,
      challengeCounterRunningFieldName: challengeCounterRunning,
      challengeDifficultyFieldName: challengeDifficulty,
    });
    final fetchChallenge = await document.get();
    return CloudChallenge(
      challengeName,
      challengeCreator,
      challengeType,
      challengeDescription,
      challengeOwnPoints,
      challengeBoulders,
      challengeCounter,
      challengeDifficulty,
      challengeCounterRunning,
      challengeID: fetchChallenge.id,
    );
  }

  Future<void> updateChallenge({
    required String challengeID,
    String? challengeName,
    String? challengeCreator,
    String? challengeType,
    String? challengeDescription,
    double? challengeOwnPoints,
    List? challengeBoulders,
    bool? challengeCounter,
    int? challengeCounterRunning,
    int? challengeDifficulty,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      // Add non-null fields to the map
      if (challengeCreator != null) {
        updatedData[challengeCreatorFieldName] = challengeCreator;
      }
      if (challengeType != null) {
        updatedData[challengeTypeFieldName] = challengeType;
      }
      if (challengeDescription != null) {
        updatedData[challengeDescriptionFieldName] = challengeDescription;
      }
      if (challengeOwnPoints != null) {
        updatedData[challengeOwnPointsFieldName] = challengeOwnPoints;
      }
      if (challengeBoulders != null) {
        updatedData[challengeBouldersFieldName] = challengeBoulders;
      }
      if (challengeCounter != null) {
        updatedData[challengeCounterFieldName] = challengeCounter;
      }
      if (challengeCounterRunning != null) {
        updatedData[challengeCounterRunningFieldName] = challengeCounterRunning;
      }
      if (challengeDifficulty != null) {
        updatedData[challengeDifficultyFieldName] = challengeDifficulty;
      }
      await challengeCollection.doc(challengeID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateChallenge();
    }
  }

  Future<CloudChallenge?> getchallenge(challengeName) async {
    final querySnapshot = await challengeCollection
        .where(challengeNameFieldName, isEqualTo: challengeName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there's at least one document with the specified compID
      // Return the first document as a CloudComp instance
      return CloudChallenge.fromSnapshot(querySnapshot.docs.first);
    } else {
      // If no document with the specified compID is found, return null
      return null;
    }
  }

  Stream<Iterable<CloudChallenge>> getAllChallenges() {
    final allChallenges = challengeCollection.snapshots().map(
        (event) => event.docs.map((doc) => CloudChallenge.fromSnapshot(doc)));
    return allChallenges;
  }

  Future<CloudSettings> createSettings({
    required String settingsID,
    required String settingsNameID,
    required String settingsName,
    required String settingsCountry,
    required String settingsLocation,
    required String settingsStyle,
    required List settingsActivites,
    Map<String, dynamic>? appBarMain,
    Map<String, dynamic>? appBarComp,
    Map<String, dynamic>? appBarEditing,
    Map<String, dynamic>? mainTexstStyle,
    bool? settingsHoldsFollowsGrade,
    Map<String, dynamic>? settingsHoldColour,
    Map<String, dynamic>? settingsGradeColour,
    Map<String, dynamic>? settingsColorToGrade,
    Map<String, dynamic>? settingsWallRegions,
    String? contactEmail,
  }) async {
    final document = await settingsCollection.add({
      settingsNameIDFieldName: settingsNameID,
      settingsNameFieldName: settingsName,
      settingsStyleFieldName: settingsStyle,
      settingsActivitesFieldName: settingsActivites,
      appBarMainFieldName: appBarMain,
      appBarCompFieldName: appBarComp,
      appBarEditingFieldName: appBarEditing,
      mainTexstStyleFieldName: mainTexstStyle,
      settingsHoldsFollowsGradeFieldName: settingsHoldsFollowsGrade,
      settingsHoldColourFieldName: settingsHoldColour,
      settingsGradeColourFieldName: settingsGradeColour,
      settingsColorToGradeFieldName: settingsColorToGrade,
      settingsWallRegionsFieldName: settingsWallRegions,
      contactEmailFildName: contactEmail,
    });
    final fetchChallenge = await document.get();
    return CloudSettings(
      settingsNameID,
      settingsName,
      settingsStyle,
      settingsActivites,
      appBarMain,
      appBarComp,
      appBarEditing,
      mainTexstStyle,
      settingsHoldsFollowsGrade,
      settingsHoldColour,
      settingsGradeColour,
      settingsColorToGrade,
      settingsWallRegions,
      contactEmail,
      settingsID: fetchChallenge.id,
    );
  }

  Future<void> updateSettings({
    required String settingsID,
    String? settingsName,
    String? settingsStyle,
    List? settingsActivites,
    Map<String, dynamic>? appBarMain,
    Map<String, dynamic>? appBarComp,
    Map<String, dynamic>? appBarEditing,
    Map<String, dynamic>? mainTexstStyle,
    bool? settingsHoldsFollowsGrade,
    Map<String, dynamic>? settingsHoldColour,
    Map<String, dynamic>? settingsGradeColour,
    Map<String, dynamic>? settingsColorToGrade,
    Map<String, dynamic>? settingsWallRegions,
    String? contactEmail,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      if (settingsName != null) {
        updatedData[settingsNameFieldName] = settingsName;
      }
      if (settingsStyle != null) {
        updatedData[settingsStyleFieldName] = settingsStyle;
      }
      if (settingsActivites != null) {
        updatedData[settingsActivitesFieldName] = settingsActivites;
      }
      if (appBarMain != null) {
        updatedData[appBarMainFieldName] = appBarMain;
      }
      if (appBarComp != null) {
        updatedData[appBarCompFieldName] = appBarComp;
      }
      if (appBarEditing != null) {
        updatedData[appBarEditingFieldName] = appBarEditing;
      }
      if (mainTexstStyle != null) {
        updatedData[mainTexstStyleFieldName] = mainTexstStyle;
      }
      if (settingsHoldsFollowsGrade != null) {
        updatedData[settingsHoldsFollowsGradeFieldName] =
            settingsHoldsFollowsGrade;
      }
      if (settingsHoldColour != null) {
        updatedData[settingsHoldColourFieldName] = settingsHoldColour;
      }
      if (settingsGradeColour != null) {
        updatedData[settingsGradeColourFieldName] = settingsGradeColour;
      }
      if (settingsColorToGrade != null) {
        updatedData[settingsColorToGradeFieldName] = settingsColorToGrade;
      }
      if (settingsWallRegions != null) {
        updatedData[settingsWallRegionsFieldName] = settingsWallRegions;
      }
      if (contactEmail != null) {
        updatedData[contactEmailFildName] = contactEmail;
      }

      // Add non-null fields to the map

      await settingsCollection.doc(settingsID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateSettings();
    }
  }

  Future<CloudSettings?> getSettings(String? settingsNameID) async {
    final querySnapshot = await settingsCollection
        .where(settingsNameIDFieldName, isEqualTo: settingsNameID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudSettings.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Future<void> deleteChallenge({required String challengeID}) async {
    try {
      await challengeCollection.doc(challengeID).delete();
    } catch (e) {
      throw CouldNotDeleteUserException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._shareIstance();
  FirebaseCloudStorage._shareIstance();
  factory FirebaseCloudStorage() => _shared;

  Future<CloudGymData> createGymData({
    required String gymDataID,
    required String gymDataNameID,
    Map<String, dynamic>? gymDataClimbers,
    Map<String, dynamic>? gymDataBoulders,
    Map<String, dynamic>? gymDataBouldersTopped,
    Map<String, dynamic>? gymDataRoutesTopped,
  }) async {
    final document = await gymDataCollection.add({
      gymDataNameIDFieldName: gymDataNameID,
      gymDataClimbersFieldName: gymDataClimbers,
      gymDataBouldersFieldName: gymDataBoulders,
      gymDataBouldersToppedFieldName: gymDataBouldersTopped,
      gymDataRoutesToppedFieldName: gymDataRoutesTopped,
    });
    final fetchGymData = await document.get();
    return CloudGymData(
      gymDataNameID,
      gymDataClimbers,
      gymDataBoulders,
      gymDataBouldersTopped,
      gymDataRoutesTopped,
      gymDataID: fetchGymData.id,
    );
  }

  Future<void> updateGymData({
    required String gymDataID,
    String? gymDataNameID,
    Map<String, dynamic>? gymDataClimbers,
    Map<String, dynamic>? gymDataBoulders,
    Map<String, dynamic>? gymDataBouldersTopped,
    Map<String, dynamic>? gymDataRoutesTopped,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      if (gymDataNameID != null) {
        updatedData[gymDataNameIDFieldName] = gymDataNameID;
      }

      if (gymDataClimbers != null) {
        updatedData[gymDataClimbersFieldName] = gymDataClimbers;
      }
      if (gymDataBoulders != null) {
        updatedData[gymDataBouldersFieldName] = gymDataBoulders;
      }
      if (gymDataBouldersTopped != null) {
        updatedData[gymDataBouldersToppedFieldName] = gymDataBouldersTopped;
      }
      if (gymDataRoutesTopped != null) {
        updatedData[gymDataRoutesToppedFieldName] = gymDataRoutesTopped;
      }
      await gymDataCollection.doc(gymDataID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateSettings();
    }
  }

  Future<CloudGymData?> getGymData(String? gymDataNameID) async {
    final querySnapshot = await gymDataCollection
        .where(gymDataNameIDFieldName, isEqualTo: gymDataNameID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudGymData.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Future<CloudOutdoorData> createOutdoorData({
    required String outdoorDataID,
    required String outdoorDataNameID,
    Map<String, dynamic>? outdoorSections,
    Map<String, dynamic>? outdoorDataClimbers,
    Map<String, dynamic>? outdoorDataBoulders,
    Map<String, dynamic>? outdoorDataBouldersTopped,
    Map<String, dynamic>? outdoorDataRoutes,
    Map<String, dynamic>? outdoorDataRoutesTopped,
  }) async {
    final document = await outdoorDataCollection.add({
      outdoorDataNameIDFieldName: outdoorDataNameID,
      outdoorSectionsFieldName: outdoorSections,
      outdoorDataClimbersFieldName: outdoorDataClimbers,
      outdoorDataBouldersFieldName: outdoorDataBoulders,
      outdoorDataBouldersToppedFieldName: outdoorDataBouldersTopped,
      outdoorDataRoutesFieldName: outdoorDataRoutes,
      outdoorDataRoutesToppedFieldName: outdoorDataRoutesTopped,
    });
    final fetchGymData = await document.get();
    return CloudOutdoorData(
      outdoorDataNameID,
      outdoorSections,
      outdoorDataClimbers,
      outdoorDataBoulders,
      outdoorDataBouldersTopped,
      outdoorDataRoutes,
      outdoorDataRoutesTopped,
      outdoorDataID: fetchGymData.id,
    );
  }

  Future<void> updateOutdoorData({
    required String outdoorDataID,
    String? outdoorDataNameID,
    Map<String, dynamic>? outdoorSections,
    Map<String, dynamic>? outdoorDataClimbers,
    Map<String, dynamic>? outdoorDataBoulders,
    Map<String, dynamic>? outdoorDataBouldersTopped,
    Map<String, dynamic>? outdoorDataRoutes,
    Map<String, dynamic>? outdoorDataRoutesTopped,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      if (outdoorDataNameID != null) {
        updatedData[gymDataNameIDFieldName] = outdoorDataNameID;
      }

      if (outdoorSections != null) {
        updatedData[gymDataClimbersFieldName] = outdoorSections;
      }
      if (outdoorDataClimbers != null) {
        updatedData[gymDataBouldersFieldName] = outdoorDataClimbers;
      }
      if (outdoorDataBoulders != null) {
        updatedData[gymDataBouldersToppedFieldName] = outdoorDataBoulders;
      }
      if (outdoorDataBouldersTopped != null) {
        updatedData[gymDataRoutesToppedFieldName] = outdoorDataBouldersTopped;
      }
      if (outdoorDataRoutes != null) {
        updatedData[gymDataRoutesToppedFieldName] = outdoorDataRoutes;
      }

      if (outdoorDataRoutesTopped != null) {
        updatedData[gymDataRoutesToppedFieldName] = outdoorDataRoutesTopped;
      }

      await outdoorDataCollection.doc(outdoorDataID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateSettings();
    }
  }

  Future<CloudOutdoorData?> getOutdoorData(String? gymDataNameID) async {
    final querySnapshot = await outdoorDataCollection
        .where(outdoorDataNameIDFieldName, isEqualTo: gymDataNameID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudOutdoorData.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Stream<Iterable<Map<String, dynamic>?>> getAllOutdoorBoulders(
      String locationName) {
    final Stream<Iterable<Map<String, dynamic>?>> allBoulders;
    allBoulders = outdoorDataCollection
        .where(locationNameIDFieldName, isEqualTo: locationName)
        .snapshots()
        .map((event) => event.docs.map(
            (doc) => CloudOutdoorData.fromSnapshot(doc).outdoorDataBoulders));
    return allBoulders;
  }

  Future<CloudLocationData> createGymLocation({
    required String locationID,
    required String locationNameID,
    required bool bouldering,
    required bool sport,
    required bool trad,
    required bool isGym,
    required double locationXCordinate,
    required double locationYCordinate,
    required String locationCountry,
    String? locationAdresse,
    String? locationHomepage,
    String? locationEmail,
    String? locationInfo,
    String? locationAccess,
  }) async {
    final document = await gymLocationCollection.add({
      locationNameIDFieldName: locationNameID,
      boulderingFieldName: bouldering,
      sportFieldName: sport,
      tradFieldName: trad,
      isGymFieldName: isGym,
      locationXCordinateFieldName: locationXCordinate,
      locationYCordinateFieldName: locationYCordinate,
      locationCountryFieldName: locationCountry,
      locationAdresseFieldName: locationAdresse,
      locationHomepageFieldName: locationHomepage,
      locationEmailFieldName: locationEmail,
      locationInfoFieldName: locationInfo,
      locationAccessFieldName: locationAccess,
    });
    final fetchGymLocation = await document.get();
    return CloudLocationData(
      locationNameID,
      bouldering,
      sport,
      trad,
      isGym,
      locationXCordinate,
      locationYCordinate,
      locationCountry,
      locationAdresse,
      locationHomepage,
      locationEmail,
      locationInfo,
      locationAccess,
      locationID: fetchGymLocation.id,
    );
  }

  Future<void> updateGymLocation({
    required String locationID,
    String? locationNameID,
    bool? bouldering,
    bool? sport,
    bool? trad,
    bool? isGym,
    double? locationXCordinate,
    double? locationYCordinate,
    String? locationCountry,
    String? locationAdresse,
    String? locationHomepage,
    String? locationEmail,
    String? locationInfo,
    String? locationAccess,
  }) async {
    try {
      // Create a map to store non-null fields and their values
      final Map<String, dynamic> updatedData = {};

      if (locationNameID != null) {
        updatedData[locationNameIDFieldName] = locationNameID;
      }
      if (bouldering != null) {
        updatedData[boulderingFieldName] = bouldering;
      }
      if (sport != null) {
        updatedData[sportFieldName] = sport;
      }
      if (trad != null) {
        updatedData[tradFieldName] = trad;
      }
      if (isGym != null) {
        updatedData[isGymFieldName] = isGym;
      }
      if (locationXCordinate != null) {
        updatedData[locationXCordinateFieldName] = locationXCordinate;
      }
      if (locationYCordinate != null) {
        updatedData[locationYCordinateFieldName] = locationYCordinate;
      }
      if (locationCountry != null) {
        updatedData[locationCountryFieldName] = locationCountry;
      }
      if (locationAdresse != null) {
        updatedData[locationAdresseFieldName] = locationAdresse;
      }
      if (locationHomepage != null) {
        updatedData[locationHomepageFieldName] = locationHomepage;
      }
      if (locationEmail != null) {
        updatedData[locationEmailFieldName] = locationEmail;
      }
      if (locationInfo != null) {
        updatedData[locationInfoFieldName] = locationInfo;
      }
      if (locationAccess != null) {
        updatedData[locationAccessFieldName] = locationAccess;
      }

      await gymDataCollection.doc(locationID).update(updatedData);
    } catch (e) {
      throw CouldNotUpdateSettings();
    }
  }

  Future<CloudLocationData?> getGymLocation(String? locationNameID) async {
    final querySnapshot = await gymLocationCollection
        .where(locationNameIDFieldName, isEqualTo: locationNameID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return CloudLocationData.fromSnapshot(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  Stream<Iterable<CloudLocationData>> getAllGymLocations() {
    final allLocations = gymLocationCollection.snapshots().map((event) =>
        event.docs.map((doc) => CloudLocationData.fromSnapshot(doc)));
    return allLocations;
  }
}
