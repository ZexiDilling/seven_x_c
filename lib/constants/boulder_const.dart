import 'package:flutter/material.dart' show Color, Colors;

const String constSettingsID = "dtu_climbing";

const String dtuSetterName = "DTU Setter Team";
const String guestSetter = "Guest Setter";

// drawing Constants
const double boulderRadius = 2.5;
const double boulderRadiusDrawing = 15;
const double boulderRadiusTopped = 0.80;
const double boulderSingleShow = 2.5;
const double boulderNewGlowRadius = 5.0;
const double boulderUpdatedGlowRadius = boulderNewGlowRadius;
const Color hiddenGradeColor = Colors.white;
const Color newBoulderColour = Colors.purple;
const Color updatedBoulderColour = Colors.yellow;
const Color deactivateBoulderColor = Colors.red;
// const Color soonToBeStrippedColour = Colors.red;   Not used yet
const double minBoulderDistance = 10.0;

// Points
const double defaultSetterPoints = 10;
const double defaultBoulderPoints = 10;
const double newFlashGradeMultiplier = 0.25;
const double newToppedGradeMultiplier = 0.5;
const double decrementMultipler = 0.2;
const double repeatsMultiplier = 0.5;
const double repeatsDecrement = 0.1;

// Time constants
const Duration newBoulderNotice = Duration(days: 3);
const Duration updateBoulderNotice = Duration(days: 2);
// const Duration soonToBeStripped = Duration(days: 3);   Not used yet
