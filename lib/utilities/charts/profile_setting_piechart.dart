
  import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart' show nameToColor;

import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_chart_extra.dart';

List<PieChartSectionData> showingSections(CloudSettings currentSettings,
      Map<String, int> boulderSplit, List<String> colorOrder, bool setterViewGrade) {
    return List.generate(boulderSplit.length, (counter) {
      final isTouched = counter == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final colorKey = boulderSplit.keys.elementAt(counter);
      final colorValue = boulderSplit[colorKey];

      return PieChartSectionData(
        color: setterViewGrade ? nameToColor(
            currentSettings.settingsGradeColour![colorOrder[counter]]) : nameToColor(
            currentSettings.settingsHoldColour![colorOrder[counter]]),
        value: (colorValue ?? 0.0).toDouble(),
        title: colorValue?.toString() ?? "",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColour,
          shadows: shadows,
        ),
      );
    });
  }

  PieChartData pirChartSetter(CloudSettings currentSettings,
      Map<String, int> boulderSplit, List<String> colorOrder, bool setterViewGrade) {
    return PieChartData(
      pieTouchData: PieTouchData(),
      borderData: FlBorderData(
        show: false,
      ),
      sectionsSpace: 0,
      centerSpaceRadius: 40,
      sections: showingSections(currentSettings, boulderSplit, colorOrder, setterViewGrade),
    );
  }
