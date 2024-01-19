import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/comp_const.dart';
import 'package:seven_x_c/helpters/comp/comp_calculations.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/comp/random_getter.dart';

bool showAllBouldersFilter = false;

Drawer compDrawer(
  BuildContext context,
  setState,
  CloudComp currentComp,
  FirebaseCloudStorage compService,
  FirebaseCloudStorage userService,
) {
  String selectedRule = currentComp.compRules;
  String selectedStyle = currentComp.compStyle;
  bool includeFinals = currentComp.includeFinals;
  bool includeSemiFinals = currentComp.includeSemiFinals;
  bool signUp = currentComp.signUpActiveComp;
  int maxPP = currentComp.maxParticipants!;
  TextEditingController maxController =
      TextEditingController(text: currentComp.maxParticipants?.toString());
  return Drawer(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: 5000,
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: AppBar(
                title: const Text('Comp Settings'),
              ),
            ),
            ListTile(
              title: TextField(
                controller: TextEditingController(text: currentComp.compName),
                decoration: const InputDecoration(labelText: 'Comp Name'),
                onChanged: (value) {},
                enabled: !currentComp.activeComp,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('Show All Boulders'),
                  Checkbox(
                    value: showAllBouldersFilter,
                    onChanged: currentComp.activeComp
                        ? null
                        : (value) {
                            setState(() {
                              showAllBouldersFilter = !showAllBouldersFilter;
                            });
                          },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('Sign Up Active'),
                  Checkbox(
                    value: signUp,
                    onChanged: currentComp.activeComp
                        ? null
                        : (value) {
                            signUp = !signUp;
                          },
                  ),
                ],
              ),
            ),
            ListTile(
              title: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Max Participants'),
                onChanged: (value) {
                  try {
                    maxPP = int.parse(value);
                  } catch (e) {
                    maxPP = currentComp.maxParticipants!;
                  }
                },
                enabled: !currentComp.activeComp,
              ),
            ),
            ListTile(
              title: DropdownButton<String>(
                value: selectedRule,
                onChanged: currentComp.activeComp
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedRule = newValue!;
                        });
                      },
                items: compRulesOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: DropdownButton<String>(
                value: selectedStyle,
                onChanged: currentComp.activeComp
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedStyle = newValue!;
                        });
                      },
                items: compStylesOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: includeFinals,
                  onChanged: currentComp.activeComp
                      ? null
                      : (value) {
                          setState(() {
                            includeFinals = value!;
                          });
                        },
                ),
                const Text('Finals?'),
                Checkbox(
                  value: includeSemiFinals,
                  onChanged: currentComp.activeComp
                      ? null
                      : (value) {
                          setState(() {
                            includeSemiFinals = value!;
                          });
                        },
                ),
                const Text('Semi Finals?'),
              ],
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  currentComp.activeComp
                      ? null
                      : compService.updatComp(
                          compID: currentComp.compID,
                          signUpActiveComp: signUp,
                          maxParticipants: maxPP);
                },
                child: const Text('Apply Changes'),
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: ()  {
                  List climbers = [];
                  if (currentComp.climbersComp != null &&
                      currentComp.climbersComp!.isNotEmpty) {
                    climbers =
                        currentComp.climbersComp!.values.toList();

                  }
                  showRadomGetter(context, climbers: climbers);
                },
                child: const Text('Random Picker'),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    currentComp.activeComp
                        ? null
                        : compService.updatComp(
                            compID: currentComp.compID, startedComp: true);
                  },
                  child: const Text('Start Comp'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> rankings = compRanking(currentComp);
                    compService.updatComp(
                        compID: currentComp.compID,
                        startedComp: false,
                        signUpActiveComp: false,
                        activeComp: false,
                        endDateComp: Timestamp.now(),
                        compResults: rankings);
                    updateClimbers(
                        currentComp: currentComp,
                        userService: userService,
                        compRanking: rankings);
                  },
                  child: const Text('End Comp'),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

void updateClimbers({
  required CloudComp currentComp,
  required FirebaseCloudStorage userService,
  required Map<String, dynamic> compRanking,
}) {
  currentComp.climbersComp!.forEach((userId, climbInfo) async {
    CloudProfile currentProfile =
        (await userService.getUser(userID: userId).first).first;

    userService.updateUser(
      currentProfile: currentProfile,
      compProfile: updateCompProfile(
        currentComp: currentComp,
        currentProfile: currentProfile,
        ranking: compRanking,
        existingData: currentProfile.compProfile,
      ),
    );
  });
}
