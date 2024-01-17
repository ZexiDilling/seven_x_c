import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

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
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('Show All Boulders'),
                  Checkbox(
                    value: showAllBouldersFilter,
                    onChanged: (value) {
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
                    onChanged: (value) {
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
              ),
            ),
            ListTile(
              title: DropdownButton<String>(
                value: selectedRule,
                onChanged: (String? newValue) {
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
                onChanged: (String? newValue) {
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
                  onChanged: (value) {
                    setState(() {
                      includeFinals = value!;
                    });
                  },
                ),
                const Text('Finals?'),
                Checkbox(
                  value: includeSemiFinals,
                  onChanged: (value) {
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
                  compService.updatComp(
                      compID: currentComp.compID,
                      signUpActiveComp: signUp,
                      maxParticipants: maxPP);
                },
                child: const Text('Apply Changes'),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    compService.updatComp(
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
                        endDateComp: Timestamp.now(), compResults: rankings);
                      // updateClimbers(
                      //     currentComp: currentComp,
                      //     userService: userService,
                      //     compRanking: rankings);
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

Map<String, dynamic> compRanking(CloudComp currentComp) {
  Map<String, dynamic> ranking = {
    "total": {},
    "male": {},
    "female": {},
  };

  // Create a list of user IDs sorted by points and tops
  List<String> sortedUserIds = currentComp.climbersComp!.keys.toList();
  sortedUserIds.sort((a, b) {
    int pointsA = currentComp.climbersComp![a]["points"] ?? 0;
    int pointsB = currentComp.climbersComp![b]["points"] ?? 0;
    int topsA = currentComp.climbersComp![a]["tops"] ?? 0;
    int topsB = currentComp.climbersComp![b]["tops"] ?? 0;

    if (pointsB != pointsA) {
      return pointsB.compareTo(pointsA); // Sort by points
    } else {
      return topsB.compareTo(topsA); // If points are equal, sort by tops
    }
  });
  int rankTotal = 1;
  int rankMale = 1;
  int rankFemale = 1;
  // Update ranking based on sorted user IDs
  sortedUserIds.forEach((userId) {
    String gender = currentComp.climbersComp![userId]["gender"].toLowerCase();
    double points = currentComp.climbersComp![userId]["points"].toDouble() ?? 0.0;
    int tops = currentComp.climbersComp![userId]["tops"] ?? 0;

    // Update total ranking
    ranking["total"]![userId] = {
      "points": points,
      "tops": tops,
      "rank": rankTotal
    };
    rankTotal++;
    // Update gender-specific ranking
    if (gender == "male") {
      ranking["male"]![userId] = {
        "points": points,
        "tops": tops,
        "rank": rankMale
      };
      rankMale++;
    } else if (gender == "female") {
      ranking["female"]![userId] = {
        "points": points,
        "tops": tops,
        "rank": rankFemale
      };
      rankFemale++;
    }
  });

  return ranking;
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
