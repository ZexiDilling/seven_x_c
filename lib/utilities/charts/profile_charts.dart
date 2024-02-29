import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart' show allGrading;
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import '../../helpters/time_calculations.dart' show TimePeriod;
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_barchart.dart';
import 'package:seven_x_c/utilities/charts/profile_line_chart_max.dart';
import 'package:seven_x_c/utilities/charts/profile_setting_piechart.dart';
import 'package:seven_x_c/views/profile/point_gather.dart';

class LineChartGraph extends StatelessWidget {
  const LineChartGraph({
    super.key,
    required this.currentProfile,
    required this.currentSettings,
    required this.chartSelection,
    required this.graphData,
    required this.selectedTimePeriod,
    required this.gradingSystem,
    required this.gradeNumberToColour,
    required this.setterViewGrade,
    required this.gradeVsColour,
    required this.colourVsValue,
    required this.selectedSetter,
  });
  final CloudProfile currentProfile;
  final CloudSettings currentSettings;
  final String chartSelection;
  final TimePeriod selectedTimePeriod;
  final PointsData graphData;
  final String gradingSystem;
  final Map<int, String> gradeNumberToColour;
  final bool setterViewGrade;
  final bool gradeVsColour;
  final bool colourVsValue;
  final String selectedSetter;

  @override
  Widget build(BuildContext context) {
    List<String> gradeColorOrder = [];
    if (gradeNumberToColour.length > 1) {
      gradeColorOrder = gradeNumberToColour.values.toList();
    } else {
      gradeColorOrder = [
        'green',
        'yellow',
        'blue',
        'purple',
        'Rrd',
        'black',
        "silver"
      ];
    }

    List<String> holdColourOrder =
        currentSettings.settingsHoldColour!.keys.toList();
    switch (chartSelection) {
      case "maxGrade":
        List<FlSpot> climbedEntries =
            graphData.boulderClimbedMaxClimbed.entries.map((entry) {
          double xValue;
          xValue = double.parse(entry.key);
          return FlSpot(
            xValue,
            entry.value.toDouble().clamp(0, 27),
          );
        }).toList();

        double maxYValue = climbedEntries.isNotEmpty
            ? climbedEntries
                .map((entry) => entry.y)
                .reduce((a, b) => a > b ? a : b)
            : 10.0;

        double maxY = (maxYValue + 2).clamp(0, 27);

        double minY = (maxY - 6).clamp(0, maxY);
        return LineChart(
          maxGradeChart(
              graphData.boulderClimbedMaxClimbed,
              graphData.boulderClimbedMaxFlashed,
              minY,
              maxY,
              gradingSystem,
              selectedTimePeriod,
              chartSelection),
          duration: const Duration(milliseconds: 250),
        );
      case "climbs":
        List<int> graphList =
            graphData.boulderClimbedAmount.entries.map((entry) {
          final int yValue = (entry.value).toInt();
          return yValue;
        }).toList();
        double maxValue = 0;
        if (graphList.isNotEmpty) {
          maxValue = (graphList.reduce(max)).toDouble();
        } else {
          maxValue = 10;
        }

        Map<String, List<double>> listColorsClimbed = {};

        for (String date in graphData.boulderClimbedColours.keys) {
          for (var colour in gradeColorOrder) {
            double colourCount =
                graphData.boulderClimbedColours[date]?[colour]?.toDouble() ??
                    0.0;
            if (listColorsClimbed[date] == null) {
              listColorsClimbed[date] = [colourCount];
            } else {
              listColorsClimbed[date]!
                  .add(colourCount); // Use add to append to the list
            }
          }
        }

        return BarChart(
          boulderBarChart(
              currentSettings,
              listColorsClimbed,
              maxValue,
              gradeColorOrder,
              selectedTimePeriod,
              chartSelection,
              setterViewGrade),
        );
      case "SetterData":
        Map<String, Map<String, int>> colorData = {};
        List<String> colorOrder = [];
        if (setterViewGrade) {
          colorData = graphData.boulderSetGradeColours;
          colorOrder = gradeColorOrder;
        } else {
          colorData = graphData.boulderSetHoldColours;
          colorOrder = holdColourOrder;
        }
        Map<String, List<double>> listColorsClimbed = {};
        for (var date in colorData.keys) {
          for (var colour in colorOrder) {
            double colourCount = colorData[date]?[colour]?.toDouble() ?? 0.0;

            if (listColorsClimbed[date] == null) {
              listColorsClimbed[date] = [colourCount];
            } else {
              listColorsClimbed[date]!.add(colourCount);
            }
          }
        }

        List<int> graphList = graphData.boulderSetAmount.entries.map((entry) {
          final int yValue = (entry.value).toInt();
          return yValue;
        }).toList();
        double maxValue = 0;
        if (graphList.isNotEmpty) {
          maxValue = (graphList.reduce(max)).toDouble();
        } else {
          maxValue = 10;
        }
        return BarChart(
          boulderBarChart(currentSettings, listColorsClimbed, maxValue,
              colorOrder, selectedTimePeriod, chartSelection, setterViewGrade),
        );

      case "SetterDataPie":
        Map<String, Map<String, int>> colorData = {};
        List<String> colorOrder = [];
        Map<String, int> boulderSetSplit = {};
        if (setterViewGrade) {
          colorData = graphData.boulderSetGradeColours;
          colorOrder = gradeColorOrder;
        } else {
          colorData = graphData.boulderSetHoldColours;
          colorOrder = holdColourOrder;
        }

        colorData.forEach((date, colorCounts) {
          for (String color in colorOrder) {
            if (colorCounts.containsKey(color)) {
              boulderSetSplit[color] =
                  (boulderSetSplit[color] ?? 0) + colorCounts[color]!;
            } else {
              // If the color doesn't exist in colorCounts, set the count to 0
              boulderSetSplit[color] = (boulderSetSplit[color] ?? 0);
            }
          }
        });

        return PieChart(
          pirChartSetter(
              currentSettings, boulderSetSplit, colorOrder, setterViewGrade),
        );

      case "AllSetterData":
        if (selectedSetter.toLowerCase() == "all") {}
        Map<String, Map<String, int>> allSetterGraphData = {};
        Map<String, Map<dynamic, Map<dynamic, int>>> allSetterDataMap = {};
        Map<String, int> gradingComparitor = {};
        String sortingSetup = "";
        String xValues = "";
        String yValues = "";

        if (gradeVsColour) {
          if (colourVsValue) {
            sortingSetup = "gradeColourToHoldColour";
            allSetterDataMap = graphData.boulderGradeColourToHoldColour;

            for (var grades in gradeColorOrder) {
              allSetterGraphData[grades.toString()] ??= {};
            }
          } else {
            sortingSetup = "gradeToHoldColour";
            allSetterDataMap = graphData.boulderGradeToHoldColour;
            String gradingSystem = "";
            if (currentProfile.gradingSystem.toLowerCase() == "coloured") {
              gradingSystem = "french";
            } else {
              gradingSystem = currentProfile.gradingSystem.toLowerCase();
            }

            for (var counter in allGrading.keys) {
              String grade = allGrading[counter]![gradingSystem]!;
               gradingComparitor[grade] = counter;
              allSetterGraphData[grade] ??= {};
            }
          }
        } else {
          for (var grades in holdColourOrder) {
            allSetterGraphData[grades.toString()] ??= {};
          }

          if (colourVsValue) {
            sortingSetup = "holdColourToGradeColour";
            allSetterDataMap = graphData.boulderHoldColourToGradeColour;
          } else {
            sortingSetup = "holdColourToGrade";
            allSetterDataMap = graphData.boulderHoldColourToGrade;
          }
        }

        for (var setter in allSetterDataMap.keys) {
          if (setter == selectedSetter ||
              selectedSetter.toLowerCase() == "all") {
            for (var gradeOrColourX in allSetterDataMap[setter]!.keys) {
              if (gradeOrColourX.runtimeType == int) {
                  if (currentProfile.gradingSystem.toLowerCase() ==
                      "coloured") {
                    xValues = allGrading[gradeOrColourX]!["french"]!;
                  } else {
                    xValues = allGrading[gradeOrColourX]![
                        currentProfile.gradingSystem.toLowerCase()]!;
                  }
                  gradingComparitor[xValues] = gradeOrColourX;
              } else {xValues=gradeOrColourX;}
              
              allSetterGraphData[xValues] ??= {};
              for (var gradeOrColourY
                  in allSetterDataMap[setter]![gradeOrColourX]!.keys) {
                if (gradeOrColourY.runtimeType == int) {
                  if (currentProfile.gradingSystem.toLowerCase() ==
                      "coloured") {
                    yValues = allGrading[gradeOrColourY]!["french"]!;
                  } else {
                    yValues = allGrading[gradeOrColourY]![
                        currentProfile.gradingSystem.toLowerCase()]!;
                  }
                  gradingComparitor[yValues] = gradeOrColourY;
                } else {
                  yValues = gradeOrColourY;
                }

                int counter =
                    allSetterDataMap[setter]![gradeOrColourX]![gradeOrColourY]!;

                (allSetterGraphData[xValues]![yValues] =
                        allSetterGraphData[xValues]![yValues] ?? counter) +
                    counter;
              }
            }
          }
        }
        print(sortingSetup);
        print("holdColourOrder - $holdColourOrder");
        print("gradingComparitor - $gradingComparitor");
        print("allSetterGraphData - $allSetterGraphData");
        switch (sortingSetup) {
          case "gradeColourToHoldColour":
            gradeColourToHoldColour(
                holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
          case "gradeToHoldColour":
            gradeToHoldColour(
                holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
          case "holdColourToGradeColour":
            holdColourToGradeColour(
                holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
          case "holdColourToGrade":
            holdColourToGrade(
                holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
        }
        print("allSetterGraphData - $allSetterGraphData");
        return const Text('AllSetterData');
      default:
        return const Text('Invalid chart selection');
    }
  }

  void holdColourToGrade(
      List<String> holdColourOrder,
      Map<String, Map<String, int>> allSetterGraphData,
      Map<String, int> gradingComparitor) {
    SplayTreeMap<String, Map<String, int>> sortedGraphData =
        SplayTreeMap<String, Map<String, int>>((a, b) {
      int indexA = holdColourOrder.indexOf(a);
      int indexB = holdColourOrder.indexOf(b);

      return indexA - indexB;
    });

    // Sort entries based on allGrading
    for (var entry in allSetterGraphData.entries) {
      String key = entry.key;
      Map<String, int> value = entry.value;

      // Convert allGrading values to a comparable format
      value = sortValuesBasedOnGrading(value, gradingComparitor);

      sortedGraphData[key] = value;
    }
  }
}

void gradeToHoldColour(
    List<String> holdColourOrder,
    Map<String, Map<String, int>> allSetterGraphData,
    Map<String, int> gradingComparitor) {
      print(gradingComparitor);

      
List<String> sortedKeys = allSetterGraphData.keys.toList()
    ..sort((a, b) => gradingComparitor[a]!.compareTo(gradingComparitor[b]!));

  // Sorting values based on holdColourOrder
  sortedKeys.forEach((key) {
    allSetterGraphData[key]!.keys.toList()
      ..sort((a, b) => holdColourOrder.indexOf(a).compareTo(holdColourOrder.indexOf(b)));
  });
    }

void holdColourToGradeColour(
    List<String> holdColourOrder,
    Map<String, Map<String, int>> allSetterGraphData,
    Map<String, int> gradingComparitor) {}

void gradeColourToHoldColour(
    List<String> holdColourOrder,
    Map<String, Map<String, int>> allSetterGraphData,
    Map<String, int> gradingComparitor) {}

Map<String, int> sortValuesBasedOnGrading(
    Map<String, int> values, Map<String, int> gradingComparitor) {
  Map<String, int> sortedValues = SplayTreeMap<String, int>((a, b) {
    // Assume allGrading is defined somewhere
    // Add other grading systems here
    int gradeA = gradingComparitor[a]!;
    int gradeB = gradingComparitor[b]!;
    return gradeA.compareTo(gradeB);
  });

  sortedValues.addAll(values);
  return sortedValues;
}
