// Function to create a polygon representing a region
import 'package:flutter/material.dart';


// List<Offset> createRegionPolygon(Region region) {
//   // Define the vertices of the polygon based on region boundaries
//   List<Offset> vertices = [];
//   vertices.add(Offset(region['regionXMin'] as double, region['regionYMin'] as double));
//   vertices.add(Offset(region['regionXMin'] as double, region['regionYMax'] as double));
//   vertices.add(Offset(region['regionXMax'] as double, region['regionYMax'] as double));
//   vertices.add(Offset(region['regionXMax'] as double, region['regionYMin'] as double));
//   return vertices;
// }


// Function to perform point-in-polygon test
bool isPointInPolygon(Offset point, List<Offset> polygon) {
  int i, j = polygon.length - 1;
  bool oddNodes = false;

  for (i = 0; i < polygon.length; i++) {
    if (polygon[i].dy < point.dy && polygon[j].dy >= point.dy ||
        polygon[j].dy < point.dy && polygon[i].dy >= point.dy) {
      if (polygon[i].dx +
              (point.dy - polygon[i].dy) /
                  (polygon[j].dy - polygon[i].dy) *
                  (polygon[j].dx - polygon[i].dx) <
          point.dx) {
        oddNodes = !oddNodes;
      }
    }
    j = i;
  }

  return oddNodes;
}