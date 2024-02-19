import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudProfile {
  final double boulderPoints;
  final double setterPoints;
  final double challengePoints;
  final bool isSetter;
  final bool isAdmin;
  final String? settingsID;
  final bool isAnonymous;
  final Map<String, dynamic>? climbedBoulders;
  final Map<String, dynamic>? dateBoulderTopped;
  final Map<String, dynamic>? dateBoulderSet;
  final Map<String, dynamic>? setBoulders;
  final Map<String, dynamic>? challengeProfile;
  final Map<String, dynamic>? compProfile;
  final String profileID;
  final String email;
  final String displayName;
  final String gradingSystem;
  final String userID;
  final int maxToppedGrade;
  final int maxFlahsedGrade;
  final Timestamp createdDateProfile;
  final Timestamp updateDateProfile;

  CloudProfile(
    this.boulderPoints,
    this.setterPoints,
    this.challengePoints,
    this.isSetter,
    this.isAdmin,
    this.settingsID,
    this.isAnonymous,
    this.climbedBoulders,
    this.dateBoulderTopped,
    this.dateBoulderSet,
    this.setBoulders,
    this.challengeProfile,
    this.compProfile,
    this.email,
    this.displayName,
    this.gradingSystem,
    this.userID,
    this.maxToppedGrade,
    this.maxFlahsedGrade,
    this.createdDateProfile,
    this.updateDateProfile, {
    required this.profileID,
  });

  CloudProfile.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : boulderPoints =
            (snapshot.data()[boulderPointsFieldName] as num?)?.toDouble() ??
                0.0,
        setterPoints =
            (snapshot.data()[setterPointsFieldName] as num?)?.toDouble() ?? 0.0,
        challengePoints =
            (snapshot.data()[challengePointsFieldName] as num?)?.toDouble() ??
                0.0,
        isSetter = snapshot.data()[isSetterFieldName] as bool,
        isAdmin = snapshot.data()[isAdminFieldName] as bool,
        settingsID = snapshot.data()[settingsIDFieldName] as String?,
        isAnonymous = snapshot.data()[isAnonymousFieldName] as bool,
        climbedBoulders =
            snapshot.data()[climbedBouldersFieldName] as Map<String, dynamic>?,
        dateBoulderTopped = snapshot.data()[dateBoulderToppedFieldName]
            as Map<String, dynamic>?,
            dateBoulderSet = snapshot.data()[dateBoulderSetFieldName]
            as Map<String, dynamic>?,
        setBoulders =
            snapshot.data()[setBouldersFieldName] as Map<String, dynamic>?,
        challengeProfile =
            snapshot.data()[challengeProfileFieldName] as Map<String, dynamic>?,
        compProfile =
            snapshot.data()[compBoulderFieldName] as Map<String, dynamic>?,
        email = snapshot.data()[emailFieldName] as String,
        displayName = snapshot.data()[displayNameFieldName] as String,
        gradingSystem = snapshot.data()[gradingSystemFieldName] as String,
        userID = snapshot.data()[userIDFieldName] as String,
        maxToppedGrade = snapshot.data()[maxToppedGradeFieldName] as int,
        maxFlahsedGrade = snapshot.data()[maxFlashedGradeFieldName] as int,
        createdDateProfile =
            snapshot.data()[createdDateProfileFieldName] as Timestamp,
        updateDateProfile =
            snapshot.data()[updateDateProfileFieldName] as Timestamp,
        profileID = snapshot.id;
}
