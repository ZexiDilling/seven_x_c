import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
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
    int? attempts,
    bool? flashed,
    int? repeats,
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
    "repeats": repeats,
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
  } else {
    return points;
  }
}

Map<String, dynamic> updateBoulderCompSet({
  required CloudComp currentComp,
  required CloudBoulder boulder,
  Map<String, dynamic>? existingData,
}) {
  String boulderID = boulder.boulderID;
  int? sequenceNumber;
  if (existingData != null) {
    sequenceNumber = existingData.length + 1;
  } else {
    sequenceNumber = 1;
  }
  Map<String, dynamic> newData = {
    "name": sequenceNumber,
    "holdColour": boulder.holdColour,
    "points": defaultCompBoulderPoints,
    "tops": 0,
    "topUsers": []
  };
  Map<String, dynamic> boulderComp = existingData ?? {};
  boulderComp[boulderID] = newData;
  return boulderComp;
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
    int? repeats,
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
    "repeats": repeats,
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

enum TimePeriod { week, month, semester, year, allTime }

DateTime calculateDateThreshold(TimePeriod timePeriod) {
  DateTime currentTime = DateTime.now();
  switch (timePeriod) {
    case TimePeriod.week:
      return currentTime.subtract(Duration(days: 7));
    case TimePeriod.month:
      return currentTime.subtract(Duration(days: 30));
    case TimePeriod.semester:
      // Adjust the duration as needed
      return currentTime.subtract(Duration(days: 180));
    case TimePeriod.year:
      return currentTime.subtract(Duration(days: 365));
    default:
      return DateTime(0); // Or handle the default case accordingly
  }
}

String getTimePeriodLabel(TimePeriod timePeriod) {
  switch (timePeriod) {
    case TimePeriod.week:
      return 'Week';
    case TimePeriod.month:
      return 'Month';
    case TimePeriod.semester:
      return 'Semester';
    case TimePeriod.year:
      return 'Year';
    case TimePeriod.allTime:
      return 'All Time';
  }
}
