import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudLocationData {
  // Basic info to find the data based on the Gym or User
  final String locationID;
  final String locationNameID;

  // Tracking information
  final bool bouldering;
  final bool sport;
  final bool trad;
  final bool isGym;
  final double locationXCordinate;
  final double locationYCordinate;
  final String locationCountry;
  final String? locationAdresse;
  final String? locationHomepage;
  final String? locationEmail;
  final String? locationInfo;
  final String? locationAccess;

  const CloudLocationData(
    this.locationNameID,
    this.bouldering,
    this.sport,
    this.trad,
    this.isGym,
    this.locationXCordinate,
    this.locationYCordinate,
    this.locationCountry,
    this.locationAdresse,
    this.locationHomepage,
    this.locationEmail,
    this.locationInfo,
    this.locationAccess, {
    required this.locationID,
  });

  CloudLocationData.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : locationID = snapshot.id,
        locationNameID = snapshot.data()[locationCountryFieldName] as String,
        bouldering = snapshot.data()[boulderingFieldName] as bool,
        sport = snapshot.data()[sportFieldName] as bool,
        trad = snapshot.data()[tradFieldName] as bool,
        isGym = snapshot.data()[isGymFieldName] as bool,
        locationXCordinate =
            snapshot.data()[locationXCordinateFieldName] as double,
        locationYCordinate =
            snapshot.data()[locationYCordinateFieldName] as double,
        locationCountry = snapshot.data()[locationCountryFieldName] as String,
        locationAdresse = snapshot.data()[locationAdresseFieldName] as String?,
        locationHomepage =
            snapshot.data()[locationHomepageFieldName] as String?,
        locationEmail = snapshot.data()[locationEmailFieldName] as String?,
        locationInfo = snapshot.data()[locationInfoFieldName] as String?,
        locationAccess = snapshot.data()[locationAccessFieldName] as String?;
}
