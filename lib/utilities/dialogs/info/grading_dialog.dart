import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';


void showGradeInfo(BuildContext context, CloudSettings currentSettings) {
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
                _buildGradeColorsList(context, currentSettings),
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

Widget _buildGradeColorsList(context, CloudSettings currentSettings) {
  final settingsGradeColour = currentSettings.settingsGradeColour;

  if (settingsGradeColour == null || settingsGradeColour.isEmpty) {
    return const Text("No grade colors available.");
  }

  return ListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var entry in settingsGradeColour.entries)
        _buildColorTile(context, nameToColor(currentSettings.settingsGradeColour![entry.key]), entry.value),
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
