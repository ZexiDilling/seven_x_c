import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

class CloudChallenge {
  final String challengeID;
  final String challengeName;
  final String challengeCreator;
  final String challengeType;
  final String challengeDescription;
  final double challengeOwnPoints;
  final List challengeBoulders;
  final bool challengeCounter;
  int? challengeCounterRunning;
  final int challengeDifficulty;

  CloudChallenge(
      this.challengeName,
      this.challengeCreator,
      this.challengeType,
      this.challengeDescription,
      this.challengeOwnPoints,
      this.challengeBoulders,
      this.challengeCounter,
      this.challengeCounterRunning,
      this.challengeDifficulty,
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
        challengeBoulders = snapshot.data()[challengeBouldersFieldName] as List,
        challengeCounter = snapshot.data()[challengeCounterFieldName] as bool,
        challengeCounterRunning =
            snapshot.data()[challengeCounterRunningFieldName] as int?,
        challengeDifficulty =
            snapshot.data()[challengeDifficultyFieldName] as int;
}
