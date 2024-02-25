import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart'; //
import 'package:seven_x_c/helpters/bonus_functions.dart';
import 'package:seven_x_c/helpters/functions.dart'
    show capitalize, removeDateBoulderToppedMap, removeRepeatFromBoulder, updateClimberToppedMap, updateDateBoulderToppedMap, updateGymDataToppes, updatePoints, updateRepeatBoulder;
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart'; //
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart'; //
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/barcharts_gradings.dart'; //

Map<String, dynamic>? updateUsersVotedForGrade(
    FirebaseCloudStorage boulderService,
    CloudBoulder boulder,
    CloudProfile currentProfile,
    String gradingSystem,
    int? gradeValue,
    int? difficultyLevel,
    String? gradeColorChoice) {
  if (gradingSystem == "coloured") {
    gradeValue = difficultyLevelToArrow(difficultyLevel!, gradeColorChoice!);
  } else {
    String arrow = getArrowFromNumberAndColor(gradeValue!, gradeColorChoice!);
    difficultyLevel = getdifficultyFromArrow(arrow);
  }
  boulder.climberTopped = updateClimberToppedMap(
    currentProfile: currentProfile,
    gradeNumberVoted: gradeValue,
    gradeColourVoted: gradeColorChoice,
    gradeArrowVoted: difficultyLevel,
    existingData: boulder.climberTopped,
  );
  boulderService.updateBoulder(
      boulderID: boulder.boulderID, climberTopped: boulder.climberTopped);
  return boulder.climberTopped;
}

void updateUserReapet(FirebaseCloudStorage userService,
    CloudProfile currentProfile, CloudBoulder boulder, int newRepeats) {
  int currentRepeats =
      boulder.climberTopped![currentProfile.userID]["repeats"];
  double orgBoulderPoints = 0.0;
  try {
  orgBoulderPoints =
      boulder.climberTopped![currentProfile.userID]["boulderPoints"];}
      on Error {orgBoulderPoints = 0.0;}
  double orgRepeatPoints =
      boulder.climberTopped![currentProfile.userID]["boulderPoints"] ?? 0;
  double repeatPoints;

  if (newRepeats > currentRepeats) {
    repeatPoints = calculateRepeatPoints(
        currentProfile, boulder, newRepeats, orgBoulderPoints);
double newRepeatPoints = orgRepeatPoints + repeatPoints;
userService.updateUser(
    currentProfile: currentProfile,
      boulderPoints: updatePoints(
          points: newRepeatPoints, existingData: currentProfile.boulderPoints),
      repeatBoulders: updateRepeatBoulder(currentUser: currentProfile, boulder: boulder, existingData: currentProfile.repeatBoulders),
      );
  } else {
    repeatPoints = -calculateRepeatPoints(
        currentProfile, boulder, newRepeats, orgBoulderPoints);
        double newRepeatPoints = orgRepeatPoints + repeatPoints;
        userService.updateUser(
    currentProfile: currentProfile,
      boulderPoints: updatePoints(
          points: newRepeatPoints, existingData: currentProfile.boulderPoints),
      repeatBoulders: removeRepeatFromBoulder(currentUser: currentProfile, boulder: boulder, existingData: currentProfile.repeatBoulders),
      );
  }

  
  

}

double calculateRepeatPoints(CloudProfile currentProfile, CloudBoulder boulder,
    int repeats, double orgBoulderPoints) {
  double repeatPoints = orgBoulderPoints *
      (repeats > 0 ? repeatsMultiplier - (repeats - 1) * repeatsDecrement : 0);
  if (repeatPoints > 0) {
    return repeatPoints;
  } else {
    return 0.0;
  }
}

int checkGrade(CloudProfile currentProfile, String boulderID, String style) {
  int maxValue = 0;
  DateTime currentDate = DateTime.now();
  String year = currentDate.year.toString();
  int comparedMonth = currentDate.month.toInt();
  // String currentMonth = comparedMonth.toString();
  int boulderGrade = 0;
  for (var month in currentProfile.dateBoulderTopped![year]!) {
    for (var week in currentProfile.dateBoulderTopped![year]![month]) {
      if (comparedMonth - month < 2) {
        for (var day in currentProfile.dateBoulderTopped![year]![month][week]) {
          for (var boulder in currentProfile.dateBoulderTopped![year]![month]
              [week][day]) {
            boulderGrade = currentProfile.dateBoulderTopped![year]![month][week]
                [day][boulder]["gradeSetter"];
            if (maxValue < boulderGrade) {
              maxValue = boulderGrade;
            }
          }
        }
      }
    }
  }
  return maxValue;
}

double calculateMultiplierFromGrade(
    int gradeNumber, int maxFlahsedGrade, int maxToppedGrade, bool flashed) {
  double baseMultiplier = 1.0;
  double newMultiplier;
  if (gradeNumber > maxFlahsedGrade && flashed) {
    newMultiplier = baseMultiplier + newFlashGradeMultiplier;
  }

  int gradeDiffer = gradeNumber - maxToppedGrade;

  if (gradeDiffer < 0) {
    newMultiplier = baseMultiplier + newToppedGradeMultiplier;
  } else if (gradeDiffer == 0) {
    newMultiplier = baseMultiplier;
  } else {
    newMultiplier = max(baseMultiplier - (decrementMultipler * gradeDiffer), 0);
  }

  return newMultiplier;
}

double calculateboulderPoints(CloudProfile currentProfile, CloudBoulder boulder,
    int repeats, bool flashed) {
  double boulderPoints = defaultBoulderPoints;
  int gradeNumber = boulder.gradeNumberSetter;
  int maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  int maxToppedGrade = currentProfile.maxToppedGrade;

  boulderPoints = boulderPoints *
      calculateMultiplierFromGrade(
        gradeNumber,
        maxFlahsedGrade,
        maxToppedGrade,
        flashed,
      );
  // Check if the user have points from this boulder
  if (boulder.climberTopped != null) {
    if (boulder.climberTopped!.containsKey((currentProfile.userID))) {
      if (boulder.climberTopped![currentProfile.userID]["topped"] != null) {
        boulderPoints = boulderPoints *
            (repeats > 0
                ? repeatsMultiplier - (repeats - 1) * repeatsDecrement
                : 0);
      }
    }
  }
  return boulderPoints;
}

void updateUserRemovedFlashed(
    FirebaseCloudStorage firebaseService,
    CloudProfile currentProfile,
    CloudBoulder boulder,
    CloudGymData currentGymData,
    bool flashed,
    bool topped,
    int attempts,
    int repeats) {
  int maxFlahsedGrade;
  double pointsForTop;
  double pointsForFlash;
  double boulderPoints;
  if (boulder.gradeNumberSetter == currentProfile.maxFlahsedGrade) {
    maxFlahsedGrade = checkGrade(currentProfile, boulder.boulderID, "flashed");
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  pointsForFlash =
      -boulder.climberTopped![currentProfile.userID]["boulderPoints"];

  pointsForTop =
      calculateboulderPoints(currentProfile, boulder, repeats, flashed);

  boulderPoints = pointsForTop - pointsForFlash;

  firebaseService.updateBoulder(
    boulderID: boulder.boulderID,
    climberTopped: updateClimberToppedMap(
        currentProfile: currentProfile,
        attempts: attempts,
        repeats: repeats,
        flashed: flashed,
        topped: topped,
        existingData: boulder.climberTopped),
  );

  firebaseService.updateUser(
      boulderPoints: updatePoints(
          points: boulderPoints, existingData: currentProfile.boulderPoints),
      currentProfile: currentProfile,
      maxFlahsedGrade: maxFlahsedGrade,
      dateBoulderTopped: updateDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          flashed: flashed,
          boulderPoints: boulderPoints,
          maxFlahsedGrade: maxFlahsedGrade,
          existingData: currentProfile.dateBoulderTopped));
        
    firebaseService.updateGymData(
      gymDataID: currentGymData.gymDataID,
      gymDataBouldersTopped: updateGymDataToppes(
          currentProfile: currentProfile,
          boulder: boulder,
          flashed: flashed,
          existingData: currentGymData.gymDataBouldersTopped));
}

void updateUserUndoTop(
  FirebaseCloudStorage firebaseService,
  CloudProfile currentProfile,
  CloudBoulder boulder,
  CloudGymData currentGymData,
) {
  int maxFlahsedGrade;
  int maxToppedGrade;
  double orgBoulderPoints;
  if (boulder.gradeNumberSetter == currentProfile.maxFlahsedGrade) {
    maxFlahsedGrade = checkGrade(currentProfile, boulder.boulderID, "flashed");
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  if (boulder.gradeNumberSetter == currentProfile.maxToppedGrade) {
    maxToppedGrade = checkGrade(currentProfile, boulder.boulderID, "topped");
  } else {
    maxToppedGrade = currentProfile.maxToppedGrade;
  }
  if (boulder.climberTopped != null) {
    if (boulder.climberTopped![currentProfile.userID] != null) {
      orgBoulderPoints = -(boulder.climberTopped![currentProfile.userID]
                  ["boulderPoints"] ??
              0.0) -
          (boulder.climberTopped![currentProfile.userID]["repeatPoints"] ??
              0.0);
    } else {
      orgBoulderPoints = defaultBoulderPoints;
    }
  } else {
    orgBoulderPoints = defaultBoulderPoints;
  }

  firebaseService.updateBoulder(
      boulderID: boulder.boulderID,
      climberTopped: updateClimberToppedMap(
          currentProfile: currentProfile,
          undoTop: true,
          existingData: boulder.climberTopped));

  firebaseService.updateUser(
      currentProfile: currentProfile,
      boulderPoints: updatePoints(
          points: orgBoulderPoints, existingData: currentProfile.boulderPoints),
      maxFlahsedGrade: maxFlahsedGrade,
      maxToppedGrade: maxToppedGrade,
      dateBoulderTopped: removeDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          maxFlahsedGrade: maxFlahsedGrade,
          maxToppedGrade: maxToppedGrade,
          existingData: currentProfile.dateBoulderTopped));

    firebaseService.updateGymData(
      gymDataID: currentGymData.gymDataID,
      gymDataBouldersTopped: updateGymDataToppes(
          currentProfile: currentProfile,
          boulder: boulder,
          flashed: false,
          existingData: currentGymData.gymDataBouldersTopped));
          
}

void updateUserTopped(
    FirebaseCloudStorage firebaseService,
    CloudProfile currentProfile,
    CloudBoulder boulder,
    CloudGymData currentGymData,
    bool flashed,
    bool topped,
    int attempts,
    int repeats) {
  double boulderPoints;
  int maxFlahsedGrade;
  int maxToppedGrade;

  if (currentProfile.maxFlahsedGrade < boulder.gradeNumberSetter) {
    maxFlahsedGrade = boulder.gradeNumberSetter;
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  if (currentProfile.maxToppedGrade < boulder.gradeNumberSetter) {
    maxToppedGrade = boulder.gradeNumberSetter;
  } else {
    maxToppedGrade = currentProfile.maxToppedGrade;
  }
  boulderPoints =
      calculateboulderPoints(currentProfile, boulder, repeats, flashed);

  firebaseService.updateBoulder(
      boulderID: boulder.boulderID,
      climberTopped: updateClimberToppedMap(
          currentProfile: currentProfile,
          attempts: attempts,
          repeats: repeats,
          flashed: flashed,
          topped: topped,
          toppedDate: DateTime.now(),
          boulderPoints: boulderPoints,
          existingData: boulder.climberTopped));

  firebaseService.updateUser(
      boulderPoints: updatePoints(
          points: boulderPoints, existingData: currentProfile.boulderPoints),
      currentProfile: currentProfile,
      maxFlahsedGrade: maxFlahsedGrade,
      maxToppedGrade: maxToppedGrade,
      dateBoulderTopped: updateDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          flashed: flashed,
          boulderPoints: boulderPoints,
          maxFlahsedGrade: maxFlahsedGrade,
          maxToppedGrade: maxToppedGrade,
          existingData: currentProfile.dateBoulderTopped));

  firebaseService.updateGymData(
      gymDataID: currentGymData.gymDataID,
      gymDataBouldersTopped: updateGymDataToppes(
          currentProfile: currentProfile,
          boulder: boulder,
          flashed: flashed,
          existingData: currentGymData.gymDataBouldersTopped));
}

SizedBox climberTopList(List<Map<String, dynamic>> toppersList) {
  return SizedBox(
    width: 200,
    height: 200,
    child: ListView.builder(
      itemCount: toppersList.length,
      itemBuilder: (context, index) {
        // Access climber information from the map
        String name = toppersList[index]['name'];
        bool flashed = toppersList[index]['flashed'];

        return Card(
          child: ListTile(
              title: Text(name, overflow: TextOverflow.ellipsis),
              subtitle: Text(flashed ? "Flashed" : "Topped")),
        );
      },
    ),
  );
}

Container gradingInnerCirleDrawing(double circleWidth, double circleHeight,
    CloudBoulder boulder, CloudSettings currentSettings, String? gradingShow) {
  return Container(
    width: circleWidth * 0.8,
    height: circleHeight * 0.8,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: boulder.hiddenGrade == true
            ? hiddenGradeColor
            : nameToColor(
                currentSettings.settingsHoldColour![boulder.gradeColour])),
    child: Center(
      child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: OutlineText(
            Text(
              capitalize(gradingShow!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: boulder.gradeColour != "black"
                    ? Colors.black
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: (gradingShow.length > 3 || gradingShow.contains('/'))
                    ? 10 // Font size for the text in the grading cirle. Changes size depending on text length
                    : 15,
              ),
            ),
            strokeWidth: 3,
            strokeColor: Colors.white54,
            overflow: TextOverflow.ellipsis,
          )),
    ),
  );
}

SizedBox barGraphColours(CloudBoulder boulder, CloudSettings currentSettings) {
  return SizedBox(
    width: 250,
    height: 100,
    child: BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: getGradeColourChartData(boulder, currentSettings),
      ),
    ),
  );
}

SizedBox barChartGradeNumbering(
    String gradingSystem, CloudSettings currentSettings, CloudBoulder boulder) {
  return SizedBox(
    width: 250,
    height: 100,
    child: BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) =>
                    getBottomTitlesNumberGrade(value, meta, gradingSystem),
              ),
            )),
        barGroups:
            getGradeNumberChartData(boulder, currentSettings, gradingSystem),
      ),
    ),
  );
}
