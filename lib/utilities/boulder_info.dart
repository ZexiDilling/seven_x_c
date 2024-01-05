import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

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

class BackgroundRegion {
  final String regionId;
  final double regionTop;
  final double regionBottom;
  final String attribute;

  BackgroundRegion({
    required this.regionId,
    required this.regionTop,
    required this.regionBottom,
    required this.attribute,
  });
}

List<BackgroundRegion> wallRegions = [
  BackgroundRegion(
    regionId: 'slap',
    regionTop: double.infinity,
    regionBottom: 626,
    attribute: 'Slap',
  ),
  BackgroundRegion(
    regionId: 'dyno',
    regionTop: 626,
    regionBottom: 561,
    attribute: 'Dyno',
  ),
  BackgroundRegion(
    regionId: 'chimney',
    regionTop: 561,
    regionBottom: 556,
    attribute: 'Chimney',
  ),
  BackgroundRegion(
    regionId: 'diamond',
    regionTop: 556,
    regionBottom: 490,
    attribute: 'Diamond',
  ),
  BackgroundRegion(
    regionId: 'face',
    regionTop: 490,
    regionBottom: 435,
    attribute: 'Face',
  ),
  BackgroundRegion(
    regionId: 'shroom',
    regionTop: 435,
    regionBottom: 385,
    attribute: 'Shroom',
  ),
  BackgroundRegion(
    regionId: 'Onyd',
    regionTop: 385,
    regionBottom: 280,
    attribute: 'Onyd',
  ),
  BackgroundRegion(
    regionId: 'door',
    regionTop: 280,
    regionBottom: 256,
    attribute: 'Door',
  ),
  BackgroundRegion(
    regionId: 'ARG',
    regionTop: 256,
    regionBottom: 216,
    attribute: 'ARG',
  ),
  BackgroundRegion(
    regionId: 'Roof',
    regionTop: 216,
    regionBottom: 138,
    attribute: 'Roof',
  ),
  BackgroundRegion(
    regionId: 'cave',
    regionTop: 138,
    regionBottom: 0,
    attribute: 'Cave',
  ),
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

class GymPainter extends CustomPainter {
  final Iterable<CloudBoulder> allBoulders;
  final CloudProfile currentProfile;

  GymPainter(this.allBoulders, this.currentProfile);

  @override
  void paint(Canvas canvas, Size size) {
    for (final boulder in allBoulders) {
      bool userTopped = false;
      bool userFlashed = false;
      Color? gradeColour = getColorFromName(capitalizeFirstLetter(boulder.gradeColour));
      Color? holdColour = getColorFromName(boulder.holdColour);
      double fadeEffect = 0.3;

      if (boulder.climberTopped != null &&
          boulder.climberTopped is Map<String, dynamic>) {
        if (boulder.climberTopped!.containsKey(currentProfile.userID)) {
          var userClimbInfo = boulder.climberTopped?[currentProfile.userID];
          userFlashed = userClimbInfo['flashed'] ?? false;
          userTopped = userClimbInfo['topped'] ?? false;
          
        }
      }
      
      final Paint paint = Paint()
        ..color = (userTopped ? gradeColour?.withOpacity(fadeEffect) : gradeColour!)!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(boulder.cordX, boulder.cordY),
        boulderRadius,
        paint,
      );

    if (userFlashed && !userTopped) {
      final Paint glowPaint = Paint()
        ..color = Colors.purple.withOpacity(0.2) // Semi-transparent white color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.1); // Adjust the radius as needed

      canvas.drawCircle(
        Offset(boulder.cordX, boulder.cordY),
        boulderRadius + 5.0, // Adjust the radius to make the glow more visible
        glowPaint,
      );
    }
      final Paint outlinePaint = Paint()
        ..color =
            (userTopped ? holdColour?.withOpacity(fadeEffect) : holdColour!)!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(boulder.cordX, boulder.cordY),
        boulderRadius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
