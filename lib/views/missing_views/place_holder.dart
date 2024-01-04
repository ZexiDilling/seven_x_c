import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: GymView(),
  ));
}

class GymView extends StatefulWidget {
  const GymView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GymViewState createState() => _GymViewState();
}

class _GymViewState extends State<GymView> {
  final List<CircleInfo> circles = [];
  final double minZoomThreshold = 0; // Adjust this threshold as needed
  final TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DTU Climbing"),
        backgroundColor: const Color.fromRGBO(255, 17, 0, 1),
      ),
      body: GestureDetector(
        onScaleEnd: (details) {
          if (_controller.value.getMaxScaleOnAxis() >= minZoomThreshold) {
            // Handle zoom in
          } else {
            // Handle zoom out
          }
        },
        onTapUp: (details) {
          // Only add circles when zoomed in
          if (_controller.value.getMaxScaleOnAxis() >= minZoomThreshold) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final position = renderBox.globalToLocal(details.globalPosition);
            setState(() {
              circles.add(CircleInfo(
                centerX: position.dx,
                centerY: position.dy,
                data: CircleData(
                  title: "Circle ${circles.length + 1}",
                  description: "This is some information about the circle.",
                ),
              ));
            });
          }
        },
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.5,
          maxScale: 5.0,
          child: CustomPaint(
            painter: GymPainter(circles),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background/dtu_climbing.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GymPainter extends CustomPainter {
  final List<CircleInfo> circles;

  GymPainter(this.circles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final circle in circles) {
      canvas.drawCircle(
        Offset(circle.centerX, circle.centerY),
        20.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleInfo {
  final double centerX;
  final double centerY;
  final CircleData data;

  CircleInfo({
    required this.centerX,
    required this.centerY,
    required this.data,
  });
}

class CircleData {
  final String title;
  final String description;

  CircleData({
    required this.title,
    required this.description,
  });
}
