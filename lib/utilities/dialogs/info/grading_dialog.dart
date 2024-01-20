import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';


void showGradeInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Grading Overview'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGradeColorsList(context),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _buildGradeColorsList(context) {
  return ListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var entry in gradeColorMap.entries)
        _buildColorTile(context, entry.key, entry.value),
    ],
  );
}

Widget _buildColorTile(context, Color color, String grade) {
  final gradeRange = colorToGrade[grade.toLowerCase()];
  return ListTile(
    title: Text('$grade Grade'),
    tileColor: color,
    subtitle: gradeRange != null
        ? Text(
            'Min: ${allGrading[gradeRange['min']]!["french"]}/${allGrading[gradeRange['min']]!["v_grade"]} Max: ${allGrading[gradeRange['max']]!["french"]}/${allGrading[gradeRange['max']]!["v_grade"]}')
        : null,
    onTap: () {},
  );
}
