import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart'
    show
        allGrading,
        arrowDict,
        difficultyLevelToArrow,
        getArrowFromNumberAndColor,
        nameToColor;
import 'package:seven_x_c/constants/slide_up_const.dart';
import 'package:seven_x_c/helpters/bonus_functions.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:vector_math/vector_math_64.dart' as VM;

Container slideUpCollapsContent() {
  return Container(
      decoration: BoxDecoration(
          color: slideUpCollapsColour, borderRadius: slideUpCollapsRadius),
      child: Center(
        child: slideUpText,
      ));
}

Center slideUpContent(
    CloudSettings currentSettings,
    CloudProfile currentProfile,
    Iterable<CloudBoulder> allBoulders,
    TransformationController controller,
    constraints) {
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
            slideUpPanelHeadling,
            const SizedBox(height: 16.0),
            // Creating a column of widgets based on colorEntries
            for (var entry in colorEntries)
              gradingExpansionList(entry, currentProfile, currentSettings,
                  colourSplit, colourBoulderSplit, controller, constraints)
          ],
        ),
      ),
    ),
  );
}

ExpansionTile gradingExpansionList(
    MapEntry<String, dynamic> entry,
    CloudProfile currentProfile,
    CloudSettings currentSettings,
    Map<String, int> colourSplit,
    Map<String, List<dynamic>> colourBoulderSplit,
    TransformationController controller,
    constraints) {
  return ExpansionTile(
    title: Text(capitalize(entry.key)),
    subtitle: Text(
      currentProfile.gradingSystem.toLowerCase() == "coloured"
          ? '${allGrading[entry.value['min']]!["french"]} - ${allGrading[entry.value['max']]!["french"]}'
          : '${allGrading[entry.value['min']]![currentProfile.gradingSystem.toLowerCase()]} - ${allGrading[entry.value['max']]![currentProfile.gradingSystem.toLowerCase()]}',
    ),
    leading: gradingColourCircle(currentSettings, entry, colourSplit),
    children: [
      for (CloudBoulder boulder in colourBoulderSplit[entry.key] ?? [])
        boulderTitleLayout(
            currentProfile, currentSettings, boulder, controller, constraints)
    ],
  );
}

SizedBox gradingColourCircle(CloudSettings currentSettings,
    MapEntry<String, dynamic> entry, Map<String, int> colourSplit) {
  return SizedBox(
    width: 40,
    height: 40,
    child: Stack(alignment: Alignment.center, children: [
      Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: nameToColor(currentSettings.settingsGradeColour![entry.key]),
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
            color: entry.key != "black" ? Colors.black : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize:
                (entry.key.length > 3 || entry.key.contains('/')) ? 10 : 15,
          ),
        ),
        strokeColor: Colors.white,
      ))
    ]),
  );
}

ListTile boulderTitleLayout(
    CloudProfile currentProfile,
    CloudSettings currentSettings,
    CloudBoulder boulder,
    TransformationController controller,
    constraints) {
      bool topped = false;
      if (boulder.climberTopped != null &&
              boulder.climberTopped!.containsKey(currentProfile.userID)) {topped = true;}
  return ListTile(
      leading: holdColourCircle(currentSettings, boulder, currentProfile),
      title: Text(boulder.wall),
      tileColor: topped ? Colors.white : Colors.grey,
      subtitle: Text(topped
          ? boulder.climberTopped![currentProfile.userID]["flashed"]!=null ? "Flashed": "Attempts for top: ${boulder.climberTopped![currentProfile.userID]["attempts"].toString()}"
          : boulder.setter),
      onTap: () {
        // Assuming boulder.x and boulder.y are the positions of the boulder
        zoomToBoulder(boulder, controller, constraints);
      });
}

SizedBox holdColourCircle(CloudSettings currentSettings, CloudBoulder boulder,
    CloudProfile currentProfile) {
  String? gradingShow = "";

  if (currentProfile.gradingSystem.toLowerCase() == "coloured") {
    try {
      gradingShow = arrowDict()[boulder.gradeDifficulty]!["arrow"];
    } on Error {
      gradingShow = getArrowFromNumberAndColor(
          boulder.gradeNumberSetter, boulder.gradeColour);
    }
  } else {
    gradingShow = allGrading[boulder.gradeNumberSetter]![
        currentProfile.gradingSystem.toLowerCase()];
  }
  return SizedBox(
    width: 40,
    height: 40,
    child: Stack(alignment: Alignment.center, children: [
      Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: nameToColor(
              currentSettings.settingsHoldColour![boulder.holdColour]),
        ),
      ),
      Center(
          child: OutlineText(
        Text(
          gradingShow ?? "",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: boulder.holdColour != "black" ? Colors.black : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: (gradingShow!.length > 3 || gradingShow.contains('/'))
                ? 10
                : 15,
          ),
        ),
        strokeColor: Colors.white,
      ))
    ]),
  );
}

Future<void> zoomToBoulder(CloudBoulder boulder,
    TransformationController controller, constraints) async {
  final Offset center = Offset((boulder.cordX * constraints.maxWidth),
      (boulder.cordY * constraints.maxHeight));
  controller.value = Matrix4.identity()
    ..translate(-center.dx * 2.0, -center.dy * 2.5)
    ..scale(3.0);
}
