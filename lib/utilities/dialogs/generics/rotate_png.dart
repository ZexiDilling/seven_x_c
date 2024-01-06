
import 'package:flutter/material.dart';


class RotatedImage extends StatelessWidget {
  final String imagePath;

  const RotatedImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 90 * (3.14159265358979323846264338327950288 / 180),
      child: Image.asset(imagePath),
    );
  }
}