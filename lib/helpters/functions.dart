import 'package:seven_x_c/constants/comp_const.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/challenges/cloud_challenges.dart';
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

Map<String, dynamic> removeClimbedBouldersMap(
    {required CloudBoulder boulder,
    required Map<String, dynamic>? existingData}) {
  String? boulderID = boulder.boulderID;
  Map<String, dynamic> bouldersClimbedData = existingData ?? {};
  bouldersClimbedData.remove(boulderID.toString());
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
    double? repeatPoints,
    Map<String, dynamic>? existingData}) {
  String? boulderID = boulder.boulderID;
  int? gradeNumberBoulder = boulder.gradeNumberSetter;

  Map<String, dynamic> newData = {
    "gradeNumber": gradeNumberBoulder,
    'attempts': attempts,
    "repeats": repeats,
    "topped": topped,
    'flashed': flashed,
    "boulderPoints": boulderPoints,
    "repeatPoints": repeatPoints,
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

Map<String, dynamic> updateCompProfile({
  required CloudComp currentComp,
  required CloudProfile currentProfile,
  required Map<String, dynamic> ranking,
  Map<String, dynamic>? existingData,
}) {
  String displayName = currentProfile.displayName;
  String userId = currentProfile.userID;
  String compName = currentComp.compName;
  String gender = currentComp.climbersComp![userId]["gender"];
  int rankingTotal = ranking["total"]![userId]["rank"];
  int rankingMale = ranking["male"]?[userId]?["rank"] ?? 0;
  int rankingFemale = ranking["female"]?[userId]?["rank"] ?? 0;
  double points = ranking["total"]![userId]["points"];
  int tops = ranking["total"]![userId]["tops"];

  // Create a new climber data
  Map<String, dynamic> newData = {
    "displayName": displayName,
    "gender": gender,
    "points": points,
    "tops": tops,
    "rankingTotal": rankingTotal,
    "rankingMale": rankingMale,
    "rankingFemale": rankingFemale,
  };

  Map<String, dynamic> climbersComp = existingData ?? {};
  climbersComp[compName] = newData;

  return climbersComp;
}

Map<String, dynamic> updateCompClimbers(
    {required CloudComp currentComp,
    required CloudProfile currentProfile,
    required String gender,
    Map<String, dynamic>? existingData}) {
  String displayName = currentProfile.displayName;
  String userID = currentProfile.userID;

  Map<String, dynamic> newData = {
    "displayName": displayName,
    "gender": gender,
  };
  Map<String, dynamic> climbersComp = existingData ?? {};
  climbersComp[userID] = newData;

  return climbersComp;
}

Map<String, dynamic> removeClimberToppedentry(
    {required CloudProfile currentProfile,
    required Map<String, dynamic>? existingData}) {
  String userID = currentProfile.userID;
  Map<String, dynamic> climberToppedData = existingData ?? {};
  climberToppedData.remove(userID);
  return climberToppedData;
}

Map<String, dynamic> updateClimberToppedMap(
    {required CloudProfile currentProfile,
    int? attempts,
    bool? flashed,
    bool? topped,
    int? repeats,
    int? gradeNumberVoted,
    String? gradeColourVoted,
    int? gradeArrowVoted,
    Map<String, dynamic>? existingData}) {
  String displayName = currentProfile.displayName;
  bool isAnonymous = currentProfile.isAnonymous;
  String userID = currentProfile.userID;
  if (existingData != null && existingData.isNotEmpty) {
    attempts ??= existingData[userID]['attempts'];
    repeats ??= existingData[userID]["repeats"];
    topped ??= existingData[userID]["topped"];
    flashed ??= existingData[userID]['flashed'];
    gradeNumberVoted ??= existingData[userID]["gradeNumber"];
    gradeColourVoted ??= existingData[userID]["gradeColour"];
    gradeArrowVoted ??= existingData[userID]["gradeArrow"];
  } else {
    existingData = {};
  }

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

  existingData[userID] = newData;
  return existingData;
}

enum TimePeriod { week, month, semester, year, allTime }

DateTime calculateDateThreshold(TimePeriod timePeriod) {
  DateTime currentTime = DateTime.now();

  switch (timePeriod) {
    case TimePeriod.week:
      // Find the last Monday of the current week
      DateTime lastMonday =
          currentTime.subtract(Duration(days: currentTime.weekday - 1));
      // Find the next Sunday
      return lastMonday;

    case TimePeriod.month:
      // Return the first day of the current month
      return DateTime(currentTime.year, currentTime.month, 1);

    case TimePeriod.semester:
      // Determine the semester start based on the current month
      if (currentTime.month >= 1 && currentTime.month <= 6) {
        // Semester starts in January
        return DateTime(currentTime.year, 1, 1);
      } else {
        // Semester starts in August
        return DateTime(currentTime.year, 8, 1);
      }

    case TimePeriod.year:
      // Return the first day of the current month 12 months ago
      return currentTime.subtract(
          const Duration(days: 30 * 12)); // Assuming 30 days in a month

    default:
      return DateTime(0); // Or handle the default case accordingly
  }
}

DateTime calculateEndDate(TimePeriod selectedTimePeriod, DateTime startDate) {
  switch (selectedTimePeriod) {
    case TimePeriod.week:
      // Find the next Sunday from the start date
      return startDate.add(Duration(days: (7 - startDate.weekday + 1) % 7));

    case TimePeriod.month:
      // Find the last day of the current month
      return DateTime(startDate.year, startDate.month + 1, 1)
          .subtract(const Duration(days: 1));

    case TimePeriod.semester:
      // Determine the end of the semester based on the current month
      if (startDate.month >= 1 && startDate.month <= 6) {
        // Semester ends in July
        return DateTime(startDate.year, 7, 31);
      } else {
        // Semester ends in December
        return DateTime(startDate.year, 12, 31);
      }

    default:
      // Default case (handle accordingly)
      return DateTime.now();
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

Map<String, dynamic> updateCompBoulderMap(
    {required CloudProfile currentProfile,
    required CloudBoulder boulder,
    required CloudComp currentComp,
    Map<String, dynamic>? existingData}) {
  String boulderName = boulder.boulderName!;
  String displayName = currentProfile.displayName;
  List climberToped = currentComp.bouldersComp![boulderName];

  if (climberToped.contains(displayName)) {
    climberToped.remove(displayName);
  } else {
    climberToped.add(displayName);
  }

  int tops = climberToped.length;
  double points = defaultCompBoulderPoints / tops;

  Map<String, dynamic> newData = {
    "points": points,
    "tops": tops,
  };

  Map<String, dynamic> climbersComp = existingData ?? {};
  climbersComp[boulderName] = newData;

  return climbersComp;
}

Map<String, dynamic> updateBoulderChallengeMap(
    {required CloudChallenge currentChallenge,
    required bool completed,
    CloudProfile? currentProfile,
    bool? removeUser,
    Map<String, dynamic>? existingData}) {
  String challengeID = currentChallenge.challengeID;
  List completedList;

  if (completed) {
    if (removeUser!) {
      completedList = existingData!["completed"].remove(currentProfile);
    } else {
      completedList = existingData!["completed"].add(currentProfile);
    }
  } else {
    completedList = [];
  }

  Map<String, dynamic> newData = {
    "name": currentChallenge.challengeName,
    "difficulty": currentChallenge.challengeDifficulty,
    "description": currentChallenge.challengeDescription,
    "type": currentChallenge.challengeType,
    "gotCounter": currentChallenge.challengeCounter,
    "runningCount": currentChallenge.challengeCounterRunning,
    "points": currentChallenge.challengeOwnPoints,
    "completed": completedList,
  };

  Map<String, dynamic> boulderChallenges = existingData ?? {};
  boulderChallenges[challengeID] = newData;

  return boulderChallenges;
}

List updateListOfRandomWinners(
    {required CloudComp currentComp,
    required String userDisplayName,
    List? existingData}) {
  List randomWinners = existingData ?? [];
  randomWinners.add(userDisplayName);
  return randomWinners;
}

List updateChallengeBoulderList(
    {required CloudBoulder boulder, List? existingData}) {
  List randomWinners = existingData ?? [];
  randomWinners.add(boulder.boulderID);
  return randomWinners;
}

Map<String, dynamic> updateSettingsHoldColours(
    {required String colourName,
    required int alpha,
    required int red,
    required int green,
    required int blue,
    String? oldColourName,
    Map<String, dynamic>? existingData}) {
  Map<String, dynamic> newData = {
    "aplha": alpha,
    "red": red,
    "green": green,
    "blue": blue,
  };

  Map<String, dynamic> colourSettings = existingData ?? {};
  if (oldColourName != null) {
    colourSettings.remove(oldColourName);
  }
  colourSettings[colourName] = newData;

  return colourSettings;
}

Map<String, dynamic> updateSettingsGradeColours(
    {required String colourName,
    required int alpha,
    required int red,
    required int green,
    required int blue,
    required int minGrade,
    required int maxGrade,
    String? oldColourName,
    Map<String, dynamic>? existingData}) {
  Map<String, dynamic> newData = {
    "aplha": alpha,
    "red": red,
    "green": green,
    "blue": blue,
    "min": minGrade,
    "max": maxGrade,
  };

  Map<String, dynamic> colourSettings = existingData ?? {};
  if (oldColourName != null) {
    colourSettings.remove(oldColourName);
  }
  colourSettings[colourName] = newData;

  return colourSettings;
}

Map<String, dynamic> deletSubSettings(
    {required String oldColourName,
    required Map<String, dynamic>? existingData}) {
  Map<String, dynamic> colourSettings = existingData ?? {};
  colourSettings.remove(oldColourName);
  return colourSettings;
}

int? tryParseInt(String? value) {
  if (value == null) {
    return null;
  }

  try {
    return int.parse(value);
  } catch (e) {
    // Handle the case where the string is not a valid integer
    return null;
  }
}
