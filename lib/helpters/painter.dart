import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';

class GymPainter extends CustomPainter {
  final Iterable<CloudBoulder> allBoulders;
  final CloudProfile currentProfile;

  GymPainter(this.allBoulders, this.currentProfile);

  @override
  void paint(Canvas canvas, Size size) {
    for (final CloudBoulder boulder in allBoulders) {
      bool userTopped = false;
      bool userFlashed = false;
      DateTime setBoulderDate = boulder.setDateBoulder.toDate();
      DateTime? updatedBoulderDate = boulder.updateDateBoulder?.toDate();
      DateTime currentTime = DateTime.now();
      Color? gradeColour = boulder.hiddenGrade == true
          ? hiddenGradeColor
          : getColorFromName(capitalizeFirstLetter(boulder.gradeColour));
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
        ..color =
            (userTopped ? gradeColour?.withOpacity(fadeEffect) : gradeColour!)!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(boulder.cordX, boulder.cordY),
        userTopped | userFlashed
            ? boulderRadius * boulderRadiusTopped
            : boulderRadius,
        paint,
      );

      if (setBoulderDate.add(newBoulderNotice).isAfter(currentTime) && (!userTopped && !userFlashed)) {
        final Paint glowPaint = Paint()
          ..color =
              newBoulderColour.withOpacity(0.2) 
          ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal, 0.2); 

        canvas.drawCircle(
          Offset(boulder.cordX, boulder.cordY),
          boulderRadius +
              boulderNewGlowRadius, // Adjust the radius to make the glow more visible
          glowPaint,
        );
      } else if (updatedBoulderDate != null &&
          updatedBoulderDate.add(updateBoulderNotice).isAfter(currentTime) && (!userTopped && !userFlashed)) {
        final Paint glowPaint = Paint()
          ..color = updatedBoulderColour
              .withOpacity(0.2) 
          ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal, 0.2); 

        canvas.drawCircle(
          Offset(boulder.cordX, boulder.cordY),
          boulderRadius +
              boulderUpdatedGlowRadius, // Adjust the radius to make the glow more visible
          glowPaint,
        );
      }
      ;
      final Paint outlinePaint = Paint()
        ..color =
            (userTopped ? holdColour?.withOpacity(fadeEffect) : holdColour!)!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(boulder.cordX, boulder.cordY),
        userTopped | userFlashed
            ? boulderRadius * boulderRadiusTopped
            : boulderRadius,
        outlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
