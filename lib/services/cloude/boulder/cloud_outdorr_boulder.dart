import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudOutdoorBoulder {
  final String outdoorBoulderID;
  final double outdoorCordX;
  final double outdoorCordY;
  final String outdoorBoulderDataNameID;
  final String outdoorBoulderSections;
  final String outdoorGradeColour;
  final int outdoorGradeNumberSetter;
  final int outdoorGradeDifficulty;
  final bool outdoorTopOut;
  final bool outdoorActive;
  final List? outdoorTags;
  final String? outdoorBoulderName;
  final String? outdoorSetter;
  final int? outdoorRating;
  final Map<String, dynamic>? outdoorGradeNumberClimbers;
  final Map<String, dynamic>? outdoorRatingClimbers;
  final Map<String, dynamic>? outdoorClimberTopped;
  final Timestamp? outdoorSetDateBoulder;
  final String? outdoorBoulderInfo;

  CloudOutdoorBoulder(
    this.outdoorCordX,
    this.outdoorCordY,
    this.outdoorBoulderDataNameID,
    this.outdoorBoulderSections,
    this.outdoorGradeColour,
    this.outdoorGradeNumberSetter,
    this.outdoorGradeDifficulty,
    this.outdoorTopOut,
    this.outdoorActive,
    this.outdoorTags,
    this.outdoorBoulderName,
    this.outdoorSetter,
    this.outdoorRating,
    this.outdoorGradeNumberClimbers,
    this.outdoorRatingClimbers,
    this.outdoorClimberTopped,
    this.outdoorSetDateBoulder,
    this.outdoorBoulderInfo, {
    required this.outdoorBoulderID,
  });

  CloudOutdoorBoulder.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : outdoorBoulderID = snapshot.id,
        outdoorCordX = snapshot.data()[outdoorCordXFieldName] as double,
outdoorCordY = snapshot.data()[outdoorCordYFieldName] as double,
outdoorBoulderDataNameID = snapshot.data()[outdoorBoulderDataNameIDFieldName] as String,
outdoorBoulderSections = snapshot.data()[outdoorBoulderSectionsFieldName] as String,
outdoorGradeColour = snapshot.data()[outdoorGradeColourFieldName] as String,
outdoorGradeNumberSetter = snapshot.data()[outdoorGradeNumberSetterFieldName] as int,
outdoorGradeDifficulty = snapshot.data()[outdoorGradeDifficultyFieldName] as int,
outdoorTopOut = snapshot.data()[outdoorTopOutFieldName] as bool,
outdoorActive = snapshot.data()[outdoorActiveFieldName] as bool,
outdoorTags = snapshot.data()[outdoorTagsFieldName] as List?,
outdoorBoulderName = snapshot.data()[outdoorBoulderNameFieldName] as String?,
outdoorSetter = snapshot.data()[outdoorSetterFieldName] as String?,
outdoorRating = snapshot.data()[outdoorRatingFieldName] as int?,
outdoorGradeNumberClimbers = snapshot.data()[outdoorGradeNumberClimbersFieldName] as Map<String, dynamic>?,
outdoorRatingClimbers = snapshot.data()[outdoorRatingClimbersFieldName] as Map<String, dynamic>?,
outdoorClimberTopped = snapshot.data()[outdoorClimberToppedFieldName] as Map<String, dynamic>?,
outdoorSetDateBoulder = snapshot.data()[outdoorSetDateBoulderFieldName] as Timestamp?,
outdoorBoulderInfo  = snapshot.data()[outdoorBoulderInfoFieldName] as String?;
}
