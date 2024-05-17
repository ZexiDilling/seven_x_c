import 'package:flutter/material.dart';

List<Offset> currentRegionVertices = []; // To store vertices of the current region



// Function to draw the regions/polygons on the map
Widget drawRegions(background) {
  return Stack(
    children: [
      // Existing background image
      Image.asset(
        background, // Path to your JPG file
        fit: BoxFit.fill,
      ),
      // Draw polygons dynamically using the vertices
      CustomPaint(
        painter: RegionPainter(currentRegionVertices),
      ),
    ],
  );
}

// CustomPainter to draw the regions/polygons
class RegionPainter extends CustomPainter {
  final List<Offset> vertices;

  RegionPainter(this.vertices);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (vertices.length > 1) {
      Path path = Path();
      path.moveTo(vertices.first.dx, vertices.first.dy);
      for (int i = 1; i < vertices.length; i++) {
        path.lineTo(vertices[i].dx, vertices[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
