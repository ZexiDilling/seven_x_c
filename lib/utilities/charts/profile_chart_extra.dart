import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart'
    show allGrading, nameToColor;
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import '../../helpters/functions.dart' show TimePeriod;

const double fontChartSize = 10;
const double chartHeight = 150;
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

List<BarChartRodStackItem> generateRodStackItems(CloudSettings currentSettings,
    List<double> values, List<String> colorOrder, bool isTouched) {
  List<BarChartRodStackItem> rodStackItems = [];
  double startValue = 0;

  for (int counter = 0; counter < values.length; counter++) {
    double endValue = startValue + values[counter];
    rodStackItems.add(
      BarChartRodStackItem(
        startValue,
        endValue,
        nameToColor(currentSettings.settingsGradeColour![colorOrder[counter]]),
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

findTopIndex(List<double> values) {
  for (int i = values.length - 1; i >= 0; i--) {
    if (values[i] > 0) {
      return i;
    }
  }
  return -1;
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

Widget bottomTitles(
  double value,
  TitleMeta meta,
  TimePeriod selectedTimePeriod,
  String chartSelection,
) {

  const style = TextStyle(color: textColour, fontSize: fontChartSize);
  String text = '';
  // Format the date based on the selected time period
  switch (selectedTimePeriod) {
    case TimePeriod.week:
      // Display the day of the week for each entry number
      switch (value.toInt().toString()) {
        case "0":
          text = "Mon";
          break;
        case "1":
          text = "Tue";
          break;
        case "2":
          text = "Wed";
          break;
        case "3":
          text = "Thu";
          break;
        case "4":
          text = "Fri";
          break;
        case "5":
          text = "Sat";
          break;
        case "6":
          text = "Sun";
          break;
      }
      break;
    case TimePeriod.month:
      text = value.toInt().toString();
      break;
    case TimePeriod.year:
    case TimePeriod.semester:
      switch (value.toInt().toString()) {
        
        
        case "1":
          text = "Jan";
          break;
        case "2":
          text = "Feb";
          break;
        case "3":
          text = "Mar";
          break;
        case "4":
          text = "Apr";
          break;
        case "5":
          text = "May";
          break;
        case "6":
          text = "Jun";
          break;
        case "7":
          text = "Jul";
          break;
        case "8":
          text = "Aug";
          break;
        case "9":
          text = "Sep";
          break;
        case "10":
          text = "Oct";
          break;
        case "11":
          text = "Nov";
          break;
        case "12":
          text = "Dec";
          break;
      }
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

SideTitleWidget getGradeLabel(
  
    double value, TitleMeta meta, String gradingSystem) {

  int index = value.toInt();
  String text = "";
  if (allGrading.containsKey(index)) {
    if (gradingSystem.toLowerCase() == "coloured") {
      text = allGrading[index]!["french"] ?? "";
    } else {
      text = allGrading[index]![gradingSystem.toLowerCase()] ?? "";
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
