// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/helpters/general_const_and_info.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final TextEditingController _displayNameController = TextEditingController();
  String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;
  late final FirebaseCloudStorage fireBaseService;
  late CloudProfile? currentProfile;

  bool _isSetter = false;
  bool _isAdmin = false;
  bool _isAnonymous = false;
  String _gradingSystem = 'Coloured';
  bool profileExist = false;
  String settingsID = constSettingsID;

  @override
  void initState() {
    super.initState();
    fireBaseService = FirebaseCloudStorage();
    _initializeCurrentProfile();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      _initializeCurrentProfile();
    });
  }

  Future<CloudProfile?> _initializeCurrentProfile() async {
    await for (final profiles
        in fireBaseService.getUser(userID: userId.toString())) {
      if (profiles.isNotEmpty) {
        currentProfile = profiles.first;
        setState(() {
          currentProfile = currentProfile;
        _isAdmin = currentProfile!.isAdmin;
        _isSetter = currentProfile!.isSetter;
        _isAnonymous = currentProfile!.isAnonymous;
        _gradingSystem = currentProfile!.gradingSystem;
        _displayNameController.text = currentProfile!.displayName;
        });
        

        
        
        profileExist = true;
        
        return currentProfile;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Nick-name'),
              ),
              const SizedBox(height: 16.0),
              Text(userEmail),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {}, // todo Need this to work.
                child: const Text('Change Password'),
              ),
              const SizedBox(height: 16.0),
              Visibility(
                visible: _isSetter,
                child: Row(
                  children: [
                    Checkbox(
                      value: _isSetter,
                      onChanged: (value) {
                        setState(() {
                          _isSetter = value ?? false;
                        });
                      },
                    ),
                    const Text('Setter'),
                  ],
                ),
              ),
              Visibility(
                visible: _isAdmin,
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAdmin,
                      onChanged: (value) {
                        setState(() {
                          _isAdmin = value ?? false;
                        });
                      },
                    ),
                    const Text('Admin'),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                  ),
                  const Text('Anonymous'),
                  IconButton(
                    onPressed: () {
                      _showAnonymousInfo(context);
                    },
                    icon: const Icon(IconManager.info),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Grading: '),
                  DropdownButton<String>(
                    value: _gradingSystem,
                    onChanged: (String? newValue) async {
                      setState(() {
                        _gradingSystem = newValue ?? 'Coloured';
                      });
                      await fireBaseService.updateUser(
                          currentProfile: currentProfile!,
                          gradingSystem: _gradingSystem);
                    },
                    items: <String>['Coloured', 'French', 'V_Grade']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    onPressed: () {
                      _showGradingSystemInfo(context);
                    },
                    icon: const Icon(IconManager.info),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final profiles = await fireBaseService
                          .getUser(userID: userId.toString())
                          .first;
                      final currentProfile =
                          profiles.isNotEmpty ? profiles.first : null;
                      await _createOrUpdateUserProfile(currentProfile);
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Reset'),
                            content: const Text(
                                'Are you sure you want to Reset All your points?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await fireBaseService.updateUser(
                                      currentProfile: currentProfile!,
                                      boulderPoints: 0.0,
                                      setterPoints: 0.0,
                                      challengePoints: 0.0,
                                    );
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    context
                                        .read<AuthBloc>()
                                        .add(const AuthEventLogOut());
                                  } catch (error) {
                                    showErrorDialog(context, error.toString());
                                  }
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Reset Points"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                                'Are you sure you want to deleted your profile?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await fireBaseService.deleteUser(
                                        ownerUserId: userId);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    context
                                        .read<AuthBloc>()
                                        .add(const AuthEventLogOut());
                                  } catch (error) {
                                    showErrorDialog(context, error.toString());
                                  }
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Delete Profile"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createOrUpdateUserProfile(currentProfile) async {
    try {
      final displayName = _displayNameController.text.trim();
      final email = userEmail.trim();
      if (displayName.isEmpty) {
        showErrorDialog(context, "Missing Nick-Name");
      } else if (email.isEmpty) {
        showErrorDialog(context, "Missing E-mail");
      } else if (await fireBaseService.isDisplayNameUnique(
          displayName, userId)) {
        if (profileExist) {
          // User exists, update the user profile information
          await fireBaseService.updateUser(
            currentProfile: currentProfile,
            displayName: _displayNameController.text,
            isSetter: _isSetter,
            isAdmin: _isAdmin,
            isAnonymous: _isAnonymous,
            gradingSystem: _gradingSystem,
          );
          Navigator.of(context).pop();
        } else {
          // User does not exist, create a new user
          await fireBaseService.createNewUser(
              boulderPoints: 0.0,
              setterPoints: 0.0,
              challengePoints: 0.0,
              isSetter: _isSetter,
              isAdmin: _isAdmin,
              settingsID: settingsID,
              isAnonymous: _isAnonymous,
              email: userEmail,
              displayName: _displayNameController.text,
              gradingSystem: _gradingSystem,
              maxToppedGrade: 0,
              maxFlahsedGrade: 0,
              createdDateProfile: Timestamp.now(),
              updateDateProfile: Timestamp.now(),
              userID: userId);

          Navigator.of(context).popAndPushNamed(gymView);
        }
      } else {
        showErrorDialog(context, "Nick Name is already");
      }
    } catch (e) {
      showErrorDialog(context, "Failed to save or update profile");
    }
  }

  void _showAnonymousInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Anonymous Mode'),
          content: const Text('Will not show your Nick-name on any lists besides comp.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showGradingSystemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grading System'),
          content: Text("This is the gradesystem you will see on the boulder. \n"
                              "Coloured: Will show an arrow inside the grading colour circle for how hard the boulder is within the grade. \n"
                              "French: Will show the French grade inside the grading colour circle. \n"
                              "V-Grade: Will show the French grade inside the grading colour circle. \n"
                              "Missing a grading system, let us know on $contactMail" ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
