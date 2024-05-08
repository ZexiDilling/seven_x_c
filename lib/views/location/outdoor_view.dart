import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/gym_data/cloud_settings.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

class OutdoorView extends StatefulWidget {
  const OutdoorView({super.key});
  @override
  State<OutdoorView> createState() => _OutdoorView();
}

class _OutdoorView extends State<OutdoorView> {
  late CloudProfile? currentProfile;
  CloudSettings? currentSettings;
  CloudOutdoorData? currentGymData;
  bool profileLoaded = false;
  late final FirebaseCloudStorage _fireBaseService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _fireBaseService = FirebaseCloudStorage();

    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    // await _initSettings();
    await _initOutdoorData();
    // _initSettingData();
  }

  Future<CloudProfile?> _initializeCurrentProfile() async {
    await for (final profiles
        in _fireBaseService.getUser(userID: userId.toString())) {
      if (profiles.isNotEmpty) {
        final CloudProfile profile = profiles.first;
        if (profile.displayName == "") {
          Navigator.of(context).popAndPushNamed(profileSettings);
        } else {
          setState(() {
            currentProfile = profile;
            profileLoaded = true;
          });
        }
      } else {
        Navigator.of(context).popAndPushNamed(profileSettings);
      }
      return currentProfile;
    }
    return null;
  }

  Future<CloudOutdoorData?> _initOutdoorData() async {
    final CloudOutdoorData? tempOutdoorData =
        await _fireBaseService.getOutdoorData(currentProfile!.settingsID);
    setState(() {
      currentOutdoorData = tempOutdoorData;
    });
    return currentOutdoorData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
