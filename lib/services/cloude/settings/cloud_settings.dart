import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudSettings {
  final String settingsID;
  final String settingsName;
  final String settingsCountry;
  final String settingsLocation;
  final String settingsStyle;
  final List settingsActivites;
  final List settingsGradingSystem;
  
  // Indoor gyms
  final bool? settingsHoldsFollowsGrade;
  final Map<String, dynamic>? settingsHoldColour;
  final Map<String, dynamic>? settingsGradeColour;
  final Map<String, dynamic>? settingsColorToGrade;
  final Map<String, dynamic>? settingsWallRegions;

  const CloudSettings(
    this.settingsName,
    this.settingsCountry,
    this.settingsLocation,
    this.settingsStyle,
    this.settingsActivites,
    this.settingsGradingSystem,
    this.settingsHoldsFollowsGrade,
    this.settingsHoldColour,
    this.settingsGradeColour,
    this.settingsColorToGrade,
    this.settingsWallRegions, {
    required this.settingsID,
  });

  CloudSettings.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : settingsID = snapshot.id,
        settingsName = snapshot.data()[settingsNameFieldName] as String,
        settingsCountry = snapshot.data()[settingsCountryFieldName] as String,
        settingsLocation = snapshot.data()[settingsLocationFieldName] as String,
        settingsStyle = snapshot.data()[settingsStyleFieldName] as String,
        settingsActivites = snapshot.data()[settingsActivitesFieldName] as List,
        settingsGradingSystem =
            snapshot.data()[settingsGradingSystemFieldName] as List,
        settingsHoldsFollowsGrade =
            snapshot.data()[settingsHoldsFollowsGradeFieldName] as bool?,
        settingsHoldColour =
            snapshot.data()[settingsHoldColourFieldName] as Map<String, dynamic>?,
        settingsGradeColour =
            snapshot.data()[settingsGradeColourFieldName] as Map<String, dynamic>?,
        settingsColorToGrade = snapshot.data()[settingsColorToGradeFieldName]
            as Map<String, dynamic>?,
        settingsWallRegions = snapshot.data()[settingsWallRegionsFieldName]
            as Map<String, dynamic>?;
}


