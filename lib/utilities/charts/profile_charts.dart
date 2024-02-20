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
  });
  final CloudSettings currentSettings;
  final String chartSelection;
  final TimePeriod selectedTimePeriod;
  final PointsData graphData;
  final String gradingSystem;
  final Map<int, String> gradeNumberToColour;

  @override
  Widget build(BuildContext context) {

    List<String> colorOrder = [];
    if (gradeNumberToColour.length > 1) {
      colorOrder = gradeNumberToColour.values.toList();
    } else {
      colorOrder = [
        'green',
        'yellow',
        'blue',
        'purple',
        'Rrd',
        'black',
        "silver"
      ];
    }
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
            : 27.0;

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
        }

        Map<String, List<double>> listColorsClimbed = {};

        for (String date in graphData.boulderClimbedColours.keys) {
          for (var colour in colorOrder) {
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
          boulderBarChart(currentSettings, listColorsClimbed, maxValue,
              colorOrder, selectedTimePeriod, chartSelection),
        );
      case "SetterData":
        Map<String, List<double>> listColorsClimbed = {};
        for (String date in graphData.boulderClimbedColours.keys) {
          for (var colour in colorOrder) {
            double colourCount =
                graphData.boulderClimbedColours[date]?[colour]?.toDouble() ??
                    0.0;
            if (listColorsClimbed[date] == null) {
              listColorsClimbed[date] = [colourCount];
            } else {
              listColorsClimbed[date]!.add(colourCount);
            }
          }

          List<int> graphList = graphData.boulderSetAmount.entries.map((entry) {
            final int yValue = (entry.value).toInt();
            return yValue;
          }).toList();
          double maxValue = 0;
          if (graphList.isNotEmpty) {
            maxValue = (graphList.reduce(max)).toDouble();
          }

          return BarChart(
            boulderBarChart(currentSettings, listColorsClimbed, maxValue,
                colorOrder, selectedTimePeriod, chartSelection),
          );
        }
      case "SetterDataPie":
      Map<String, int> boulderSetSplit = {"yellow": 1}; 
        return PieChart(
          
          pirChartSetter(
              currentSettings, boulderSetSplit, colorOrder),
        );
      default:
        return const Text('Invalid chart selection');
    } return const Text('Invalid chart selection');
  } 
}
