import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart' show allGrading;
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import '../../helpters/time_calculations.dart' show TimePeriod;
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
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
              setterViewGrade,
              null,
              null,
              null),
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
          boulderBarChart(
              currentSettings,
              listColorsClimbed,
              maxValue,
              colorOrder,
              selectedTimePeriod,
              chartSelection,
              setterViewGrade,
              null,
              null,
              null),
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
        String xValue = "";
        String yValue = "";

        String gradingSystem = "";
        if (currentProfile.gradingSystem.toLowerCase() == "coloured") {
          gradingSystem = "french";
        } else {
          gradingSystem = currentProfile.gradingSystem.toLowerCase();
        }

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
                xValue = allGrading[gradeOrColourX]![gradingSystem]!;
                gradingComparitor[xValue] = gradeOrColourX;
              } else {
                xValue = gradeOrColourX;
              }

              allSetterGraphData[xValue] ??= {};
              for (var gradeOrColourY
                  in allSetterDataMap[setter]![gradeOrColourX]!.keys) {
                if (gradeOrColourY.runtimeType == int) {
                  yValue = allGrading[gradeOrColourY]![gradingSystem]!;
                  gradingComparitor[yValue] = gradeOrColourY;
                } else {
                  yValue = gradeOrColourY;
                }

                int counter =
                    allSetterDataMap[setter]![gradeOrColourX]![gradeOrColourY]!;

                allSetterGraphData[xValue]![yValue] =
                    (allSetterGraphData[xValue]![yValue] ?? 0) + counter;
              }
            }
          }
        }
        List<String> xValuesOrder = [];
        bool? setterViewGradeNew;
        Map<int, Color>? gradeColors;

        switch (sortingSetup) {
          case "gradeColourToHoldColour":
            xValuesOrder = holdColourOrder;
            setterViewGradeNew = false;
            // gradeColourToHoldColour(holdColourOrder, allSetterGraphData, gradeColorOrder);
            break;
          case "gradeToHoldColour":
            xValuesOrder = holdColourOrder;
            setterViewGradeNew = false;
            // gradeToHoldColour(holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
          case "holdColourToGradeColour":
            xValuesOrder = gradeColorOrder;
            setterViewGradeNew = true;
            // holdColourToGradeColour(holdColourOrder, allSetterGraphData, gradeColorOrder);
            break;
          case "holdColourToGrade":
            setterViewGradeNew = null;
            xValuesOrder =
                allGrading.values.map((map) => map[gradingSystem]!).toList();

            gradeColors = generateGradeColors(allGrading,
                currentSettings.settingsGradeColour!, gradingSystem);
            // holdColourToGrade(holdColourOrder, allSetterGraphData, gradingComparitor);
            break;
        }

        Map<String, List<double>> listOfSettingsSplit = {};
        double maxValue = 0;
        int counter = 0;
        double xValueCounter = 0.0;
        Map<String, String> yValueTranslator = {};
        for (var yValue in allSetterGraphData.keys) {
          listOfSettingsSplit[counter.toString()] = [];
          yValueTranslator[counter.toString()] = yValue;
          xValueCounter = 0;
          for (var xValue in xValuesOrder) {
            double xValueCount =
                allSetterGraphData[yValue]?[xValue]?.toDouble() ?? 0.0;
            listOfSettingsSplit[counter.toString()]!.add(xValueCount);
            xValueCounter += xValueCount;
          }
          if (maxValue < xValueCounter) {
            maxValue = xValueCounter;
          }
          counter++;
        }

        return BarChart(
          boulderBarChart(
              currentSettings,
              listOfSettingsSplit,
              maxValue,
              xValuesOrder,
              selectedTimePeriod,
              chartSelection,
              setterViewGradeNew,
              sortingSetup,
              yValueTranslator,
              gradeColors),
        );
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
  List<String> sortedKeys = allSetterGraphData.keys.toList()
    ..sort((a, b) => gradingComparitor[a]!.compareTo(gradingComparitor[b]!));

  // Sorting values based on holdColourOrder
  for (var key in sortedKeys) {
    allSetterGraphData[key]!.keys.toList().sort((a, b) =>
        holdColourOrder.indexOf(a).compareTo(holdColourOrder.indexOf(b)));
  }
}

void holdColourToGradeColour(
    List<String> holdColourOrder,
    Map<String, Map<String, int>> allSetterGraphData,
    List<String> gradeColorOrder) {
  List<String> sortedKeys = allSetterGraphData.keys.toList()
    ..sort((a, b) =>
        holdColourOrder.indexOf(a).compareTo(holdColourOrder.indexOf(b)));

  for (var key in sortedKeys) {
    allSetterGraphData[key]!.keys.toList().sort((a, b) =>
        gradeColorOrder.indexOf(a).compareTo(gradeColorOrder.indexOf(b)));
  }
}

void gradeColourToHoldColour(
    List<String> holdColourOrder,
    Map<String, Map<String, int>> allSetterGraphData,
    List<String> gradeColorOrder) {
  List<String> sortedKeys = allSetterGraphData.keys.toList()
    ..sort((a, b) =>
        gradeColorOrder.indexOf(a).compareTo(gradeColorOrder.indexOf(b)));

  for (var key in sortedKeys) {
    allSetterGraphData[key]!.keys.toList().sort((a, b) =>
        holdColourOrder.indexOf(a).compareTo(holdColourOrder.indexOf(b)));
  }
}

Map<String, int> sortValuesBasedOnGrading(
    Map<String, int> values, Map<String, int> gradingComparitor) {
  Map<String, int> sortedValues = SplayTreeMap<String, int>((a, b) {
    int gradeA = gradingComparitor[a]!;
    int gradeB = gradingComparitor[b]!;
    return gradeA.compareTo(gradeB);
  });

  sortedValues.addAll(values);
  return sortedValues;
}

Map<int, Color> generateGradeColors(Map<int, Map<String, String>> allGrading,
    Map<String, dynamic> settings, String gradingSystem) {
  // Sort the settings map based on min values
  List<String> sortedColors = settings.keys.toList()
    ..sort((a, b) => settings[a]['min'].compareTo(settings[b]['min']));

  // Create a map to store the generated colors for each grade number
  Map<int, Color> gradeColors = {};

  // Generate colors for each grade number
  for (var gradeInt in allGrading.keys) {
    // Find the color that matches the grade range
    for (String color in sortedColors) {
      int min = settings[color]['min'];
      int max = settings[color]['max'];

      if (gradeInt >= min && gradeInt <= max) {
        // Check if the color is already assigned to a lower grade

        bool isColorTaken = gradeColors.values.contains(Color.fromRGBO(
          settings[color]['red'],
          settings[color]['green'],
          settings[color]['blue'],
          1,
        ));

        // If the color is not taken, assign it to the current grade
        // Otherwise, find the next available darker shade
        if (!isColorTaken) {
          gradeColors[gradeInt] = Color.fromRGBO(
            settings[color]['red'],
            settings[color]['green'],
            settings[color]['blue'],
            1,
          );
          break;
        } else {
          // Find the next available darker shade
          double darkenFactor =
              0.2; // Adjust this factor based on how much darker you want the shade to be
          gradeColors[gradeInt] = getDarkerShade(
            Color.fromRGBO(
              settings[color]['red'],
              settings[color]['green'],
              settings[color]['blue'],
              1,
            ),
            darkenFactor,
          );
          break;
        }
      }
    }
  }

  return gradeColors;
}

Color getDarkerShade(Color originalColor, double factor) {
  assert(factor >= 0 && factor <= 1, 'Factor should be between 0 and 1');

  int red = (originalColor.r * (1 - factor)).round();
  int green = (originalColor.g * (1 - factor)).round();
  int blue = (originalColor.b * (1 - factor)).round();

  return Color.fromRGBO(red, green, blue, 1);
}
