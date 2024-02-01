import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart' show capitalize;
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';


void showGradeInfo(BuildContext context, CloudSettings currentSettings, CloudProfile currentProfile) {
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
                _buildGradeColorsList(context, currentSettings, currentProfile),
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

Widget _buildGradeColorsList(context, CloudSettings currentSettings, CloudProfile currentProfile) {
  final settingsGradeColour = currentSettings.settingsGradeColour;

  if (settingsGradeColour == null || settingsGradeColour.isEmpty) {
    return const Text("No grade colors available.");
  }

  // Sort entries based on the minimum grade value
  final sortedEntries = settingsGradeColour.entries.toList()
    ..sort((a, b) => a.value['min'].compareTo(b.value['min']));

  return ListView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var entry in sortedEntries)
        _buildColorTile(
          context,
          nameToColor(currentSettings.settingsGradeColour![entry.key]),
          entry.key,
          entry.value, currentProfile
        ),
    ],
  );
}


Widget _buildColorTile(context, Color color, String grade, Map<String, dynamic> gradeDetails, CloudProfile currentProfile) {
  
  return ListTile(
    title: Text('${capitalize(grade)} Grade',
    style: const TextStyle(),
    ),
    tileColor: color,
    subtitle:
         currentProfile.gradingSystem == "V_grade" ? Text(
            'Min: ${allGrading[gradeDetails['min']]!["v_grade"]} Max: ${allGrading[gradeDetails['max']]!["v_grade"]}')
            : Text('Min: ${allGrading[gradeDetails['min']]!["french"]} Max: ${allGrading[gradeDetails['max']]!["french"]}'),
        
    onTap: () {},
  );
}

