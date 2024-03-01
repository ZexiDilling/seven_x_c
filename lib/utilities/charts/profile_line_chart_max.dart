import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../helpters/time_calculations.dart' show TimePeriod;
import 'package:seven_x_c/utilities/charts/profile_chart_extra.dart';

LineChartData maxGradeChart(
    Map<String, int> sortedMapMaxClimbed,
    Map<String, int> sortedMapMaxflashed,
    double minY,
    double maxY,
    String gradingSystem,
    TimePeriod selectedTimePeriod,
    String chartSelection) {
  return LineChartData(
    titlesData: FlTitlesData(
      show: true,
      topTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (double value, TitleMeta meta) {
              return bottomTitles(
                  value, meta, selectedTimePeriod, chartSelection, null);
            }),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            return getGradeLabel(value, meta, gradingSystem);
          },
          interval: 1,
          reservedSize: 42,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
    ),
    gridData: const FlGridData(
      show: false,
    ),
    borderData: FlBorderData(
      show: false,
    ),
    minY: 0,
    maxY: maxY,
    minX: 0,

    lineBarsData: [
      LineChartBarData(
        spots: sortedMapMaxClimbed.entries.map((entry) {
          double xValue;
          xValue = double.parse(entry.key);
          return FlSpot(
            xValue,
            entry.value.toDouble().clamp(0, 27),
          );
        }).toList(),
        isCurved: true,
        belowBarData: BarAreaData(show: true),
        color: const Color.fromARGB(255, 243, 33, 208),
        dotData: const FlDotData(show: true),
        isStrokeCapRound: true,
        barWidth: 4,
        isStrokeJoinRound: true,
      ),
      LineChartBarData(
        spots: sortedMapMaxflashed.entries.map((entry) {
          double xValue;
          xValue = double.parse(entry.key);
          return FlSpot(
            xValue,
            entry.value.toDouble().clamp(0, 27),
          );
        }).toList(),
        isCurved: true,
        belowBarData: BarAreaData(show: false),
        color: const Color.fromARGB(255, 43, 219, 8),
        dotData: const FlDotData(show: false),
        isStrokeCapRound: false,
        barWidth: 4,
        isStrokeJoinRound: true,
      ),
    ],
    
  );
}
