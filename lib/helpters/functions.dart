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
  };

  Map<String, dynamic> bouldersClimbedData = existingData ?? {};
  bouldersClimbedData[boulderID.toString()] = newData;

  return bouldersClimbedData;
}

Map<String, dynamic> updateClimbedBouldersMap(
    {required CloudBoulder boulder,
    required int attempts,
    required bool flashed,
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
    'flashed': flashed,
    "points": boulderPoints,
  };

  Map<String, dynamic> bouldersClimbedData = existingData ?? {};
  bouldersClimbedData[boulderID.toString()] = newData;

  return bouldersClimbedData;
}

// Map<String, dynamic> updateGradeNumberClimbers({
//   int? gradeNumberClimber,
//   Map<String, dynamic>? existingData,
// }) {
//   Map<String, dynamic> updatedData = existingData ?? {};
//   print(existingData);
//   if (updatedData.containsKey(gradeNumberClimber.toString())) {
//     // If the grade already exists, increment the vote count
//     updatedData[gradeNumberClimber.toString()] = (updatedData[gradeNumberClimber] ?? 0) + 1;
//   } else {
//     // If the grade doesn't exist, create a new entry with a vote count of 1
//     updatedData[gradeNumberClimber.toString()] = 1;
//   }

//   return updatedData;
// }

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
  String userID = "currentProfile.userID";

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
