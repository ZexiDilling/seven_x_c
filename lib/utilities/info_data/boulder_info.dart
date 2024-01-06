import 'package:flutter/material.dart';

const boulderRadius = 2.5;
const minBoulderDistance = 10.0;

double calculateDistance(double x1, double y1, double x2, double y2) {
  return ((x2 - x1).abs() + (y2 - y1).abs());
}

// Define maps for holds and grades, where the key is the color and the value is the name
Map<Color, String> holdColorMap = {
  Colors.green: 'Green',
  Colors.blue: 'Blue',
  Colors.yellow: 'Yellow',
  Colors.orange: 'Orange',
  Colors.red: 'Red',
  Colors.black: 'Black',
  Colors.white: 'White',
  Colors.purple: "Purple",
  Colors.grey: "Grey",
};

Map<Color, String> gradeColorMap = {
  Colors.green: 'Green',
  Colors.yellow: 'Yellow',
  Colors.blue: 'Blue',
  Colors.purple: 'Purple',
  Colors.red: 'Red',
  Colors.black: 'Black',
  Colors.grey: 'Grey',
};

Map<String, Map<String, int>> colorToGrade = {
  "green": {"min": 0, "max": 4},
  "yellow": {"min": 3, "max": 4},
  "blue": {"min": 5, "max": 6},
  "purple": {"min": 7, "max": 8},
  "red": {"min": 9, "max": 12},
  "black": {"min": 12, "max": 19},
  "white": {"min": 18, "max": 27},
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

Color? getColorFromName(String colorName) {
  for (var entry in holdColorMap.entries) {
    if (entry.value == colorName) {
      return entry.key;
    }
  }
  return null;
}

Color? numberToColor(int number) {
  List<String> colorName = mapNumberToColors(number);
  return getColorFromName(colorName[0]);
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

Map<int, Map<String, String>> arrowDict() {
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
  final double wallXMax;
  final double wallXMin;
  final String wallName;
  final int section;
  bool isSelected;

  WallRegion({
    required this.wallID,
    required this.wallXMax,
    required this.wallXMin,
    required this.wallName,
    required this.section,
    required this.isSelected,

  });
}

List<WallRegion> wallRegions = [
  WallRegion(
    wallID: 'slap',
    wallXMax: double.infinity,
    wallXMin: 626,
    wallName: 'Slap',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'dyno',
    wallXMax: 626,
    wallXMin: 561,
    wallName: 'Dyno',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'chimney',
    wallXMax: 561,
    wallXMin: 556,
    wallName: 'Chimney',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'diamond',
    wallXMax: 556,
    wallXMin: 490,
    wallName: 'Diamond',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'face',
    wallXMax: 490,
    wallXMin: 435,
    wallName: 'Face',
    section: 1,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'shroom',
    wallXMax: 435,
    wallXMin: 385,
    wallName: 'Shroom',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'Onyd',
    wallXMax: 385,
    wallXMin: 280,
    wallName: 'Onyd',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'door',
    wallXMax: 280,
    wallXMin: 256,
    wallName: 'Door',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'ARG',
    wallXMax: 256,
    wallXMin: 216,
    wallName: 'ARG',
    section: 2,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'Roof',
    wallXMax: 216,
    wallXMin: 138,
    wallName: 'Roof',
    section: 3,
    isSelected: false,
  ),
  WallRegion(
    wallID: 'cave',
    wallXMax: 138,
    wallXMin: 0,
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
  ),  WallSection(
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
