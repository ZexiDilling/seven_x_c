import 'package:cloud_firestore/cloud_firestore.dart';
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

Map<String, dynamic> removeDateBoulderToppedMap(
    {required CloudBoulder boulder,
    required userID,
    required int maxFlahsedGrade,
    required int maxToppedGrade,
    required Map<String, dynamic>? existingData}) {
  String boulderID = boulder.boulderID;
  Map<String, dynamic> dateBoulder = existingData ?? {};

  DateTime boulderDate = boulder.climberTopped![userID]["dateTopped"];

  String boulderYear = boulderDate.year.toString();
  String boulderMonth = boulderDate.month.toString();
  String boulderWeek = getIsoWeekNumber(boulderDate).toString();
  String boulderDay = boulderDate.day.toString();

  dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
      .remove(boulderID.toString());

  dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
      ["maxFlahsedGrade"] = maxFlahsedGrade;
  dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
      ["maxToppedGrade"] = maxToppedGrade;

  return dateBoulder;
}

Map<String, dynamic> updateDateBoulderToppedMap({
  required CloudBoulder boulder,
  required String userID,
  required bool flashed,
  required boulderPoints,
  int? maxFlahsedGrade,
  int? maxToppedGrade,
  Map<String, dynamic>? existingData,
}) {
  String gradeColour = boulder.gradeColour;
  int gradeNumberSetter = boulder.gradeNumberSetter;

  DateTime boulderDate = boulder.climberTopped![userID]["toppedDate"];

  String boulderYear = boulderDate.year.toString();
  String boulderMonth = boulderDate.month.toString();
  String boulderWeek = getIsoWeekNumber(boulderDate).toString();
  String boulderDay = boulderDate.day.toString();

  Map<String, dynamic> newData = {
    "gradeColour": gradeColour,
    "gradeNumber": gradeNumberSetter,
    "flashed": flashed,
    "points": boulderPoints,
  };

  Map<String, dynamic> dateBoulder = existingData ?? {};

  dateBoulder[boulderYear] ??= {};
  dateBoulder[boulderYear][boulderMonth] ??= {};
  dateBoulder[boulderYear][boulderMonth][boulderWeek] ??= {};
  dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay] ??= {};
  dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
      [boulder.boulderID] = newData;

  if (maxFlahsedGrade != null) {
    if (dateBoulder[boulderYear][boulderMonth][boulderWeek]
            ["maxFlahsedGrade"] !=
        null) {
      if (maxFlahsedGrade >
          dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
              ["maxFlahsedGrade"]) {
        dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
            ["maxFlahsedGrade"] = maxFlahsedGrade;
      }
    } else {
      dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
          ["maxFlahsedGrade"] = maxFlahsedGrade;
    }
  }
  if (maxToppedGrade != null) {
    if (dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
            ["maxToppedGrade"] !=
        null) {
      if (maxToppedGrade >
          dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
              ["maxToppedGrade"]) {
        dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
            ["maxToppedGrade"] = maxToppedGrade;
      }
    } else {
      dateBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
          ["maxToppedGrade"] = maxToppedGrade;
    }
  }

  return dateBoulder;
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
    {required CloudProfile setterProfile,
    required String boulderId,
    CloudBoulder? newBoulder,
    required double setterPoints,
    Map<String, dynamic>? existingData}) {
  String boulderYear = "";
  String boulderMonth = "";
  String boulderWeek = "";
  String boulderDay = "";
  String boulderID = "";

  var holdColour;
  var gradeColour;
  var gradeNumberSetter;
  var gradeDifficulty;

  if (newBoulder != null) {
    Timestamp boulderTimeStamp = newBoulder.setDateBoulder;
    DateTime boulderDate = boulderTimeStamp.toDate();
    boulderYear = boulderDate.year.toString();
    boulderMonth = boulderDate.month.toString();
    boulderWeek = getIsoWeekNumber(boulderDate).toString();
    boulderDay = boulderDate.day.toString();

    holdColour = newBoulder.holdColour;
    gradeColour = newBoulder.gradeColour;

    gradeNumberSetter = newBoulder.gradeNumberSetter;
    gradeDifficulty = newBoulder.gradeDifficulty;
    boulderID = newBoulder.boulderID;
  } else {
    DateTime boulderDate = setterProfile.setBoulders![boulderId]["setDateBoulder"];
    boulderYear = boulderDate.year.toString();
    boulderMonth = boulderDate.month.toString();
    boulderWeek = getIsoWeekNumber(boulderDate).toString();
    boulderDay = boulderDate.day.toString();
    boulderID = boulderId;
    holdColour = setterProfile.setBoulders![boulderId]["holdColour"];
    gradeColour = setterProfile.setBoulders![boulderId]["gradeColour"];
    gradeNumberSetter =
        setterProfile.setBoulders![boulderId]["gradeNumberSetter"];

    gradeDifficulty =
        setterProfile.setBoulders![boulderId]["gradeDifficulty"] ?? 1;
  }

  Map<String, dynamic> newData = {
    "holdColour": holdColour,
    "gradeColour": gradeColour,
    "gradeNumberSetter": gradeNumberSetter,
    "gradeDifficulty": gradeDifficulty,
    "points": setterPoints
  };

  Map<String, dynamic> setBoulder = existingData ?? {};

  setBoulder[boulderYear] ??= {};
  setBoulder[boulderYear][boulderMonth] ??= {};
  setBoulder[boulderYear][boulderMonth][boulderWeek] ??= {};
  setBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay] ??= {};
  setBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay][boulderID] =
      newData;

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
    double? boulderPoints,
    DateTime? toppedDate,
    Map<String, dynamic>? existingData}) {
  String displayName = currentProfile.displayName;
  bool isAnonymous = currentProfile.isAnonymous;
  String userID = currentProfile.userID;

  if (existingData != null && existingData.isNotEmpty) {
    if (existingData[userID] != null) {
      attempts ??= existingData[userID]['attempts'];
      repeats ??= existingData[userID]["repeats"];
      topped ??= existingData[userID]["topped"];
      flashed ??= existingData[userID]['flashed'];
      toppedDate ??= existingData[userID]["toppedDate"];
      gradeNumberVoted ??= existingData[userID]["gradeNumber"];
      gradeColourVoted ??= existingData[userID]["gradeColour"];
      gradeArrowVoted ??= existingData[userID]["gradeArrow"];
    }
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
    "boulderPoints": boulderPoints,
    "toppedDate": toppedDate,
  };

  existingData[userID] = newData;
  return existingData;
}

enum TimePeriod { week, month, semester, year }

// Map enum values to display strings
final Map<TimePeriod, String> timePeriodStrings = {
  TimePeriod.week: 'Week',
  TimePeriod.month: 'Month',
  TimePeriod.semester: 'Semester',
  TimePeriod.year: 'Year',
};

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
      return startDate.add(const Duration(days: 7));

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
    required bool removeUser,
    CloudProfile? currentProfile,
    Map<String, dynamic>? existingData}) {
  String challengeID = currentChallenge.challengeID;
  List completedList;

  if (existingData == null) {
    completedList = [];
  } else {
    completedList = existingData["completed"];
  }

  if (completed) {
    if (removeUser) {
      completedList.remove(currentProfile?.displayName);
    } else {
      completedList.add(currentProfile?.displayName);
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

String capitalize(String s) {
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

int getIsoWeekNumber(DateTime date) {
  DateTime january4th = DateTime(date.year, 1, 4);
  int daysSinceJanuary4th = date.difference(january4th).inDays;
  int weekNumber = ((daysSinceJanuary4th + january4th.weekday + 6) / 7).floor();

  if (weekNumber == 0) {
    // If the date is in the last week of the previous year
    weekNumber = getIsoWeekNumber(DateTime(date.year - 1, 12, 31));
  }

  return weekNumber;
}

DateTime getStartDateOfWeek(int year, int weekNumber) {
  DateTime january4th = DateTime(year, 1, 4);
  int daysToAdd = (weekNumber - 1) * 7 - january4th.weekday + 1;
  return january4th.add(Duration(days: daysToAdd));
}

DateTime getEndDateOfWeek(int year, int weekNumber) {
  DateTime startDate = getStartDateOfWeek(year, weekNumber);
  return startDate.add(const Duration(days: 6));
}
