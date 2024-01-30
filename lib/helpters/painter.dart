import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';

class GymPainter extends CustomPainter {
  final BuildContext context;
  final Iterable<CloudBoulder> allBoulders;
  final CloudProfile currentProfile;
  final CloudSettings currentSettings;
  double currentScale;
  bool compView;

  GymPainter(this.context, this.allBoulders, this.currentProfile, this.currentSettings,
      this.currentScale, this.compView);
  DateTime currentTime = DateTime.now();
  @override
  void paint(Canvas canvas, Size size) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    Map<String, int> bouldersCountPerWall = {};
    Map<String, int> userToppedBouldersCountPerWall = {};
    Map<String, Color> glowForMapMarkings = {};
    bool userTopped = false;
    bool userFlashed = false;
    Color? glowColour;
    if (currentScale >= boulderSingleShow) {
      for (final CloudBoulder boulder in allBoulders) {
        DateTime setBoulderDate = boulder.setDateBoulder.toDate();
        DateTime? updatedBoulderDate = boulder.updateDateBoulder?.toDate();
        Color? gradeColour = boulder.hiddenGrade == true
            ? hiddenGradeColor
            : nameToColor(currentSettings.settingsHoldColour![boulder.gradeColour.toLowerCase()]);
        Color? holdColour = nameToColor(currentSettings.settingsHoldColour![boulder.holdColour]);
        double fadeEffect = 0.3;

        if (boulder.climberTopped != null &&
            boulder.climberTopped is Map<String, dynamic>) {
          if (boulder.climberTopped!.containsKey(currentProfile.userID)) {
            var userClimbInfo = boulder.climberTopped?[currentProfile.userID];
            userFlashed = userClimbInfo['flashed'] ?? false;
            userTopped = userClimbInfo['topped'] ?? false;
          }
        } else {
          userFlashed = false;
          userTopped = false;
        }

        double centerX = boulder.cordX * screenWidth;
        double centerY = boulder.cordY * screenHeight;
        // Fade if user have topped the boulder
        final Paint paint = Paint()
          ..color =
              (userTopped ? gradeColour.withOpacity(fadeEffect) : gradeColour)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(centerX, centerY),
          userTopped | userFlashed
              ? boulderRadius * boulderRadiusTopped
              : boulderRadius,
          paint,
        );

        if (compView && boulder.boulderName != null) {
          // set-up central boulder count
          final TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: "${boulder.boulderName}}",
              style: const TextStyle(
                color: Colors.black, // Set your desired text color
                fontSize: 10.0, // Set your desired font size
              ),
            ),
            textDirection: TextDirection.ltr,
          );

          textPainter.layout();
        }

        // set glowcolour depending on status of the boulder
        if (setBoulderDate.add(newBoulderNotice).isAfter(currentTime) &&
            (!userTopped && !userFlashed)) {
          glowColour = newBoulderColour;
        } else if (updatedBoulderDate != null &&
            updatedBoulderDate.add(updateBoulderNotice).isAfter(currentTime) &&
            (!userTopped && !userFlashed)) {
          glowColour = updatedBoulderColour;
        }

        // Give problems a glow, unless they have been topped
        if (glowColour != null && !userTopped) {
          final Paint glowPaint = Paint()
            ..color = newBoulderColour.withOpacity(0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2);

          canvas.drawCircle(
            Offset(centerX, centerY),
            boulderRadius +
                boulderNewGlowRadius, // Adjust the radius to make the glow more visible
            glowPaint,
          );
        }

        // Colour the outer ring
        final Paint outlinePaint = Paint()
          ..color =
              (userTopped ? holdColour.withOpacity(fadeEffect) : holdColour)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(
          Offset(centerX, centerY),
          userTopped | userFlashed
              ? boulderRadius * boulderRadiusTopped
              : boulderRadius,
          outlinePaint,
        );
      }

      // setup for showing counter when zoomed out
    } else {
      for (final CloudBoulder boulder in allBoulders) {
        DateTime setBoulderDate = boulder.setDateBoulder.toDate();
        DateTime? updatedBoulderDate = boulder.updateDateBoulder?.toDate();

        // Count boulders per WallRegion
        bouldersCountPerWall[boulder.wall] =
            (bouldersCountPerWall[boulder.wall] ?? 0) + 1;

        if (boulder.climberTopped != null &&
            boulder.climberTopped is Map<String, dynamic>) {
          if (boulder.climberTopped!.containsKey(currentProfile.userID)) {
            var userClimbInfo = boulder.climberTopped?[currentProfile.userID];
            userFlashed = userClimbInfo['flashed'] ?? false;
            userTopped = userClimbInfo['topped'] ?? false;
          }
        }

        if (userFlashed || userTopped) {
          userToppedBouldersCountPerWall[boulder.wall] =
              (userToppedBouldersCountPerWall[boulder.wall] ?? 0) + 1;
        }

        if (setBoulderDate.add(newBoulderNotice).isAfter(currentTime) &&
            (!userTopped && !userFlashed)) {
          glowForMapMarkings[boulder.wall] = newBoulderColour;
        } else if (updatedBoulderDate != null &&
            updatedBoulderDate.add(updateBoulderNotice).isAfter(currentTime) &&
            (!userTopped && !userFlashed)) {
          if (glowForMapMarkings[boulder.wall] == null) {
            glowForMapMarkings[boulder.wall] = updatedBoulderColour;
          }
        }
      }

      for (final WallRegion wall in wallRegions) {
        final int bouldersCountTotal = bouldersCountPerWall[wall.wallName] ?? 0;
        // final int boulderCountMissing = bouldersCountTotal -
        //     (userToppedBouldersCountPerWall[wall.wallName] ?? 0);
        final int boulderCountTopped =
            userToppedBouldersCountPerWall[wall.wallName] ?? 0;

        final Offset center = Offset(
          (wall.wallXMax + wall.wallXMin) / 2,
          (wall.wallYMaX + wall.wallYMin) / 2,
        );

        // setup main circle
        final Paint paint = Paint()
          ..color = Colors.red // Set your desired color
          ..style = PaintingStyle.fill;

        // set-up central boulder count
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text:
                "${boulderCountTopped.toString()} / ${bouldersCountTotal.toString()}",
            style: const TextStyle(
              color: Colors.black, // Set your desired text color
              fontSize: 10.0, // Set your desired font size
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        final Offset textOffset = Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        );

        // Draw Main circle
        canvas.drawCircle(
            center, boulderRadiusDrawing, paint); // Set the radius as needed

        // Name of the wall
        textPainter.paint(canvas, textOffset);
        final TextPainter wallNamePainter = TextPainter(
          text: TextSpan(
            text: wall.wallName == "Onyd" ? "DYNO" : wall.wallName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        // Set name for the wall
        wallNamePainter.layout();
        final Offset wallNameOffset = Offset(
          center.dx + boulderRadiusDrawing + 5, // Adjust the spacing
          center.dy - wallNamePainter.height / 2,
        );
        if (wall.wallName == "Onyd") {
          canvas.save();
          canvas.translate(wallNameOffset.dx, wallNameOffset.dy);
          canvas.rotate(-pi); // Rotate the text by 180 degrees (pi radians)
          wallNamePainter.paint(
              canvas,
              Offset(
                  -wallNamePainter.width,
                  -wallNamePainter.height /
                      2)); // Adjust the placement after rotation
          canvas.restore();
        } else {
          wallNamePainter.paint(canvas, wallNameOffset);
        }

        // add glow if needed
        if (glowForMapMarkings[wall.wallName] != null) {
          final Paint glowPaint = Paint()
            ..color = newBoulderColour.withOpacity(0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2);

          canvas.drawCircle(
            center,
            boulderRadiusDrawing + boulderNewGlowRadius,
            glowPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
