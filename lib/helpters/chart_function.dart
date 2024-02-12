import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/utilities/charts/profile_charts.dart';

const Color borderColor = Colors.green;
const Color contentColorGreen = Colors.green;
const Color contentColorYellow = Colors.yellow;
const Color contentColorBlue = Colors.blue;
const Color contentColorPurple = Colors.purple;
const Color contentColorRed = Colors.red;
const Color contentColorBlack = Colors.black;
const Color contentColorSilver = Colors.grey;
const Color borderColour = Colors.black;
const Color textColour = Colors.black;
const double barWidth = 10;
const shadowOpacity = 0.2;
const int touchedIndex = -1;

Widget bottomTitles(
  double value,
  TitleMeta meta,
  Map<int, DateTime> numberToDateMap,
  TimePeriod selectedTimePeriod,
  String chartSelection,
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
    if (chartSelection == "maxGrade") {
       int? monthIndex = numberToDateMap[value.toInt()]?.month ??
          numberToDateMap[value - 10.toInt()]?.month;
      text = monthName(monthIndex!);} else 
      // Display month names and date numbers
      {DateTime date = numberToDateMap[value.toInt()]!;
      text = '${monthName(date.month)} ${date.day}';}
      break;
    case TimePeriod.year:
    case TimePeriod.semester:
    case TimePeriod.allTime:
    if (chartSelection == "maxGrade") {
       int? monthIndex = numberToDateMap[value.toInt()]?.month ??
          numberToDateMap[value - 10.toInt()]?.month;
      text = monthName(monthIndex!);} else {
      DateTime date = numberToDateMap[value.toInt()]!; 
      text = '${date.day} ${monthName(date.month)}';}
      break;
    default:
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Transform.rotate(
      angle: -45 * (3.1415926535 / 180), // Rotate text by -45 degrees
      child: Text(text, style: style),
    ),
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


