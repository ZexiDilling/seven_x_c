import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart'
    show allGrading, nameToColor;
import 'package:seven_x_c/helpters/bonus_functions.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';

Container slideUpCollapsContent() {
  return Container(
      color: Colors.blueGrey,
      child: const Center(
        child: Text("Boulder Info", style: TextStyle(color: Colors.white)),
      ));
}

Center slideUpContent(CloudSettings currentSettings,
    CloudProfile currentProfile, Iterable<CloudBoulder> allBoulders) {
  Map<String, int> colourSplit = {};
  Map<String, List> colourBoulderSplit = {};
  for (final CloudBoulder boulder in allBoulders) {
    if (boulder.active) {
      colourBoulderSplit[boulder.gradeColour] = [
        ...(colourBoulderSplit[boulder.gradeColour] ?? []),
        boulder
      ];

      colourSplit[boulder.gradeColour] =
          (colourSplit[boulder.gradeColour] ?? 0) + 1;
    }
  }


  Map<String, dynamic>? settingsGradeColour =
      currentSettings.settingsGradeColour;

  List<MapEntry<String, dynamic>> colorEntries =
      settingsGradeColour!.entries.toList(growable: false);

  // Sort the color entries based on the "min" value
  colorEntries.sort((a, b) => a.value['min'].compareTo(b.value['min']));

  return Center(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boulder Overview',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Creating a column of widgets based on colorEntries
            for (var entry in colorEntries)
              ExpansionTile(
                title: Text(capitalize(entry.key)),
                subtitle: Text(
                  currentProfile.gradingSystem.toLowerCase() == "coloured"
                      ? '${allGrading[entry.value['min']]!["french"]} - ${allGrading[entry.value['max']]!["french"]}'
                      : '${allGrading[entry.value['min']]![currentProfile.gradingSystem.toLowerCase()]} - ${allGrading[entry.value['max']]![currentProfile.gradingSystem.toLowerCase()]}',
                ),
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: nameToColor(currentSettings.settingsGradeColour![
                            entry.key]), // Use the color from entry.key
                      ),
                    ),
                    Center(
                        child: OutlineText(
                      Text(
                        colourSplit[entry.key] != null
                            ? colourSplit[entry.key].toString()
                            : "0",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: entry.key != "black"
                              ? Colors.black
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              (entry.key.length > 3 || entry.key.contains('/'))
                                  ? 10
                                  : 15,
                        ),
                      ),
                      strokeColor: Colors.white,
                    ))
                  ]),
                ),
                children: [
                  for (CloudBoulder boulder
                      in colourBoulderSplit[entry.key] ?? [])
                    ListTile(
                      title: Text('${boulder.gradeNumberSetter}'),
                      
                    )
                ],
              )
          ],
        ),
      ),
    ),
  );
}
