import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudProfile {
  final double boulderPoints;
  final double setterPoints;
  final bool isSetter;
  final bool isAdmin;
  final bool isAnonymous;
  final Map<String, dynamic>? climbedBoulders;
  final Map<String, dynamic>? setBoulders;
  final Map<String, dynamic>? comp;
  final String profileID;
  final String email;
  final String displayName;
  final String gradingSystem;
  final String userID;

  CloudProfile(
    this.boulderPoints,
    this.setterPoints,
    this.isSetter,
    this.isAdmin,
    this.isAnonymous,
    this.climbedBoulders,
    this.setBoulders,
    this.comp,
    this.email,
    this.displayName,
    this.gradingSystem,
    this.userID, {
    required this.profileID,
  });

  CloudProfile.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : boulderPoints = snapshot.data()[boulderPointsFieldName] as double,
        setterPoints = snapshot.data()[setterPointsFieldName] as double,
        isSetter = snapshot.data()[isSetterFieldName] as bool,
        isAdmin = snapshot.data()[isAdminFieldName] as bool,
        isAnonymous = snapshot.data()[isAnonymousFieldName] as bool,
        climbedBoulders =
            snapshot.data()[climbedBouldersFieldName] as Map<String, dynamic>?,
        setBoulders =
            snapshot.data()[setBouldersFieldName] as Map<String, dynamic>?,
        comp = snapshot.data()[compBoulderFieldName] as Map<String, dynamic>?,
        email = snapshot.data()[emailFieldName] as String,
        displayName = snapshot.data()[displayNameFieldName] as String,
        gradingSystem = snapshot.data()[gradingSystemFieldName] as String,
        userID = snapshot.data()[userIDfieldName] as String,
        profileID = snapshot.id;
}
