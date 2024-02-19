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
  final int gradeDifficulty;
  final bool topOut;
  final bool active;
  final bool hiddenGrade;
  final bool compBoulder;
  final bool gotZone;
  final double? setterPoint;
  final String? boulderName;
  final Map<String, dynamic>? boulderChallenges;
  final Map<String, dynamic>? gradeNumberClimbers;
  Map<String, dynamic>? climberTopped;
  final Timestamp setDateBoulder;
  final Timestamp? updateDateBoulder;

  CloudBoulder(
    this.boulderChallenges,
    this.gradeNumberClimbers,
    this.climberTopped,
    this.setter,
    this.cordX,
    this.cordY,
    this.wall,
    this.holdColour,
    this.gradeColour,
    this.gradeNumberSetter,
    this.gradeDifficulty,
    this.topOut,
    this.active,
    this.hiddenGrade,
    this.compBoulder,
    this.gotZone,
    this.setterPoint,
    this.boulderName,
    this.setDateBoulder,
    this.updateDateBoulder, {
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
        gradeDifficulty = snapshot.data()[gradingSetterFieldName] as int,
        topOut = snapshot.data()[topOutFieldName] as bool,
        active = snapshot.data()[activeFieldName] as bool,
        hiddenGrade = snapshot.data()[hiddenGradeFieldName] as bool,
        compBoulder = snapshot.data()[compBoulderFieldName] as bool,
        gotZone = snapshot.data()[gotZoneFieldName] as bool,
        setterPoint = snapshot.data()[setterPointFieldName] as double?,
        boulderName = snapshot.data()[boulderNameFieldName] as String?,
        setDateBoulder = snapshot.data()[setDateBoulderFiledName] as Timestamp,
        updateDateBoulder =
            snapshot.data()[updateDateBoulderFiledName] as Timestamp,
        boulderChallenges = snapshot.data()[boulderChallengesFieldName]
            as Map<String, dynamic>?,
        gradeNumberClimbers =
            snapshot.data()[gradingClimbersFieldName] as Map<String, dynamic>?,
        climberTopped =
            snapshot.data()[climberToppedFieldName] as Map<String, dynamic>?;
}
