import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/outdoor_info.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';

// List<Offset> currentRegionVertices = []; // To store vertices of the current region
List<Offset> currentRegionVertices = [
  const Offset(50, 50),
  const Offset(100, 100),
  const Offset(150, 50)
];

// Function to draw the regions/polygons on the map
Widget drawRegions(String background) {
  return Stack(
    children: [
      // Existing background image
      Image.asset(
        background, // Path to your JPG file
        fit: BoxFit.fill,
      ),
      // Draw polygons dynamically using the vertices
    ],
  );
}

class RegionPainter extends CustomPainter {
  final CloudSettings currentSettings;
  final List<OutsideRegion> outsideRegions;
  final dynamic constraints;
  final bool overviewMap;
  final bool detailMap;
  final String currentLocation;
  final Iterable<Map<String, dynamic>?> allBoulders;
  final String gradingSystem;

  RegionPainter(
    this.currentSettings,
    this.outsideRegions,
    this.constraints,
    this.overviewMap,
    this.detailMap,
    this.currentLocation,
    this.allBoulders,
    this.gradingSystem,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final selectedPaint = Paint()
      ..color = Colors.green // Change color for selected region
      ..style = PaintingStyle.stroke // Fill the region
      ..strokeWidth = 2;

    final unselectedPaint = Paint()
      ..color = Colors.blue // Change color for unselected region
      ..style = PaintingStyle.stroke // Fill the region
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    Map<String, int> boulderPerRegion = {};
    Map<String, int> boulderPerSerction = {};
    // bool userTopped = false;

    // paint Boulders
    if (overviewMap) {
      for (var boulder in allBoulders) {
        if (boulder != null && boulder.isNotEmpty) {
          String boulderId = boulder.keys.first;
          Map<String, dynamic> boulderDetails = boulder[boulderId];
          String fullLocation = boulderDetails['location'].toLowerCase();
          int locationLength = fullLocation.length;
          String location = fullLocation.substring(0, locationLength - 1);

          if (boulderPerRegion.containsKey(location)) {
            boulderPerRegion[location] = (boulderPerRegion[location]! + 1);
          } else {
            boulderPerRegion[location] = 1;
          }
        }
      }
    } else {
      if (detailMap) {
        for (var boulder in allBoulders) {
          if (boulder != null && boulder.isNotEmpty) {
            String boulderId = boulder.keys.first;
            Map<String, dynamic> boulderDetails = boulder[boulderId];
            String fullLocation = boulderDetails['location'].toLowerCase();
            int locationLength = fullLocation.length;
            String section = fullLocation.substring(locationLength - 1);

            if (boulderPerSerction.containsKey(section)) {
              boulderPerSerction[fullLocation] =
                  (boulderPerSerction[fullLocation]! + 1);
            } else {
              boulderPerSerction[fullLocation] = 1;
            }
          }
        }
      } else {
        for (var boulder in allBoulders) {
          if (boulder != null && boulder.isNotEmpty) {
            String boulderId = boulder.keys.first;
            Map<String, dynamic> boulderDetails = boulder[boulderId];
            // String fullLocation = boulderDetails['location'].toLowerCase();
            // int locationLength = fullLocation.length;
            // Assuming the section is always one character at the end
            // String location = fullLocation.substring(0, locationLength - 1);
            // String section = fullLocation.substring(locationLength - 1);

            Color gradeColour = nameToColor(currentSettings
                .settingsHoldColour![boulderDetails["gradeColour"]]);
            int grade = boulderDetails["gradeNumberSetter"];
            double centerX = boulderDetails["cordX"] * constraints.maxWidth;
            double centerY = boulderDetails["cordY"] * constraints.maxHeight;

            // draw circle
            final Paint paint = Paint()
              ..color = gradeColour
              ..style = PaintingStyle.fill;
            canvas.drawCircle(
              Offset(centerX, centerY),
              boulderRadius * 2,
              paint,
            );
            // write grade

            final TextPainter textPainter = TextPainter(
              text: TextSpan(
                text: allGrading[grade]![gradingSystem],
                style: TextStyle(
                    color:
                        boulderDetails["gradeColour"].toLowerCase() == "black"
                            ? Colors.white
                            : Colors.black,
                    fontSize: 1.6,
                    fontWeight: FontWeight.bold),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();

            textPainter.paint(
              canvas,
              Offset(centerX - textPainter.width / 2,
                  centerY - textPainter.height / 4),
            );
          }
        }
      }
    }

    // Paint regions

    for (var region in outsideRegions) {
      final paint = region.overviewMap ? selectedPaint : unselectedPaint;
      Path path = Path();
      List<Offset>? regionPolygon;
      if (overviewMap) {
        regionPolygon = region.regionPolygonOverview;
        if (regionPolygon.length > 2) {
          path.moveTo(regionPolygon.first.dx * constraints.maxWidth,
              regionPolygon.first.dy * constraints.maxHeight);
          for (int i = 1; i < regionPolygon.length; i++) {
            path.lineTo(regionPolygon[i].dx * constraints.maxWidth,
                regionPolygon[i].dy * constraints.maxHeight);
          }
        }
      } else {
        if (region.regionLocation == currentLocation) {
          regionPolygon = region
              .regionPolygonSublocation; // Use regionPolygonOverview for drawing
          if (regionPolygon.length > 2) {
            path.moveTo(regionPolygon.first.dx * constraints.maxWidth,
                regionPolygon.first.dy * constraints.maxHeight);
            for (int i = 1; i < regionPolygon.length; i++) {
              path.lineTo(regionPolygon[i].dx * constraints.maxWidth,
                  regionPolygon[i].dy * constraints.maxHeight);
            }
          }
        }
      }
      path.close();

      canvas.drawPath(path, paint);
      // Write regionNumber in the middle of the polygon
      if (regionPolygon != null) {
        var boulderCounter = region.regionIndicator;
        if (overviewMap) {
          if (boulderPerRegion[region.regionID] != null) {
            boulderCounter =
                boulderPerRegion[region.regionID.toLowerCase()].toString();
          } else {
            boulderCounter = region.regionIndicator;
          }
        } else {
          String fullLocation = region.regionID.toLowerCase();

          if (boulderPerSerction[fullLocation] != null) {
            // int locationLength = region.regionID.length;

            // String sectionLetter = fullLocation.substring(locationLength - 1);
            boulderCounter = boulderPerSerction[fullLocation].toString();
          } else {
            boulderCounter = region.regionIndicator;
          }
        }

        final centerX =
            regionPolygon.map((offset) => offset.dx).reduce((a, b) => a + b) /
                regionPolygon.length;
        final centerY =
            regionPolygon.map((offset) => offset.dy).reduce((a, b) => a + b) /
                regionPolygon.length;

        textPainter.text = TextSpan(
          // text: region.regionIndicator.toString(),
          text: boulderCounter.toString(),
          style: const TextStyle(color: Colors.red, fontSize: 15),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX * constraints.maxWidth - textPainter.width / 2,
              centerY * constraints.maxHeight - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
