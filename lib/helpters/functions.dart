// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/constants/comp_const.dart';
import 'package:seven_x_c/helpters/time_calculations.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_outdorr_boulder.dart';
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

  // Timestamp boulderTimeStamp = boulder.climberTopped![userID]["toppedDate"];
  // DateTime boulderDate = boulderTimeStamp.toDate();

  DateTime boulderDate;
  if (boulder.climberTopped != null && boulder.climberTopped![userID] != null) {
    try {
      boulderDate = boulder.climberTopped![userID]["toppedDate"];
    } on Error {
      boulderDate = boulder.climberTopped![userID]["toppedDate"].toDate();
    }
  } else {
    boulderDate = DateTime.now();
  }
  String boulderYear = boulderDate.year.toString();
  String boulderMonth = boulderDate.month.toString();
  String boulderWeek = grabIsoWeekNumber(boulderDate).toString();
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

  // Timestamp boulderTimeStamp = boulder.climberTopped![userID]["toppedDate"];
  // DateTime boulderDate = boulderTimeStamp.toDate();
  DateTime boulderDate;
  if (boulder.climberTopped != null) {
    try {
      boulderDate = boulder.climberTopped![userID]["toppedDate"];
    } on Error {
      boulderDate = boulder.climberTopped![userID]["toppedDate"].toDate();
    }
  } else {
    boulderDate = DateTime.now();
  }

  String boulderYear = boulderDate.year.toString();
  String boulderMonth = boulderDate.month.toString();
  String boulderWeek = grabIsoWeekNumber(boulderDate).toString();
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

Map<String, dynamic> updateRepeatBoulder({
  required CloudProfile currentUser,
  required CloudBoulder boulder,
  Map<String, dynamic>? existingData,
}) {
  String indicator = "${currentUser.userID}_${boulder.boulderID}";
  DateTime tempDate = DateTime.now();

  String tempYear = tempDate.year.toString();
  String tempMonth = tempDate.month.toString();
  String tempWeek = grabIsoWeekNumber(tempDate).toString();
  String tempDay = tempDate.day.toString();
  int repeats = 0;
  if (existingData != null) {
    DateTime boulderDate = DateTime.now();
    String boulderYear = boulderDate.year.toString();
    String boulderMonth = boulderDate.month.toString();
    String boulderWeek = grabIsoWeekNumber(boulderDate).toString();
    String boulderDay = boulderDate.day.toString();

    if (existingData.containsKey(boulderYear) &&
        existingData[boulderYear]!.containsKey(boulderMonth) &&
        existingData[boulderYear]![boulderMonth]!.containsKey(boulderWeek) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]!
            .containsKey(boulderDay) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]![boulderDay]!
            .containsKey(indicator)) {
      repeats = existingData[boulderYear]![boulderMonth]![boulderWeek]![
          boulderDay]![indicator]["repeats"];
    }
  }

  repeats++;

  Map<String, dynamic> newData = {
    "gradeColour": boulder.gradeColour,
    "gradeNumber": boulder.gradeNumberSetter,
    "holdColour": boulder.holdColour,
    "repeats": repeats
  };

  Map<String, dynamic> dateClimbedTopped = existingData ?? {};

  dateClimbedTopped[tempYear] ??= {};
  dateClimbedTopped[tempYear][tempMonth] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek][tempDay] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek][tempDay][indicator] =
      newData;

  return dateClimbedTopped;
}

Map<String, dynamic> removeRepeatFromBoulder({
  required CloudProfile currentUser,
  required CloudBoulder boulder,
  Map<String, dynamic>? existingData,
}) {
  String indicator = "${currentUser.userID}_${boulder.boulderID}";
  DateTime tempDate = DateTime.now();

  String boulderYear = tempDate.year.toString();
  String boulderMonth = tempDate.month.toString();
  String boulderWeek = grabIsoWeekNumber(tempDate).toString();
  String boulderDay = tempDate.day.toString();
  int repeats = 0;
  if (existingData != null) {
    DateTime boulderDate = DateTime.now();
    boulderYear = boulderDate.year.toString();
    boulderMonth = boulderDate.month.toString();
    boulderWeek = grabIsoWeekNumber(boulderDate).toString();
    boulderDay = boulderDate.day.toString();

    if (existingData.containsKey(boulderYear) &&
        existingData[boulderYear]!.containsKey(boulderMonth) &&
        existingData[boulderYear]![boulderMonth]!.containsKey(boulderWeek) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]!
            .containsKey(boulderDay) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]![boulderDay]!
            .containsKey(indicator)) {
      repeats = existingData[boulderYear]![boulderMonth]![boulderWeek]![
          boulderDay]![indicator]["repeats"];
    } else {
      DateTime boulderDate;
      List<Map<String, String>> indicatorDates = [];
      if (boulder.climberTopped != null) {
        try {
          boulderDate =
              boulder.climberTopped![currentUser.userID]["toppedDate"];
        } on Error {
          boulderDate =
              boulder.climberTopped![currentUser.userID]["toppedDate"].toDate();
        }
      } else {
        boulderDate = DateTime.now();
      }

      DateTime currentDate = DateTime.now();

      while (boulderDate.isBefore(currentDate)) {
        String year = boulderDate.year.toString();
        String month = boulderDate.month.toString();
        String week = grabIsoWeekNumber(boulderDate).toString();
        String day = boulderDate.day.toString();

        if (existingData.containsKey(year) &&
            existingData[year]!.containsKey(month) &&
            existingData[year]![month]!.containsKey(week) &&
            existingData[year]![month]![week]!.containsKey(day) &&
            existingData[year]![month]![week]![day]!.containsKey(indicator)) {
          Map<String, String> dateInfo = {
            'year': year,
            'month': month,
            'week': week,
            'day': day,
            "repeats": existingData[year]![month]![week]![day][indicator]
                    ["repeats"]
                .toString(),
          };
          indicatorDates.add(dateInfo);
        }

        boulderDate = boulderDate.add(const Duration(days: 1));
      }

      // Sort indicatorDates based on the dates in descending order
      indicatorDates.sort((a, b) {
        final dateA = DateTime(int.parse(a['year']!), int.parse(a['month']!),
            int.parse(a['day']!));
        final dateB = DateTime(int.parse(b['year']!), int.parse(b['month']!),
            int.parse(b['day']!));
        return dateB.compareTo(dateA);
      });

      // Get the latest date from the sorted list
      if (indicatorDates.isNotEmpty) {
        Map<String, String> latestDate = indicatorDates.first;
        boulderYear = latestDate['year']!;
        boulderMonth = latestDate['month']!;
        boulderWeek = latestDate['week']!;
        boulderDay = latestDate['day']!;
        repeats = int.parse(latestDate["repeats"]!);
        // Now you have the latest date information (year, month, week, day) in the variables
        // latestYear, latestMonth, latestWeek, and latestDay.
      }
    }
  }

  repeats--;

  Map<String, dynamic> newData = {
    "gradeColour": boulder.gradeColour,
    "gradeNumber": boulder.gradeNumberSetter,
    "holdColour": boulder.holdColour,
    "repeats": repeats
  };

  Map<String, dynamic> dateClimbedTopped = existingData ?? {};

  dateClimbedTopped[boulderYear] ??= {};
  dateClimbedTopped[boulderYear][boulderMonth] ??= {};
  dateClimbedTopped[boulderYear][boulderMonth][boulderWeek] ??= {};
  dateClimbedTopped[boulderYear][boulderMonth][boulderWeek][boulderDay] ??= {};
  dateClimbedTopped[boulderYear][boulderMonth][boulderWeek][boulderDay]
      [boulder.boulderID] = newData;

  return dateClimbedTopped;
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

Map<String, dynamic> updateOutdoorDataBoulders(
    {required String boulderId,
    CloudOutdoorBoulder? newOutdoorBoulder,
    Map<String, dynamic>? existingData}) {
  var initRating;
  var setter;
  var gradeColour;
  var gradeNumberSetter;
  var gradeDifficulty;
  var subLocation;
  var tags;
  var climberRating;
  var gradeNumberClimber;
  var cordX;
  var cordY;

  if (newOutdoorBoulder != null) {
    initRating = newOutdoorBoulder.outdoorRating;
    climberRating = newOutdoorBoulder.outdoorRatingClimbers;
    gradeColour = newOutdoorBoulder.outdoorGradeColour;
    gradeNumberSetter = newOutdoorBoulder.outdoorGradeNumberSetter;
    gradeNumberClimber = newOutdoorBoulder.outdoorGradeNumberClimbers;
    gradeDifficulty = newOutdoorBoulder.outdoorGradeDifficulty;
    subLocation = newOutdoorBoulder.outdoorBoulderSections;
    setter = newOutdoorBoulder.outdoorSetter;
    tags = newOutdoorBoulder.outdoorTags;
    cordX = newOutdoorBoulder.outdoorCordX;
    cordY = newOutdoorBoulder.outdoorCordY;
  }

  Map<String, dynamic> newData = {
    "initRating": initRating,
    "climberRating": climberRating,
    "gradeNumberSetter": gradeNumberSetter,
    "gradeNumberClimber": gradeNumberClimber,
    "gradeColour": gradeColour,
    "gradeDifficulty": gradeDifficulty,
    "location": subLocation,
    "setter": setter,
    "tags": tags,
    "cordX": cordX,
    "cordY": cordY,
  };

  Map<String, dynamic> setBoulder = existingData ?? {};

  setBoulder[boulderId] = newData;

  return setBoulder;
}

Map<String, dynamic> removeDateBoulderSet(
    {required CloudProfile setterProfile,
    CloudBoulder? boulder,
    Map<String, dynamic>? existingData}) {
  Map<String, dynamic> setBoulder = existingData ?? {};
  String boulderYear = "";
  String boulderMonth = "";
  String boulderWeek = "";
  String boulderDay = "";

  String boulderID = boulder!.boulderID;

  DateTime boulderDate =
      setterProfile.setBoulders![boulderID]["setDateBoulder"];
  boulderYear = boulderDate.year.toString();
  boulderMonth = boulderDate.month.toString();
  boulderWeek = grabIsoWeekNumber(boulderDate).toString();
  boulderDay = boulderDate.day.toString();

  setterProfile.setBoulders![boulderID]["gradeNumberSetter"];

  setterProfile.setBoulders![boulderID]["gradeDifficulty"] ?? 1;

  setBoulder[boulderYear][boulderMonth][boulderWeek][boulderDay]
      .remove(boulderID.toString());

  return setBoulder;
}

Map<String, dynamic> updateDateBoulderSet(
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
    boulderWeek = grabIsoWeekNumber(boulderDate).toString();
    boulderDay = boulderDate.day.toString();

    holdColour = newBoulder.holdColour;
    gradeColour = newBoulder.gradeColour;

    gradeNumberSetter = newBoulder.gradeNumberSetter;
    gradeDifficulty = newBoulder.gradeDifficulty;
    boulderID = newBoulder.boulderID;
  } else {
    DateTime boulderDate =
        setterProfile.setBoulders![boulderId]["setDateBoulder"];
    boulderYear = boulderDate.year.toString();
    boulderMonth = boulderDate.month.toString();
    boulderWeek = grabIsoWeekNumber(boulderDate).toString();
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
    bool? undoTop,
    Map<String, dynamic>? existingData}) {
  String displayName = currentProfile.displayName;
  bool isAnonymous = currentProfile.isAnonymous;
  String userID = currentProfile.userID;
  if (undoTop != null) {
    attempts = 0;
    repeats = 0;
    topped = false;
    flashed = false;
    boulderPoints = 0;
    gradeNumberVoted ??= existingData![userID]["gradeNumber"];
    gradeColourVoted ??= existingData![userID]["gradeColour"];
    gradeArrowVoted ??= existingData![userID]["gradeArrow"];
    try {
      toppedDate ??= existingData![userID]["toppedDate"];
    } on Error {
      toppedDate ??= existingData![userID]["toppedDate"].toDate();
    }
  } else {
    if (existingData != null && existingData.isNotEmpty) {
      if (existingData[userID] != null) {
        attempts ??= existingData[userID]['attempts'];
        repeats ??= existingData[userID]["repeats"];
        topped ??= existingData[userID]["topped"];
        flashed ??= existingData[userID]['flashed'];
        try {
          toppedDate ??= existingData[userID]["toppedDate"];
        } on Error {
          toppedDate ??= existingData[userID]["toppedDate"].toDate();
        }

        gradeNumberVoted ??= existingData[userID]["gradeNumber"];
        gradeColourVoted ??= existingData[userID]["gradeColour"];
        gradeArrowVoted ??= existingData[userID]["gradeArrow"];
        boulderPoints ??= existingData[userID]["boulderPoints"];
      }
    } else {
      existingData = {};
    }
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

  existingData![userID] = newData;
  return existingData;
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

Map<String, dynamic> updateGymDataBoulders(
    {required String setterID,
    required CloudBoulder newBoulder,
    Map<String, dynamic>? existingData}) {
  String boulderYear = "";
  String boulderMonth = "";
  String boulderWeek = "";
  String boulderDay = "";
  String boulderID = "";
  bool joker;

  var holdColour;
  var gradeColour;
  var gradeNumberSetter;
  var gradeDifficulty;
  

  Timestamp boulderTimeStamp = newBoulder.setDateBoulder;
  DateTime boulderDate = boulderTimeStamp.toDate();
  boulderYear = boulderDate.year.toString();
  boulderMonth = boulderDate.month.toString();
  boulderWeek = grabIsoWeekNumber(boulderDate).toString();
  boulderDay = boulderDate.day.toString();
  holdColour = newBoulder.holdColour;
  gradeColour = newBoulder.gradeColour;
  gradeNumberSetter = newBoulder.gradeNumberSetter;
  gradeDifficulty = newBoulder.gradeDifficulty;
  boulderID = newBoulder.boulderID;
  joker = newBoulder.hiddenGrade;

  Map<String, dynamic> newData = {
    "holdColour": holdColour,
    "gradeColour": gradeColour,
    "gradeNumberSetter": gradeNumberSetter,
    "gradeDifficulty": gradeDifficulty,
    "setter": setterID,
    "joker": joker
  };

  Map<String, dynamic> gymDataBoulders = existingData ?? {};

  gymDataBoulders[boulderYear] ??= {};
  gymDataBoulders[boulderYear][boulderMonth] ??= {};
  gymDataBoulders[boulderYear][boulderMonth][boulderWeek] ??= {};
  gymDataBoulders[boulderYear][boulderMonth][boulderWeek][boulderDay] ??= {};
  gymDataBoulders[boulderYear][boulderMonth][boulderWeek][boulderDay]
      [boulderID] = newData;

  return gymDataBoulders;
}

Map<String, dynamic>? removeBoulderFromGymDataBoulders({
  required String boulderID,
  DateTime? removeDate,
  Map<String, dynamic>? existingData,
}) {
  if (existingData != null) {
    DateTime boulderDate;
    if (removeDate == null) {
      boulderDate = DateTime.now();
    } else {
      boulderDate = removeDate;
    }
    String boulderYear = boulderDate.year.toString();
    String boulderMonth = boulderDate.month.toString();
    String boulderWeek = grabIsoWeekNumber(boulderDate).toString();
    String boulderDay = boulderDate.day.toString();

    if (existingData.containsKey(boulderYear) &&
        existingData[boulderYear]!.containsKey(boulderMonth) &&
        existingData[boulderYear]![boulderMonth]!.containsKey(boulderWeek) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]!
            .containsKey(boulderDay) &&
        existingData[boulderYear]![boulderMonth]![boulderWeek]![boulderDay]!
            .containsKey(boulderID)) {
      existingData[boulderYear]![boulderMonth]![boulderWeek]![boulderDay]!
          .remove(boulderID);
    }
  }

  return existingData;
}

Map<String, dynamic> updateGymDataToppes(
    {required CloudProfile currentProfile,
    required CloudBoulder boulder,
    required bool flashed,
    Map<String, dynamic>? existingData}) {
  String userID = currentProfile.userID;
  DateTime tempDate;

  if (boulder.climberTopped != null) {
    try {
      tempDate = boulder.climberTopped![userID]["toppedDate"];
    } on Error {
      tempDate = boulder.climberTopped![userID]["toppedDate"].toDate();
    }
  } else {
    tempDate = DateTime.now();
  }

  String tempYear = tempDate.year.toString();
  String tempMonth = tempDate.month.toString();
  String tempWeek = grabIsoWeekNumber(tempDate).toString();
  String tempDay = tempDate.day.toString();

  Map<String, dynamic> newData = {
    "gradeColour": boulder.gradeColour,
    "gradeNumber": boulder.gradeNumberSetter,
    "flashed": flashed,
  };

  Map<String, dynamic> dateClimbedTopped = existingData ?? {};

  dateClimbedTopped[tempYear] ??= {};
  dateClimbedTopped[tempYear][tempMonth] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek][tempDay] ??= {};
  dateClimbedTopped[tempYear][tempMonth][tempWeek][tempDay][boulder.boulderID] =
      newData;

  return dateClimbedTopped;
}
