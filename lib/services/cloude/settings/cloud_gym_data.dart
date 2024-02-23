import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudGymData {
  // Basic info to find the data based on the Gym or User
  final String gymDataID;
  final String gymDataNameID;

  // Tracking information
  final Map<String, dynamic>? gymDataClimbers;
  final Map<String, dynamic>? gymDataBoulders;
  final Map<String, dynamic>? gymDataBouldersTopped;
  final Map<String, dynamic>? gymDataRoutesTopped;

  const CloudGymData(
    this.gymDataNameID,
    this.gymDataClimbers,
    this.gymDataBoulders,
    this.gymDataBouldersTopped,
    this.gymDataRoutesTopped, {
    required this.gymDataID,
  });

  CloudGymData.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : gymDataID = snapshot.id,
        gymDataNameID = snapshot.data()[gymDataNameIDFieldName] as String,
        gymDataClimbers =
            snapshot.data()[gymDataClimbersFieldName] as Map<String, dynamic>?,
        gymDataBoulders =
            snapshot.data()[gymDataBouldersFieldName] as Map<String, dynamic>?,
        gymDataBouldersTopped = snapshot.data()[gymDataBouldersToppedFieldName]
            as Map<String, dynamic>?,
        gymDataRoutesTopped = snapshot.data()[gymDataRoutesToppedFieldName]
            as Map<String, dynamic>?;
}
