import 'package:flutter/material.dart';

// slide Up Collaps settings:
Color slideUpCollapsColour = Colors.blueGrey;
Text slideUpText =
    const Text("Boulder Info", style: TextStyle(color: Colors.white));
double slideUpMinHeight = 50;
double slideUpMaxHeight = 0.5;

BorderRadiusGeometry slideUpCollapsRadius = const BorderRadius.only(
  topLeft: Radius.circular(24.0),
  topRight: Radius.circular(24.0),
);

// Slide up Panel settings:
Text slideUpPanelHeadling = const Text(
  'Boulder Overview',
  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
);
