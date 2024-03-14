import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';

@immutable
class CloudGymLocation {
  // Basic info to find the data based on the Gym or User
  final String locationID;
  final String locationNameID;

  // Tracking information
  final String? info;
  final bool bouldering;
  final bool rope;
  final bool indoor;
  final bool outdoor;
  final double locationXCordinate;
  final double locationYCordinate;
  final String country;
  final String? adresse;

  const CloudGymLocation(
    this.locationNameID,
    this.info,
    this.bouldering,
    this.rope,
    this.indoor,
    this.outdoor,
    this.locationXCordinate,
    this.locationYCordinate,
    this.country,
    this.adresse, {
    required this.locationID,
  });

  CloudGymLocation.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : locationID = snapshot.id,
        locationNameID = snapshot.data()[locationNameIDFieldName] as String,
        info = snapshot.data()[infoFieldName] as String?,
        bouldering = snapshot.data()[boulderingFieldName] as bool,
        rope = snapshot.data()[ropeFieldName] as bool,
        indoor = snapshot.data()[indoorFieldName] as bool,
        outdoor = snapshot.data()[outdoorFieldName] as bool,
        locationXCordinate =
            snapshot.data()[locationXCordinateFieldName] as double,
        locationYCordinate =
            snapshot.data()[locationYCordinateFieldName] as double,
        country = snapshot.data()[countryFieldName] as String,
        adresse = snapshot.data()[adresseFieldName] as String?;
}
