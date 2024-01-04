import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudBoulder {
  final String boulderID;
  final String setter;
  final double cordX;
  final double cordY;
  final String wall;
  final String holdColour;
  final String gradeColour;
  final int gradeNumberSetter;
  final bool topOut;
  final bool active;
  final Map<String, dynamic>? challenge;
  final Map<String, dynamic>? gradeNumberClimbers;
  final Map<String, dynamic>? climberTopped;

  CloudBoulder(
    this.challenge,
    this.gradeNumberClimbers,
    this.climberTopped,
    this.setter,
    this.cordX,
    this.cordY,
    this.wall,
    this.holdColour,
    this.gradeColour,
    this.gradeNumberSetter,
    this.topOut,
    this.active, {
    required this.boulderID,
  });

  CloudBoulder.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : boulderID = snapshot.id,
        setter = snapshot.data()[setterFieldName] as String,
        cordX = snapshot.data()[coordinateXFieldName] as double,
        cordY = snapshot.data()[coordinateYFieldName] as double,
        wall = snapshot.data()[wallFieldName] as String,
        holdColour = snapshot.data()[holdColourFieledName] as String,
        gradeColour = snapshot.data()[gradeColourFieledName] as String,
        gradeNumberSetter = snapshot.data()[gradingSetterFieldName] as int,
        topOut = snapshot.data()[topOutFieldName] as bool,
        active = snapshot.data()[activefieldName] as bool,
        challenge =
            snapshot.data()[challengeFieldName] as Map<String, dynamic>?,
        gradeNumberClimbers =
            snapshot.data()[gradingClimbersFieldName] as Map<String, dynamic>?,
        climberTopped =
            snapshot.data()[climberToppedFieldName] as Map<String, dynamic>?;
}
