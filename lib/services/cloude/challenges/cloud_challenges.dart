import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudChallenge {
  final String challengeID;
  final String challengeName;
  final String challengeCreator;
  final String challengeType;
  final String challengeDescription;
  final double challengeOwnPoints;
  final Array challengeBoulders;
  final bool challengeCounter;

  CloudChallenge(
      this.challengeName,
      this.challengeCreator,
      this.challengeType,
      this.challengeDescription,
      this.challengeOwnPoints,
      this.challengeBoulders,
      this.challengeCounter,
      {required this.challengeID});

  CloudChallenge.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  )   : challengeID = snapshot.id,
        challengeName = snapshot.data()[challengeNameFieldName] as String,
        challengeCreator = snapshot.data()[challengeCreatorFieldName] as String,
        challengeType = snapshot.data()[challengeTypeFieldName] as String,
        challengeDescription =
            snapshot.data()[challengeDescriptionFieldName] as String,
        challengeOwnPoints =
            snapshot.data()[challengeOwnPointsFieldName] as double,
        challengeBoulders =
            snapshot.data()[challengeBouldersFieldName] as Array,
        challengeCounter = snapshot.data()[challengeCounterFieldName] as bool;
}
