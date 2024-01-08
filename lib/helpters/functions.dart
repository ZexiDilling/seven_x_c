import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}

Map<String, dynamic> updateClimberBoulderSetMap(
    {required CloudBoulder boulder,
    String? gradeColour,
    int? gradeArrow,
    String? wall,
    String? holdColour,
    double? setterPoints,
    Map<String, dynamic>? existingData}) {
  String? boulderID = boulder.boulderID;
  int? gradeNumberBoulder = boulder.gradeNumberSetter;

  Map<String, dynamic> newData = {
    "grade": gradeNumberBoulder,
    "gradeColour": gradeColour,
    "gradeArrow": gradeArrow,
    "holdColour": holdColour,
    "wall": wall,
    "points": setterPoints,
    "date": DateTime.now()
  };

  Map<String, dynamic> bouldersClimbedData = existingData ?? {};
  bouldersClimbedData[boulderID.toString()] = newData;

  return bouldersClimbedData;
}

Map<String, dynamic> updateClimbedBouldersMap(
    {required CloudBoulder boulder,
    required int attempts,
    required bool flashed,
    bool? topped,
    String? gradeColour,
    int? gradeArrow,
    double? boulderPoints,
    Map<String, dynamic>? existingData}) {
  String? boulderID = boulder.boulderID;
  int? gradeNumberBoulder = boulder.gradeNumberSetter;

  Map<String, dynamic> newData = {
    "gradeNumber": gradeNumberBoulder,
    "gradeColour": gradeColour,
    "gradeArrow": gradeArrow,
    'attempts': attempts,
    "topped": topped,
    'flashed': flashed,
    "points": boulderPoints,
    "date": DateTime.now()
  };

  Map<String, dynamic> bouldersClimbedData = existingData ?? {};
  bouldersClimbedData[boulderID.toString()] = newData;

  return bouldersClimbedData;
}

double updatePoints({required double points, double? existingData}) {
  if (existingData != null) {
    return points += existingData;
  } else {return points;}
}

Map<String, dynamic> updateBoulderSet(
    {required CloudProfile currentProfile,
    required CloudBoulder newBoulder,
    required double setterPoints,
    Map<String, dynamic>? existingData}) {
  String boulderID = newBoulder.boulderID;

  Map<String, dynamic> newData = {
    'holdColour': newBoulder.holdColour,
    'gradeColour': newBoulder.gradeColour,
    'gradeNumberSetter': newBoulder.gradeNumberSetter,
    'topOut': newBoulder.topOut,
    'compBoulder': newBoulder.compBoulder,
    'setDateBoulder': newBoulder.setDateBoulder,
    "setterPoints": setterPoints,
  };

  Map<String, dynamic> setBoulder = existingData ?? {};
  setBoulder[boulderID] = newData;

  return setBoulder;
}

Map<String, dynamic> updateClimberToppedMap(
    {required CloudProfile currentProfile,
    required int attempts,
    required bool flashed,
    required bool topped,
    int? gradeNumberVoted,
    String? gradeColourVoted,
    int? gradeArrowVoted,
    Map<String, dynamic>? existingData}) {
  String displayName = currentProfile.displayName;
  bool isAnonymous = currentProfile.isAnonymous;
  String userID = currentProfile.userID;

  Map<String, dynamic> newData = {
    "displayName": displayName,
    "isAnonymous": isAnonymous,
    'attempts': attempts,
    "topped": topped,
    'flashed': flashed,
    "gradeNumber": gradeNumberVoted,
    "gradeColour": gradeColourVoted,
    "gradeArrow": gradeArrowVoted,
  };

  Map<String, dynamic> climberToppedData = existingData ?? {};
  climberToppedData[userID] = newData;

  return climberToppedData;
}
