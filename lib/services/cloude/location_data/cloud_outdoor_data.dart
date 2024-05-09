import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudOutdoorData {
  // Basic info to find the data based on the Gym or User
  final String outdoorDataID;
  final String outdoorDataNameID;

  final Map<String, dynamic>? outdoorSections;

  // Tracking information
  final Map<String, dynamic>? outdoorDataClimbers;
  final Map<String, dynamic>? outdoorDataBoulders;
  final Map<String, dynamic>? outdoorDataBouldersTopped;
  final Map<String, dynamic>? outdoorDataRoutes;
  final Map<String, dynamic>? outdoorDataRoutesTopped;

  const CloudOutdoorData(
    this.outdoorDataNameID,
    this.outdoorSections,
    this.outdoorDataClimbers,
    this.outdoorDataBoulders,
    this.outdoorDataBouldersTopped,
    this.outdoorDataRoutes,
    this.outdoorDataRoutesTopped, {
    required this.outdoorDataID,
  });

  CloudOutdoorData.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : outdoorDataID = snapshot.id,
        outdoorDataNameID =
            snapshot.data()[outdoorDataNameIDFieldName] as String,
        outdoorSections =
            snapshot.data()[outdoorSectionsFieldName] as Map<String, dynamic>?,
        outdoorDataClimbers = snapshot.data()[outdoorDataClimbersFieldName]
            as Map<String, dynamic>?,
        outdoorDataBoulders = snapshot.data()[outdoorDataBouldersFieldName]
            as Map<String, dynamic>?,
        outdoorDataBouldersTopped =
            snapshot.data()[outdoorDataBouldersToppedFieldName]
                as Map<String, dynamic>?,
        outdoorDataRoutes = snapshot.data()[outdoorDataRoutesFieldName]
            as Map<String, dynamic>?,
        outdoorDataRoutesTopped = snapshot
            .data()[outdoorDataRoutesToppedFieldName] as Map<String, dynamic>?;
}
