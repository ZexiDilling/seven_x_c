import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/challenge_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/challenges/cloud_challenges.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

void showAddExisitingChallenge(
    BuildContext context, Stream<Iterable<CloudChallenge>> challengeStream,
    {required FirebaseCloudStorage fireBaseService,
    required CloudBoulder boulder,
    required CloudProfile currentProfile}) {
  bool editing = false;
  TextEditingController creatorController = TextEditingController();
  TextEditingController discrptionController = TextEditingController();
  String selectedChallengeType = challengeTypes[0];

  bool challengeCounter = false;
  int challengeDifficulty = 1;
  CloudChallenge? currentChallenge;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder(
        stream: challengeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final Iterable<CloudChallenge> challenges = snapshot.data!;
            final List<String> challengeList = challenges.isNotEmpty
                ? challenges
                    .map((challenges) => challenges.challengeName)
                    .toList()
                : [];
            final Map<String, dynamic> challengeNameToID = challenges.isNotEmpty
                ? Map.fromEntries(challenges.map((challenge) =>
                    MapEntry(challenge.challengeName, challenge)))
                : {};

            String selectedChallenge =
                challengeList.isNotEmpty ? challengeList.first : '';

            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("Add Challenge"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Challenge Dropdown
                      DropdownButton<String>(
                        value: selectedChallenge,
                        onChanged: (String? newValue) {
                          setState(() async {
                            selectedChallenge = newValue ?? '';
                            if (newValue != null) {
                              String creatorId =
                                  challengeNameToID[selectedChallenge]
                                      ?.challengeCreator;
                              Stream<Iterable<CloudProfile>> tempProfile =
                                  fireBaseService.getUser(userID: creatorId);
                              CloudProfile? creator =
                                  (await tempProfile.first).first;
                              creatorController.text = creator.displayName;
                              discrptionController.text =
                                  challengeNameToID[selectedChallenge]
                                          ?.challengeDescription ??
                                      '';

                              challengeCounter =
                                  challengeNameToID[selectedChallenge]
                                          ?.challengeCounter ??
                                      false;
                              challengeDifficulty =
                                  challengeNameToID[selectedChallenge]
                                          ?.challengeDifficulty ??
                                      1;
                              currentChallenge =
                                  challengeNameToID[selectedChallenge];
                            }
                          });
                        },
                        items: challengeList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      // Challenge Creator Field
                      TextFormField(
                        controller: creatorController,
                        decoration: const InputDecoration(
                            labelText: 'Challenge Creator'),
                        enabled: editing,
                        // Add controller and onChanged as needed
                      ),
                      const SizedBox(height: 10),
                      // Challenge Counter Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: challengeCounter, // Set the actual value
                            onChanged: (value) {
                              editing
                                  ? challengeCounter = !challengeCounter
                                  : null;
                              // Handle checkbox change
                            },
                          ),
                          const Text('Challenge Counter'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Challenge Difficulty Field
                      Slider(
                        value: challengeDifficulty.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: arrowDict()[challengeDifficulty]!['difficulty'],
                        onChanged: (double value) {
                          setState(() {
                            challengeDifficulty = value.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedChallengeType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedChallengeType =
                                  value ?? challengeTypes[0];
                            });
                          },
                          items: challengeTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Type',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: discrptionController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                          ),
                          enabled: editing,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Add button
                  ElevatedButton(
                    onPressed: () {
                      if (currentChallenge != null) {
                        if (editing) {
                          fireBaseService.updateChallenge(
                            challengeID: currentChallenge!.challengeID,
                            challengeCreator: creatorController.text,
                            challengeType: selectedChallengeType,
                            challengeDescription: discrptionController.text,
                            challengeCounter: challengeCounter,
                            challengeDifficulty: challengeDifficulty,
                          );
                        } else {
                          fireBaseService.updateChallenge(
                              challengeID: currentChallenge!.challengeID,
                              challengeBoulders: updateChallengeBoulderList(
                                  boulder: boulder,
                                  existingData:
                                      currentChallenge!.challengeBoulders));

                          fireBaseService.updateBoulder(
                              boulderID: boulder.boulderID,
                              boulderChallenges: updateBoulderChallengeMap(
                                removeUser: false,
                                  currentChallenge: currentChallenge!,
                                  completed: false,
                                  existingData: boulder.boulderChallenges));
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: editing ? const Text("Update") : const Text("Add"),
                  ),
                  Visibility(
                    visible: currentProfile.isAdmin,
                    child: IconButton(
                      onPressed: () {
                        editing = !editing;
                      },
                      icon: Icon(editing
                          ? IconManager.doneEdditing
                          : IconManager.editing),
                    ),
                  ),
                ],
              );
            });
          }
        },
      );
    },
  );
}
