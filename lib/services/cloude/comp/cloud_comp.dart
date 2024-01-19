import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudComp {
  final String compID;
  final String compName;
  final String compStyle;
  final String compRules;
  final bool startedComp;
  final bool activeComp;
  final bool signUpActiveComp;
  final Timestamp startDateComp;
  final Timestamp endDateComp;
  final int? maxParticipants;
  final bool includeZones;
  final bool includeFinals;
  final bool includeSemiFinals;
  final bool genderBased;
  final Map<String, dynamic>? bouldersComp;
  final Map<String, dynamic>? climbersComp;
  final Map<String, dynamic>? compResults;
  final List? randomWinners;

  const CloudComp(
    this.compName,
    this.compStyle,
    this.compRules,
    this.startedComp,
    this.activeComp,
    this.signUpActiveComp,
    this.startDateComp,
    this.endDateComp,
    this.maxParticipants,
    this.includeZones,
    this.includeFinals,
    this.includeSemiFinals,
    this.genderBased,
    this.bouldersComp,
    this.climbersComp,
    this.compResults, this.randomWinners, {
    required this.compID,
  });

  CloudComp.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : compID = snapshot.id,
        compName = snapshot.data()[compNameFieldName] as String,
        compStyle = snapshot.data()[compStyleFieldName] as String,
        compRules = snapshot.data()[compRulesFieldName] as String,
        startedComp = snapshot.data()[startedCompFieldName] as bool,
        activeComp = snapshot.data()[activeCompFieldName] as bool,
        signUpActiveComp = snapshot.data()[signUpActiveCompFieldName] as bool,
        startDateComp = snapshot.data()[startDateCompFieldName] as Timestamp,
        endDateComp = snapshot.data()[endDateCompFieldName] as Timestamp,
        maxParticipants = snapshot.data()[maxParticipantsFieldName] as int,
        includeZones = snapshot.data()[includeZonesFieldName] as bool,
        includeFinals = snapshot.data()[includeFinalsFieldName] as bool,
        includeSemiFinals = snapshot.data()[includeSemiFinalsFieldName] as bool,
        genderBased = snapshot.data()[genderBasedFieldName] as bool,
        bouldersComp =
            snapshot.data()[bouldersCompFieldName] as Map<String, dynamic>?,
        climbersComp =
            snapshot.data()[climbersCompFieldName] as Map<String, dynamic>?,
        compResults =
            snapshot.data()[compResultsFieldName] as Map<String, dynamic>?,
            randomWinners = snapshot.data()[randomWinnersFieldName] as List?;
}
