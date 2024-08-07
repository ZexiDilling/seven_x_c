import 'package:flutter/material.dart';

double calculateDistance(double x1, double y1, double x2, double y2) {
  return ((x2 - x1).abs() + (y2 - y1).abs());
}

// Define maps for holds and grades, where the key is the color and the value is the name
// Map<Color, String> holdColorMap = {
//   Colors.green: 'Green',
//   Colors.blue: 'Blue',
//   Colors.blue.shade900: "Dark Blue",
//   Colors.yellow: 'Yellow',
//   Colors.orange: 'Orange',
//   Colors.red: 'Red',
//   Colors.red.shade900: 'Dark Red',
//   Colors.black: 'Black',
//   Colors.white: 'White',
//   Colors.purple: "Purple",
//   Colors.grey: "Grey",
//   Colors.pink.shade200: "Pink",
//   Colors.tealAccent: "turquoise",
// };

Color nameToColor(Map<String, dynamic> data) {
  return Color.fromARGB(
    data["alpha"] ?? 255,
    data["red"] ?? 0,
    data["green"] ?? 0,
    data["blue"] ?? 0,
  );
}

// Map<Color, String> gradeColorMap = {
//   Colors.green: 'Green',
//   Colors.yellow: 'Yellow',
//   Colors.blue: 'Blue',
//   Colors.purple: 'Purple',
//   Colors.red: 'Red',
//   Colors.black: 'Black',
//   Colors.grey: 'Silver',
// };

Map<String, Map<String, int>> colorToGrade = {
  "green": {"min": 0, "max": 4},
  "yellow": {"min": 3, "max": 4},
  "blue": {"min": 5, "max": 6},
  "purple": {"min": 7, "max": 8},
  "red": {"min": 9, "max": 12},
  "black": {"min": 12, "max": 19},
  "silver": {"min": 18, "max": 27},
};

int difficultyLevelToArrow(int difficultyLevel, String gradeColorChoice) {
  final arrowTranslation = arrowDict()[difficultyLevel];
  final min = colorToGrade[gradeColorChoice.toLowerCase()]?['min'] ?? 0;
  final max = colorToGrade[gradeColorChoice.toLowerCase()]?['max'] ?? 0;

  if (arrowTranslation == null) {
    return min; // Handle invalid arrow value
  }

  // Perform the translation based on the arrow
  switch (arrowTranslation['arrow']) {
    case '↓':
      return min;
    case '↘':
      return ((((min + max) / 2) + min) / 2).round();
    case '⇄':
      return ((min + max) / 2).round();
    case '↖':
      return ((((min + max) / 2) + max) / 2).round();
    case '↑':
      return max;
    default:
      return min;
  }
}

String getArrowFromNumberAndColor(int gradeNumber, String colour) {
  int minGrade = colorToGrade[colour.toLowerCase()]!["min"]!;
  int maxGrade = colorToGrade[colour.toLowerCase()]!["max"]!;

  if (maxGrade - minGrade <= 3) {
    if (gradeNumber == maxGrade) {
      return arrowDict()[4]!["arrow"]!;
    } else if (gradeNumber == minGrade) {
      return arrowDict()[2]!["arrow"]!;
    } else {
      return arrowDict()[3]!["arrow"]!;
    }
  } else if (gradeNumber == maxGrade) {
    return arrowDict()[5]!["arrow"]!;
  } else if (gradeNumber == minGrade) {
    return arrowDict()[1]!["arrow"]!;
  } else {
    final midGrade = ((maxGrade + minGrade) / 2).round();
    if (gradeNumber == midGrade) {
      return arrowDict()[3]!["arrow"]!;
    } else if (gradeNumber < midGrade) {
      return arrowDict()[2]!["arrow"]!;
    } else {
      return arrowDict()[4]!["arrow"]!;
    }
  }
}

int getdifficultyFromArrow(String arrow) {
  for (final entry in arrowDict().entries) {
    if (entry.value["arrow"] == arrow) {
      return entry.key;
    }
  }
  // If the arrow is not found, you can handle it accordingly.
  throw Exception("Arrow not found: $arrow");
}

List<String> mapNumberToColors(int number) {
  List<String> matchingColors = [];

  for (var entry in colorToGrade.entries) {
    int min = entry.value['min']!;
    int max = entry.value['max']!;

    if (number >= min && number <= max) {
      matchingColors.add(entry.key);
    }
  }

  // If no match is found, you can return a default color or handle it as needed
  if (matchingColors.isEmpty) {
    matchingColors.add("white");
  }

  return matchingColors;
}

int getGradeValue(
  String gradingSystem,
  String selectedGrade,
) {
  for (var entry in allGrading.entries) {
    if (entry.value[gradingSystem] == selectedGrade) {
      return entry.key;
    }
  }
  return 0;
}

Map<int, Map<String, String>> allGrading = {
  0: {"french": "3", "v_grade": "VB"},
  1: {"french": "4", "v_grade": "V0"},
  2: {"french": "5a", "v_grade": "V1"},
  3: {"french": "5b", "v_grade": "V1"},
  4: {"french": "5c", "v_grade": "V2"},
  5: {"french": "5c+", "v_grade": "V2"},
  6: {"french": "6a", "v_grade": "V3"},
  7: {"french": "6a+", "v_grade": "V3/4"},
  8: {"french": "6b", "v_grade": "V4"},
  9: {"french": "6b+", "v_grade": "V4/5"},
  10: {"french": "6c", "v_grade": "V5"},
  11: {"french": "6c+", "v_grade": "V5/6"},
  12: {"french": "7a", "v_grade": "V6"},
  13: {"french": "7a+", "v_grade": "V7"},
  14: {"french": "7b", "v_grade": "V8"},
  15: {"french": "7b+", "v_grade": "V8/9"},
  16: {"french": "7c", "v_grade": "V9"},
  17: {"french": "7c+", "v_grade": "V10"},
  18: {"french": "8a", "v_grade": "V11"},
  19: {"french": "8a+", "v_grade": "V12"},
  20: {"french": "8b", "v_grade": "V13"},
  21: {"french": "8b+", "v_grade": "V14"},
  22: {"french": "8c", "v_grade": "V15"},
  23: {"french": "8c+", "v_grade": "V16"},
  24: {"french": "9a", "v_grade": "V16"},
  25: {"french": "9a+", "v_grade": "V16"},
  26: {"french": "9b", "v_grade": "V16"},
  27: {"french": "9b+", "v_grade": "V16"}
};

Map<int, Map<String, dynamic>> arrowDict() {
  return {
    1: {"arrow": "↓", "difficulty": "Really Easy"},
    2: {"arrow": "↘", "difficulty": "Kinda Easy"},
    3: {"arrow": "⇄", "difficulty": "Medium"},
    4: {"arrow": "↖", "difficulty": "Kinda Hard"},
    5: {"arrow": "↑", "difficulty": "Really Hard"},
  };
}

Map<String, List<String>> climbingGrades = {
  'v_grade': [
    'V0',
    'V1',
    'V2',
    'V3',
    'V4',
    'V5',
    'V6',
    'V7',
    'V8',
    'V9',
    'V10',
    'V11',
    'V12',
    'V13',
    'V14',
    'V15',
    'V16'
  ],
  'french': [
    '3',
    '4',
    '5a',
    '5b',
    '5c',
    '6a',
    '6a+',
    '6b',
    '6b+',
    '6c',
    '6c+',
    '7a',
    '7a+',
    '7b',
    '7b+',
    '7c',
    '7c+',
    '8a',
    '8a+',
    '8b',
    '8b+',
    '8c',
    '8c+',
    '9a'
  ],
};

class WallRegion {
  final String wallID;
  final double wallYMaX;
  final double wallYMin;
  final double wallXMax;
  final double wallXMin;
  final String wallName;
  final int section;
  bool isSelected;

  WallRegion({
    required this.wallID,
    required this.wallYMaX,
    required this.wallYMin,
    required this.wallXMax,
    required this.wallXMin,
    required this.wallName,
    required this.section,
    required this.isSelected,
  });
}

const double xMax = 0.88;
const double xMin = 0.18;
List<WallRegion> wallRegions = [
  WallRegion(
    wallID: 'slap',
    wallYMaX: 0.9198,
    wallYMin: 0.8573,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Slap',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'dyno',
    wallYMaX: 0.8573,
    wallYMin: 0.7765,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Dyno',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'chimney',
    wallYMaX: 0.7765,
    wallYMin: 0.7531,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Chimney',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'diamond',
    wallYMaX: 0.7531,
    wallYMin: 0.6851,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Diamond',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'face',
    wallYMaX: 0.6851,
    wallYMin: 0.6284,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Face',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'shroom',
    wallYMaX: 0.6284,
    wallYMin: 0.5585,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Shroom',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'onyd',
    wallYMaX: 0.5585,
    wallYMin: 0.4061,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Onyd',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'door',
    wallYMaX: 0.4061,
    wallYMin: 0.3819,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Door',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'arg',
    wallYMaX: 0.3819,
    wallYMin: 0.3240,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'ARG',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'roof',
    wallYMaX: 0.3240,
    wallYMin: 0.2570,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Roof',
    section: 3,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'top out',
    wallYMaX: 0.2570,
    wallYMin: 0.1989,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Top Out',
    section: 3,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'cave',
    wallYMaX: 0.1989,
    wallYMin: 0.0342,
    wallXMax: xMax,
    wallXMin: xMin,
    wallName: 'Cave',
    section: 3,
    isSelected: false,
  ),
];

class WallSection {
  final int sectionID;
  final String sectionName;

  WallSection({
    required this.sectionID,
    required this.sectionName,
  });
}

List<WallSection> wallSections = [
  WallSection(
    sectionID: 1,
    sectionName: "1",
  ),
  WallSection(
    sectionID: 2,
    sectionName: "2",
  ),
  WallSection(
    sectionID: 3,
    sectionName: "3",
  )
];

//  To get the coordinates, use a print statment on "tempCenterY" on the _tapping function in Gym view

class CircleInfo {
  final double centerX;
  final double centerY;
  final CircleData data;

  CircleInfo({
    required this.centerX,
    required this.centerY,
    required this.data,
  });
}

class CircleData {
  final String title;
  final String description;
  final Color? holdColor;
  final Color? gradeColor;

  CircleData({
    required this.title,
    required this.description,
    this.holdColor,
    this.gradeColor,
  });
}

int findNumberFromDate(DateTime date, Map<int, DateTime> numberToDateMap) {
  // Calculate the difference in days between the given date and the start date
  int daysDifference = date.difference(numberToDateMap[0]!).inDays;

  // Ensure the result is non-negative
  return daysDifference >= 0 ? daysDifference : 0;
}

List climbTags() {
  return [
    "Crimpy",
    "Juggy",
    "balance",
    "slab",
    "Dyno",
    "Compression",
    "Cut Feet",
    "Dead Point",
    "Layback",
    "Pinchy",
    "Pocket",
    "Powerfull",
    "Pumpy",
    "Slopey",
    "Technical",
    "Reachy",
    "Short Friendly",
    "Crack",
    "BullShit"
  ];
}
