import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';

 
double barRoundness = 2;
double barWidth = 10;

List<BarChartGroupData> getGradeColourChartData(CloudBoulder boulder, CloudSettings currentSettings) {
  Map<String, int> colorVotes = {};

  if (boulder.climberTopped != null && boulder.climberTopped!.isNotEmpty) {
    boulder.climberTopped!.forEach((userId, climbInfo) {
      if (climbInfo['gradeColour'] != "" && climbInfo['gradeColour']!= null ) {
      String gradeColour = climbInfo['gradeColour'];
      colorVotes[gradeColour] = (colorVotes[gradeColour] ?? 0) + 1;}
    });
  }

   List<String> colorNames = currentSettings.settingsGradeColour!.keys.toList();

 List<MapEntry<String, int>> sortedColorVotes = colorVotes.entries.toList()
    ..sort((a, b) {
      int minA = currentSettings.settingsGradeColour![a.key]!['min'];
      int minB = currentSettings.settingsGradeColour![b.key]!['min'];
      return minA.compareTo(minB);
    });
  
  List<BarChartGroupData> barGroups = sortedColorVotes.map((entry) {
    String gradeColour = entry.key;
    
    int voteCount = entry.value;
    Color color = nameToColor(currentSettings.settingsGradeColour![gradeColour]);

    return BarChartGroupData(
      x: colorNames.indexOf(gradeColour),
      barRods: [
        BarChartRodData(
          toY: voteCount.toDouble(),
          color: color,
          width: barWidth,
          borderRadius: BorderRadius.circular(barRoundness),
        ),
      ],
    );
  }).toList();

  return barGroups;
}

List<BarChartGroupData> getGradeNumberChartData(CloudBoulder boulder, CloudSettings currentSettings, String gradingSystem) {
  Map<int, int> gradeVotes = {};

  if (gradingSystem.toLowerCase() == "coloured") {
    gradingSystem = "french";
  }
  if (boulder.climberTopped != null && boulder.climberTopped!.isNotEmpty) {
    boulder.climberTopped!.forEach((userId, climbInfo) {
      if (climbInfo['gradeNumber'].runtimeType == int) {
        int gradeNumber = climbInfo['gradeNumber'];

        gradeVotes[gradeNumber] = (gradeVotes[gradeNumber] ?? 0) + 1;
      }
    });
  }

  Map<int, int> gradeMapNumber =
      getSortedGrades(gradeVotes, boulder.gradeNumberSetter);

  List<BarChartGroupData> barGroups = gradeMapNumber.entries.map((entry) {
    int gradeNumber = entry.key;
    int voteCount = entry.value;

    return BarChartGroupData(
      x: gradeNumber,
      barRods: [
        BarChartRodData(
          toY: voteCount.toDouble(),
          color: nameToColor(currentSettings.settingsGradeColour![boulder.gradeColour]),
          width: barWidth,
          borderRadius: BorderRadius.circular(barRoundness),
        ),
      ],
    );
  }).toList();

  return barGroups;
}

Map<int, int> getSortedGrades(Map<int, int> gradeVotes, int gradeNumberSetter) {
  // Get a list of sorted grade numbers
  List<int> sortedGrades;

  if (gradeVotes.isNotEmpty) {
    sortedGrades = gradeVotes.keys.toList()..sort();
  } else {
    // If gradeVotes is empty, use gradeNumberSetter as the only value
    sortedGrades = [gradeNumberSetter];
  }
  // If there are fewer than 7 grades, include additional grades as needed
  while (sortedGrades.length < 7) {
    if (sortedGrades.isEmpty) {
      // If the map is empty, add an arbitrary value with zero votes
      sortedGrades.add(0);
    } else {
      // Add one grade lower and/or one grade higher with zero votes
      int minGrade = sortedGrades.first;
      int maxGrade = sortedGrades.last;

      if (!sortedGrades.contains(minGrade - 1)) {
        if (minGrade > 0){
        sortedGrades.insert(0, minGrade - 1);}
      }

      if (!sortedGrades.contains(maxGrade + 1)) {
        sortedGrades.add(maxGrade + 1);
      }
    }
  }

  // Create a map with grades and their respective votes
  Map<int, int> result = {};

  // Assign zero votes to all grades initially
  result = {for (var grade in sortedGrades) grade: 0};

  // Update votes based on the provided gradeVotes
  gradeVotes.forEach((grade, votes) {
    result[grade] = votes;
  });

  return result;
}

Widget getBottomTitlesNumberGrade(
    double value, TitleMeta meta, String gradeSystem) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // Initialize text to a default value
  Widget text = const Text("", style: style);

  // Check if allGrading[value]?[gradeSystem] is not null
  if (allGrading[value] != null && allGrading[value]![gradeSystem] != null) {
    // Update text if the value is not null
    text = Text(allGrading[value]![gradeSystem]!, style: style);
  }

  // ignore: sort_child_properties_last
  return SideTitleWidget(child: text, axisSide: meta.axisSide);
}
