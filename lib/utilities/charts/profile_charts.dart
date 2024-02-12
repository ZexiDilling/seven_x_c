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
      List<MapEntry<DateTime, Map<String, int>>> entries =
          graphData.boulderClimbedColours.entries.toList();
      
      // Sort the list by date
      entries.sort((a, b) => a.key.compareTo(b.key));

      // Convert the sorted list back to a map
      Map<DateTime, Map<String, int>> sortedBoulderClimbedColours =
          Map.fromEntries(entries);

      List<int> graphList = graphData.boulderClimbedAmount.entries
          .where((entry) => numberToDateMap.containsValue(entry.key))
          .map((entry) {
        final int yValue = (entry.value).toInt();
        return yValue;
      }).toList();
      double maxValue = 0;
      if (graphList.isNotEmpty) {
        maxValue = (graphList.reduce(max)).toDouble();
      }

      Map<int, List<double>> listColorsClimbed = {};

      for (DateTime date in sortedBoulderClimbedColours.keys) {
        int dateCounter = dateToNumberMap[date] ?? 0;
        for (var colour in colorOrder) {
          double colourCount =
              (sortedBoulderClimbedColours[date]![colour])?.toDouble() ?? 0.0;
          if (listColorsClimbed[dateCounter] == null) {
            listColorsClimbed[dateCounter] = [colourCount];
          } else {
            listColorsClimbed[dateCounter]!
                .add(colourCount); // Use add to append to the list
          }
        }
      }
      return BarChart(
        climbsBarChart(currentSettings, listColorsClimbed, numberToDateMap,
            maxValue, colorOrder),
      );
    } else if (chartSelection == "SetterData") {
      Map<int, List<double>> cumulativeCounts = {};
      double maxYValue = 0.0;

      graphData.boulderSetColours.forEach((entryDate, colors) {
        int entryNumber = dateToNumberMap[entryDate] ?? 0;
        cumulativeCounts[entryNumber] =
            colorOrder.map((color) => (colors[color] ?? 0).toDouble()).toList();
        numberToDateMap[entryNumber] = entryDate;
      });

      Map<int, double> totalCounts = {};

      cumulativeCounts.forEach((entryNumber, counts) {
        double totalCount = counts.reduce((value, element) => value + element);
        totalCounts[entryNumber] = totalCount;
      });

      List<MapEntry<int, List<double>>> sortedList = cumulativeCounts.entries
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      Map<int, List<double>> sortedColorSet = Map.fromEntries(sortedList);

      if (totalCounts.isNotEmpty) {
        int maxEntryNumber = totalCounts.keys
            .reduce((a, b) => totalCounts[a]! > totalCounts[b]! ? a : b);
        maxYValue = totalCounts[maxEntryNumber]!;
      }
      return BarChart(
        barChartSetterData(currentSettings, colorOrder, sortedColorSet,
            numberToDateMap, maxYValue),
      );
    } else if (chartSelection == "SetterDataPie") {
      return PieChart(
        pirChartSetter(currentSettings, graphData.boulderSetSplit, colorOrder),
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

  BarChartData climbsBarChart(
      CloudSettings currentSettings,
      Map<int, List<double>> graphData,
      Map<int, DateTime> numbersToDates,
      double maxYValue,
      List<String> colorOrder) {
        
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
                    value, meta, numbersToDates, selectedTimePeriod, chartSelection);
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
      barGroups: graphData.entries
      .map((entry) => generateGroup(
        currentSettings,
        entry.key,
        entry.value,
        colorOrder,
      ))
      .toList(),
  );
    //   barGroups: graphData.entries
    //       .map(
    //         (entries) => generateGroup(
    //             currentSettings, entries.key, entries.value, colorOrder),
    //       )
    //       .toList(),
    // );
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
                    value, meta, numbersToDates, selectedTimePeriod, chartSelection);
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
    final isTop = findTopIndex(values);
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: isTop >= 0 ? sum : -sum,
          width: barWidth,
          borderRadius: isTop >= 0
              ? const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
          rodStackItems: generateRodStackItems(
              currentSettings, values, colorOrder, isTouched),
        ),
        BarChartRodData(
          toY: isTop >= 0 ? -sum : sum,
          width: barWidth,
          color: Colors.transparent,
          borderRadius: isTop >= 0
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
      CloudSettings currentSettings,
      List<double> values,
      List<String> colorOrder,
      bool isTouched) {
    List<BarChartRodStackItem> rodStackItems = [];
    double startValue = 0;

    for (int counter = 0; counter < values.length; counter++) {
      double endValue = startValue + values[counter];
      rodStackItems.add(
        BarChartRodStackItem(
          startValue,
          endValue,
          nameToColor(
              currentSettings.settingsGradeColour![colorOrder[counter]]),
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
                    value, meta, numberToDateMap, selectedTimePeriod, chartSelection);
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
            (entries) => generateGroup(
                currentSettings, entries.key, entries.value, colorOrder),
          )
          .toList(),
    );
  }

  List<PieChartSectionData> showingSections(CloudSettings currentSettings,
      Map<String, int> boulderSplit, List<String> colorOrder) {
    return List.generate(boulderSplit.length, (counter) {
      final isTouched = counter == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final colorKey = boulderSplit.keys.elementAt(counter);
      final colorValue = boulderSplit[colorKey];

      return PieChartSectionData(
        color: nameToColor(
            currentSettings.settingsGradeColour![colorOrder[counter]]),
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
      Map<String, int> boulderSplit, List<String> colorOrder) {
    return PieChartData(
      pieTouchData: PieTouchData(),
      borderData: FlBorderData(
        show: false,
      ),
      sectionsSpace: 0,
      centerSpaceRadius: 40,
      sections: showingSections(currentSettings, boulderSplit, colorOrder),
    );
  }
}

findTopIndex(List<double> values) {
  for (int i = values.length - 1; i >= 0; i--) {
    if (values[i] > 0) {
      return i;
    }
  }
  return -1;
}
