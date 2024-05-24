import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/outdoor_info.dart';

// List<Offset> currentRegionVertices = []; // To store vertices of the current region
List<Offset> currentRegionVertices = [Offset(50, 50), Offset(100, 100), Offset(150, 50)];

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
  final List<OutsideRegion> outsideRegions; final dynamic constraints;

  RegionPainter(this.outsideRegions, this.constraints);

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

    for (var region in outsideRegions) {
      final paint = region.overviewMap ? selectedPaint : unselectedPaint;

      final regionPolygon = region.regionPolygonOverview; // Use regionPolygonOverview for drawing
      if (regionPolygon.length > 2) {
        Path path = Path();
        path.moveTo(regionPolygon.first.dx * constraints.maxWidth, regionPolygon.first.dy * constraints.maxHeight);
        for (int i = 1; i < regionPolygon.length; i++) {
          path.lineTo(regionPolygon[i].dx * constraints.maxWidth, regionPolygon[i].dy * constraints.maxHeight);
        }
        path.close();

        canvas.drawPath(path, paint);

        // Write regionNumber in the middle of the polygon
        final centerX = regionPolygon.map((offset) => offset.dx).reduce((a, b) => a + b) / regionPolygon.length;
        final centerY = regionPolygon.map((offset) => offset.dy).reduce((a, b) => a + b) / regionPolygon.length;

        textPainter.text = TextSpan(
          text: region.regionIndicator.toString(),
          style: TextStyle(color: Colors.red, fontSize: 15),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX * constraints.maxWidth - textPainter.width / 2, centerY * constraints.maxHeight - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

