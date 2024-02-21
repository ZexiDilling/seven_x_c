import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart' show TimePeriod;
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_barchart.dart';
import 'package:seven_x_c/utilities/charts/profile_line_chart_max.dart';
import 'package:seven_x_c/utilities/charts/profile_setting_piechart.dart';
import 'package:seven_x_c/views/profile/point_gather.dart';

class LineChartGraph extends StatelessWidget {
  const LineChartGraph({
    super.key,
    required this.currentSettings,
    required this.chartSelection,
    required this.graphData,
    required this.selectedTimePeriod,
    required this.gradingSystem,
    required this.gradeNumberToColour,
    required this.setterViewGrade,
  });
  final CloudSettings currentSettings;
  final String chartSelection;
  final TimePeriod selectedTimePeriod;
  final PointsData graphData;
  final String gradingSystem;
  final Map<int, String> gradeNumberToColour;
  final bool setterViewGrade;

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
        print(graphData.boulderClimbedMaxClimbed);
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
        } else {maxValue = 10;}


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
        } else {maxValue = 10;}
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

      default:
        return const Text('Invalid chart selection');
    }
  }
}
