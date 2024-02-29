import 'package:flutter/material.dart';

import 'package:seven_x_c/constants/boulder_const.dart'
    show hiddenGradeColorEntry, hiddenGradeColorName;
import 'package:seven_x_c/constants/boulder_info.dart'
    show allGrading, arrowDict, getArrowFromNumberAndColor, nameToColor;
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/constants/slide_up_const.dart';
import 'package:seven_x_c/helpters/bonus_functions.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';


Container slideUpCollapsContent() {
  return Container(
      decoration: BoxDecoration(
          color: slideUpCollapsColour, borderRadius: slideUpCollapsRadius),
      child: Center(
        child: slideUpText,
      ));
}



SizedBox gradingColourCircle(CloudSettings currentSettings,
    MapEntry<String, dynamic> entry, Map<String, int> colourSplit) {
  return SizedBox(
    width: 40,
    height: 40,
    child: Stack(alignment: Alignment.center, children: [
      Container(
        width: 40.0,
        height: 40.0,
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
                (entry.key.length > 3 || entry.key.contains('/')) ? 25 : 15,
          ),
        ),
        strokeColor: Colors.white,
      ))
    ]),
  );
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
