import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/utilities/charts/profile_charts.dart';

final Color borderColor = Colors.green;
final Color contentColorGreen = Colors.green;
final Color contentColorYellow = Colors.yellow;
final Color contentColorBlue = Colors.blue;
final Color contentColorPurple = Colors.purple;
final Color contentColorRed = Colors.red;
final Color contentColorBlack = Colors.black;
final Color borderColour = Colors.black;
const Color textColour = Colors.black;
final double barWidth = 10;
final shadowOpacity = 0.2;
final int touchedIndex = -1;

Widget bottomTitles(
  double value,
  TitleMeta meta,
  Map<int, DateTime> numberToDateMap,
  TimePeriod selectedTimePeriod,
) {
  const style = TextStyle(color: textColour, fontSize: fontChartSize);
  String text = '';
  // Format the date based on the selected time period
  switch (selectedTimePeriod) {
    case TimePeriod.week:
      // Display the day of the week for each entry number
      switch (value.toInt()) {
        case 0:
          text = "Mon";
          break;
        case 1:
          text = "Tue";
          break;
        case 2:
          text = "Wed";
          break;
        case 3:
          text = "Thu";
          break;
        case 4:
          text = "Fri";
          break;
        case 5:
          text = "Sat";
          break;
        case 6:
          text = "Sun";
          break;
      }
      break;
    case TimePeriod.month:
      text = value.toInt().toString(); // Display the day of the month
      break;
    case TimePeriod.year:
    case TimePeriod.semester:
      int? monthIndex = numberToDateMap[value.toInt()]?.month ??
          numberToDateMap[value - 10.toInt()]?.month;
      text = monthName(monthIndex!);

      break;
    default:
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: style),
  );
}

String monthName(int monthIndex) {
  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return monthNames[monthIndex - 1];
}

SideTitleWidget getGradeLabel(
    double value, TitleMeta meta, String gradingSystem) {
  int index = value.toInt();
  String text = "";
  if (allGrading.containsKey(index)) {

    if (gradingSystem == "coloured") {
      text = allGrading[index]!["french"] ?? "";
    } else {
      text = allGrading[index]![gradingSystem] ?? "";
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text),
    );
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(value.toString()),
  );
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
