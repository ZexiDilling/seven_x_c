import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/chart_function.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/views/profile/profile_view.dart';

const double fontChartSize = 10;
const double chartHeight = 150;

class LineChartGraph extends StatelessWidget {
  const LineChartGraph(
      {super.key,
      required this.chartSelection,
      required this.graphData,
      required this.selectedTimePeriod, required this.gradingSystem});

  final String chartSelection;
  final TimePeriod selectedTimePeriod;
  final PointsData graphData;
  final String gradingSystem;
  
  @override
  Widget build(BuildContext context) {
    Map<int, DateTime> numberToDateMap = {};
    
      DateTime startDate = calculateDateThreshold(selectedTimePeriod);
      DateTime endDate = calculateEndDate(selectedTimePeriod, startDate);
      int dateCounter = 0;
      for (DateTime date = startDate;
          date.isBefore(endDate);
          date = date.add(const Duration(days: 1))) {
        DateTime entryDateWithoutTime =
            DateTime(date.year, date.month, date.day);

        numberToDateMap[dateCounter] = entryDateWithoutTime;
        dateCounter++;
      }
    if (chartSelection == "maxGrade") {
     
      List<FlSpot> climbedEntries = graphData.boulderClimbedMaxClimbed.entries.map((entry) {
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
        maxGradeChart(graphData, numberToDateMap, minY, maxY, maxX, gradingSystem),
        duration: const Duration(milliseconds: 250),
      );
    } else if (chartSelection == "climbs") {
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
      PointsData graphData, Map<int, DateTime> numbersToDates) {
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
      maxY: 30,
      barGroups: graphData.boulderClimbedAmount.entries
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

  LineChartData maxGradeChart(PointsData graphData, numbersToDates, double minY,
      double maxY, double maxX, String gradingSystem) {
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
          spots: graphData.boulderClimbedMaxClimbed.entries
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
          spots: graphData.boulderClimbedMaxFlashed.entries
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
            value: (boulderSplit["Green"] ?? 0.0).toDouble(),
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
            value: (boulderSplit["Yellow"] ?? 0.0).toDouble(),
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
            value: (boulderSplit["Blue"] ?? 0.0).toDouble(),
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
            value: (boulderSplit["Purple"] ?? 0.0).toDouble(),
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
            value: (boulderSplit["Red"] ?? 0.0).toDouble(),
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
            value: (boulderSplit["Black"] ?? 0.0).toDouble(),
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

