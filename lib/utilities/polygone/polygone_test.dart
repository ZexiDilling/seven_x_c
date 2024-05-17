
// Function to perform point-in-polygon test
import 'package:flutter/material.dart';

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