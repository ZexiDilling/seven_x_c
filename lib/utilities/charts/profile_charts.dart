import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/chart_function.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/views/profile/profile_view.dart';

const double fontChartSize = 10;
const double chartHeight = 150;

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
    Map<int, DateTime> numberToDateMap = {};
    Map<DateTime, int> dateToNumberMap = {};

    DateTime startDate = calculateDateThreshold(selectedTimePeriod);
    DateTime endDate = calculateEndDate(selectedTimePeriod, startDate);
    int dateCounter = 0;

    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      DateTime entryDateWithoutTime = DateTime(date.year, date.month, date.day);
      numberToDateMap[dateCounter] = entryDateWithoutTime;
      dateToNumberMap[entryDateWithoutTime] = dateCounter;
      dateCounter++;
    }

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

    if (chartSelection == "maxGrade") {
      List<MapEntry<DateTime, int>> sortedListClimbed =
          graphData.boulderClimbedMaxClimbed.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      Map<DateTime, int> sortedMapMaxClimbed =
          Map.fromEntries(sortedListClimbed);

      List<MapEntry<DateTime, int>> sortedListFlash =
          graphData.boulderClimbedMaxFlashed.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      Map<DateTime, int> sortedMapMaxflashed = Map.fromEntries(sortedListFlash);

      List<FlSpot> climbedEntries =
          graphData.boulderClimbedMaxClimbed.entries.map((entry) {
        return FlSpot(
          entry.key.millisecondsSinceEpoch.toDouble(),
          entry.value.toDouble().clamp(0, 27),
        );
      }).toList();
      double maxYValue = climbedEntries.isNotEmpty
          ? climbedEntries
              .map((entry) => entry.y)
              .reduce((a, b) => a > b ? a : b)
          : 27.0;

      double maxY = (maxYValue + 4).clamp(0, 27);

      double minY = (maxY - 12).clamp(0, maxY);
      double maxX = numberToDateMap.length.toDouble();
      return LineChart(
        maxGradeChart(sortedMapMaxClimbed, sortedMapMaxflashed, numberToDateMap,
            minY, maxY, maxX, gradingSystem),
        duration: const Duration(milliseconds: 250),
      );
    } else if (chartSelection == "climbs") {
      List<MapEntry<DateTime, int>> sortedList =
          graphData.boulderClimbedAmount.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      Map<DateTime, int> sortedMap = Map.fromEntries(sortedList);

      List<int> graphList = sortedMap.entries
          .where((entry) => numberToDateMap.containsValue(entry.key))
          .map((entry) {
        final int yValue = (entry.value).toInt();
        return yValue;
      }).toList();
      double maxValue = 0;
      if (graphList.isNotEmpty) {
        maxValue = (graphList.reduce(max)).toDouble();
      }
      print(sortedMap);
      return BarChart(
        climbsBarChart(sortedMap, numberToDateMap, maxValue, colorOrder),
      );
    } else if (chartSelection == "SetterData") {
      Map<int, List<double>> cumulativeCounts = {};
      double maxYValue = 0.0;

// Iterate over each entry in setColoursData and update cumulative counts
      graphData.boulderSetColours.forEach((entryDate, colors) {
        int entryNumber = dateToNumberMap[entryDate] ?? 0;
        cumulativeCounts[entryNumber] =
            colorOrder.map((color) => (colors[color] ?? 0).toDouble()).toList();
        numberToDateMap[entryNumber] = entryDate;
      });

      Map<int, double> totalCounts = {};

// Iterate over each entry in cumulativeCounts and calculate total counts
      cumulativeCounts.forEach((entryNumber, counts) {
        double totalCount = counts.reduce((value, element) => value + element);
        totalCounts[entryNumber] = totalCount;
      });

// Convert the map to a list of entries and sort it by keys (entryNumber in this case)
      List<MapEntry<int, List<double>>> sortedList = cumulativeCounts.entries
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

// Create a new sorted map from the sorted list
      Map<int, List<double>> sortedMap = Map.fromEntries(sortedList);

// Print the sorted map

// Find the maximum total count
      if (totalCounts.isNotEmpty) {
        int maxEntryNumber = totalCounts.keys
            .reduce((a, b) => totalCounts[a]! > totalCounts[b]! ? a : b);
        maxYValue = totalCounts[maxEntryNumber]!;
      }
      print(sortedMap);
      return BarChart(
        barChartSetterData(currentSettings, colorOrder, sortedMap, numberToDateMap, maxYValue),
      );
    } else if (chartSelection == "SetterDataPie") {
      return PieChart(
        pirChartSetter(graphData.boulderSetSplit),
      );
    } else {
      return const Text('Invalid chart selection');
    }
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: textColour, fontSize: fontChartSize);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()}';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  BarChartData climbsBarChart(Map<DateTime, int> graphData,
      Map<int, DateTime> numbersToDates, double maxYValue, List<String> colorOrder) {
    return BarChartData(
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
                    value, meta, numbersToDates, selectedTimePeriod);
              }),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitles,
            interval: 5,
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
      maxY: maxYValue,

      // barGroups: cumulativeCounts.entries
      //     .map(
      //       (e) => generateGroup(e.key, e.value, colorOrder),
      //     )
      //     .toList(),

      barGroups: graphData.entries
          .where((entry) => numbersToDates.containsValue(entry.key))
          .map((entry) {
        final xValue = findNumberFromDate(entry.key, numbersToDates);
        return BarChartGroupData(
          x: xValue,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: Colors.blue,
              width: 16,
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData maxGradeChart(
      Map<DateTime, int> sortedMapMaxClimbed,
      Map<DateTime, int> sortedMapMaxflashed,
      numbersToDates,
      double minY,
      double maxY,
      double maxX,
      String gradingSystem) {
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
                    value, meta, numbersToDates, selectedTimePeriod);
              }),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return getGradeLabel(value, meta, gradingSystem);
            },
            interval: 5,
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
      maxX: maxX,
      lineBarsData: [
        LineChartBarData(
          spots: sortedMapMaxClimbed.entries
              .where((entry) => numbersToDates.containsValue(entry.key))
              .map((entry) {
            return FlSpot(
              findNumberFromDate(entry.key, numbersToDates).toDouble(),
              entry.value.toDouble(),
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
          spots: sortedMapMaxflashed.entries
              .where((entry) => numbersToDates.containsValue(entry.key))
              .map((entry) {
            return FlSpot(
              findNumberFromDate(entry.key, numbersToDates).toDouble(),
              entry.value.toDouble(),
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

  BarChartGroupData generateGroup(
    CloudSettings currentSettings,
    int x,
    List<double> values,
    List<String> colorOrder,
  ) {
    final sum = values.reduce((a, b) => a + b);
    final isTouched = touchedIndex == x;
    final isTop = values[0] > 0;

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: isTop ? sum : -sum,
          width: barWidth,
          borderRadius: isTop
              ? const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
          rodStackItems: generateRodStackItems(currentSettings, values, colorOrder, isTouched),
        ),
        BarChartRodData(
          toY: isTop ? -sum : sum,
          width: barWidth,
          color: Colors.transparent,
          borderRadius: isTop
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
        ),
      ],
    );
  }

  List<BarChartRodStackItem> generateRodStackItems(
      CloudSettings currentSettings, List<double> values, List<String> colorOrder, bool isTouched) {
    List<BarChartRodStackItem> rodStackItems = [];
    double startValue = 0;

    for (int counter = 0; counter < values.length; counter++) {
      double endValue = startValue + values[counter];
      rodStackItems.add(
        BarChartRodStackItem(
          startValue,
          endValue,
          nameToColor(currentSettings.settingsGradeColour![colorOrder[
              counter]] ), // Assuming contentColors is a list of your content colors
          BorderSide(
            color: borderColour,
            width: isTouched ? 2 : 0,
          ),
        ),
      );

      startValue = endValue;
    }

    return rodStackItems;
  }

  BarChartData barChartSetterData(
    CloudSettings currentSettings,
      List<String> colorOrder,
      Map<int, List<double>> cumulativeCounts,
      numberToDateMap,
      double maxYValue) {
    return BarChartData(
      alignment: BarChartAlignment.center,
      maxY: maxYValue,
      minY: 0,
      groupsSpace: 12,
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
                    value, meta, numberToDateMap, selectedTimePeriod);
              }),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitles,
            interval: 5,
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
      barGroups: cumulativeCounts.entries
          .map(
            (e) => generateGroup(currentSettings, e.key, e.value, colorOrder),
          )
          .toList(),
    );
  }

  List<PieChartSectionData> showingSections(boulderSplit) {
    return List.generate(7, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: contentColorGreen,
            value: (boulderSplit["green"] ?? 0.0).toDouble(),
            title: boulderSplit["green"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: contentColorYellow,
            value: (boulderSplit["yellow"] ?? 0.0).toDouble(),
            title: boulderSplit["yellow"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: contentColorBlue,
            value: (boulderSplit["blue"] ?? 0.0).toDouble(),
            title: boulderSplit["blue"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: contentColorPurple,
            value: (boulderSplit["purple"] ?? 0.0).toDouble(),
            title: boulderSplit["purple"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: contentColorRed,
            value: (boulderSplit["red"] ?? 0.0).toDouble(),
            title: boulderSplit["red"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 5:
          return PieChartSectionData(
            color: contentColorBlack,
            value: (boulderSplit["black"] ?? 0.0).toDouble(),
            title: boulderSplit["black"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        case 6:
          return PieChartSectionData(
            color: contentColorSilver,
            value: (boulderSplit["silver"] ?? 0.0).toDouble(),
            title: boulderSplit["silver"].toString(),
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColour,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  PieChartData pirChartSetter(boulderSplit) {
    return PieChartData(
      pieTouchData: PieTouchData(),
      borderData: FlBorderData(
        show: false,
      ),
      sectionsSpace: 0,
      centerSpaceRadius: 40,
      sections: showingSections(boulderSplit),
    );
  }
}
