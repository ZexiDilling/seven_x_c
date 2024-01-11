import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/views/missing_views/profile_view.dart';

import 'package:intl/intl.dart';

class LineChartGraph extends StatelessWidget {
  const LineChartGraph(
      {super.key,
      required this.chartSelection,
      required this.graphData,
      required this.selectedTimePeriod});

  final String chartSelection;
  final TimePeriod selectedTimePeriod;
  final PointsData graphData;

  @override
  Widget build(BuildContext context) {
    Map<int, DateTime> numberToDateMap = {};
    if (chartSelection == "maxGrade") {
      graphData.boulderClimbedMaxClimbed.forEach((entryDate, colors) {
        int entryNumber = graphData.boulderSetAmount[entryDate] ?? 0;
        numberToDateMap[entryNumber] = entryDate;
      });
      return LineChart(
        maxGradeChart(graphData, numberToDateMap),
        duration: const Duration(milliseconds: 250),
      );
    } else if (chartSelection == "climbs") {
      graphData.boulderClimbedAmount.forEach((entryDate, colors) {
        int entryNumber = graphData.boulderSetAmount[entryDate] ?? 0;
        numberToDateMap[entryNumber] = entryDate;
      });
      return BarChart(
        climbsBarChart(graphData, numberToDateMap),
      );
    } else if (chartSelection == "SetterData") {
      final List<String> colorOrder = [
        'Green',
        'Yellow',
        'Blue',
        'Purple',
        'Red',
        'Black'
      ];
      Map<int, List<double>> cumulativeCounts = {};
// Iterate over each entry in setColoursData and update cumulative counts
      graphData.boulderSetColours.forEach((entryDate, colors) {
        int entryNumber = graphData.boulderSetAmount[entryDate] ?? 0;
        cumulativeCounts[entryNumber] =
            colorOrder.map((color) => (colors[color] ?? 0).toDouble()).toList();
        numberToDateMap[entryNumber] = entryDate;
      });

      return BarChart(
        barChartSetterData(colorOrder, cumulativeCounts, numberToDateMap),
      );
    } else if (chartSelection == "SetterDataPie") {

      return PieChart(
                pirChartSetter(graphData.boulderSetSplit),
              );
    } else {
      return const Text('Invalid chart selection');
    }
  }

  

  final Color borderColor = Colors.green;
  final Color contentColorGreen = Colors.green;
  final Color contentColorYellow = Colors.yellow;
  final Color contentColorBlue = Colors.blue;
  final Color contentColorPurple = Colors.purple;
  final Color contentColorRed = Colors.red;
  final Color contentColorBlack = Colors.black;
  final Color borderColour = Colors.black;
  static const Color textColour = Colors.black;
  final double barWidth = 10;
  final shadowOpacity = 0.2;
  final int touchedIndex = -1;

  Widget bottomTitles(
      double value, TitleMeta meta, Map<int, DateTime> numberToDateMap) {
    const style = TextStyle(color: textColour, fontSize: 10);
    String text = '';

    // Assuming value.toInt() is the number associated with the date
    DateTime date = numberToDateMap[value.toInt()] ?? DateTime.now();

    // Format the date to your liking
    text = DateFormat('E', 'en_US').format(
        date); // This will display the day of the week (e.g., Mon, Tue, ...)

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: textColour, fontSize: 10);
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

  BarChartData climbsBarChart(PointsData graphData, numberToDateMap) {
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
                return bottomTitles(value, meta, numberToDateMap);
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
      barGroups: graphData.boulderClimbedAmount.entries.map((entry) {
        return BarChartGroupData(
          x: entry.key.millisecondsSinceEpoch,
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

  LineChartData maxGradeChart(PointsData graphData, numberToDateMap) {
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
                return bottomTitles(value, meta, numberToDateMap);
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
      lineBarsData: [
        LineChartBarData(
          spots: graphData.boulderClimbedMaxClimbed.entries.map((entry) {
            return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(),
                entry.value.toDouble());
          }).toList(),
          isCurved: true,
          belowBarData: BarAreaData(show: false),
          color: Colors.blue, // Adjust color as needed
          dotData: const FlDotData(show: false),
          isStrokeCapRound: true,
          barWidth: 4,
          isStrokeJoinRound: true,
        ),
        LineChartBarData(
          spots: graphData.boulderClimbedMaxFlashed.entries.map((entry) {
            return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(),
                entry.value.toDouble());
          }).toList(),
          isCurved: true,
          belowBarData: BarAreaData(show: false),
          color: Colors.red, // Adjust color as needed
          dotData: const FlDotData(show: false),
          isStrokeCapRound: true,

          barWidth: 4,
          isStrokeJoinRound: true,
        ),
      ],
    );
  }

  BarChartGroupData generateGroup(
    int x,
    double value1,
    double value2,
    double value3,
    double value4,
    double value5,
    double value6,
  ) {
    final isTop = value1 > 0;
    final sum = value1 + value2 + value3 + value4;
    final isTouched = touchedIndex == x;

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: sum,
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
          rodStackItems: [
            BarChartRodStackItem(
              0,
              value1,
              contentColorGreen,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1,
              value1 + value2,
              contentColorYellow,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2,
              value1 + value2 + value3,
              contentColorBlue,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2 + value3,
              value1 + value2 + value3 + value4,
              contentColorPurple,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2 + value3 + value4,
              value1 + value2 + value3 + value4 + value5,
              contentColorRed,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
            BarChartRodStackItem(
              value1 + value2 + value3 + value4 + value5,
              value1 + value2 + value3 + value4 + value5 + value6,
              contentColorBlack,
              BorderSide(
                color: borderColour,
                width: isTouched ? 2 : 0,
              ),
            ),
          ],
        ),
        BarChartRodData(
          toY: -sum,
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

  BarChartData barChartSetterData(List<String> colorOrder,
      Map<int, List<double>> cumulativeCounts, numberToDateMap) {
    return BarChartData(
      alignment: BarChartAlignment.center,
      maxY: 20,
      minY: -20,
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
                return bottomTitles(value, meta, numberToDateMap);
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
            (e) => generateGroup(e.key, e.value[0], e.value[1], e.value[2],
                e.value[3], e.value[4], e.value[5]),
          )
          .toList(),
    );
  }


 List<PieChartSectionData> showingSections(boulderSplit) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: contentColorGreen,
            value: boulderSplit["Green"].toDouble(),
            title: boulderSplit["Green"].toString(),
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
            value: boulderSplit["Yellow"].toDouble(),
            title: boulderSplit["Yellow"].toString(),
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
            value: boulderSplit["Blue"].toDouble(),
            title: boulderSplit["Blue"].toString(),
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
            value: boulderSplit["Purple"].toDouble(),
            title: boulderSplit["Purple"].toString(),
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
            value: boulderSplit["Red"].toDouble(),
            title: boulderSplit["Red"].toString(),
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
            value: boulderSplit["Black"].toDouble(),
            title: boulderSplit["Black"].toString(),
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
                pieTouchData: PieTouchData(
                 
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(boulderSplit),
              );
  }


}

// Implement this method to get the color based on the color name
Color getNameFromColour(String colorName) {
  // Add your color logic here, return Colors.green for 'Green', Colors.yellow for 'Yellow', etc.
  // You can use a Map or a switch statement for simplicity.
  // For example:
  switch (colorName) {
    case 'Green':
      return Colors.green;
    case 'Yellow':
      return Colors.yellow;
    case 'Blue':
      return Colors.blue;
    case 'Purple':
      return Colors.purple;
    case 'Red':
      return Colors.red;
    case 'Black':
      return Colors.black;
    default:
      return Colors.grey;
  }
}
