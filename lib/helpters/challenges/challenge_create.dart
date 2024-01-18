import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/challenge_const.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/challenges/cloud_challenges.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';

Future<void> createChallengeDialog(
    BuildContext context,
    setState,
    FirebaseCloudStorage challengeService,
    FirebaseCloudStorage boulderService,
    CloudBoulder boulder,
    CloudProfile currentProfile) async {
  TextEditingController challengeNameController = TextEditingController();
  TextEditingController challengeDescriptionController =
      TextEditingController();
  bool challengeCounter = false;
  String selectedChallengeType = challengeTypes[0];
  int challengeDifficulty = 3;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create New Challenge'),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: challengeNameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedChallengeType,
                    onChanged: (String? value) {
                      setState(() {
                        selectedChallengeType = value ?? challengeTypes[0];
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
                  child: Row(
                    children: [
                      Checkbox(
                        value: challengeCounter,
                        onChanged: (value) {
                          setState(() {
                            challengeCounter = !challengeCounter;
                          });
                        },
                      ),
                      const Text("Challenge Counter"),
                    ],
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: challengeDescriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (challengeNameController.text.isEmpty ||
                      challengeDescriptionController.text.isEmpty) {
                    showErrorDialog(
                        context, "Please fill out all the information");
                  } else {
                    double challengePoint;
                    if (challengeCounter) {
                      challengePoint =
                          (defaultChallengePoints / counterDivider);
                    } else {
                      challengePoint = defaultChallengePoints;
                    }
                    CloudChallenge currentChallenge =
                        await challengeService.createNewChallenge(
                      challengeName: challengeNameController.text,
                      challengeCreator: currentProfile.userID,
                      challengeType: selectedChallengeType,
                      challengeDescription: challengeDescriptionController.text,
                      challengeOwnPoints: challengePoint,
                      challengeBoulders: [boulder.boulderID],
                      challengeCounter: challengeCounter,
                      challengeCounterRunning: 0,
                      challengeDifficulty: challengeDifficulty,
                    );
                    boulderService.updatBoulder(
                        boulderID: boulder.boulderID,
                        boulderChallenges: updateBoulderChallengeMap(
                            currentChallenge: currentChallenge, completed: false));

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Create Challenge'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
