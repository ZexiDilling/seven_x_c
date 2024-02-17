import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_charts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late CloudProfile? currentProfile;
  CloudSettings? currentSettings;
  late final FirebaseCloudStorage firebaseService;
  TimePeriod selectedTimePeriod = TimePeriod.week;
  String get userId => AuthService.firebase().currentUser!.id;
  late bool isShowingMainData;
  Map<int, String> gradeNumberToColour = {};
  String chartSelection = "maxGrade";

  @override
  void initState() {
    firebaseService = FirebaseCloudStorage();
    _initializeData();
    super.initState();

    isShowingMainData = true;
    _updateFirebaseData();
  }

  _updateFirebaseData() async {
    if (currentProfile!.climbedBoulders != null) {
      var boulderIDs = currentProfile!.climbedBoulders!.keys.toList();

      boulderIDs.sort((a, b) {
        DateTime dateA =
            DateTime.parse(currentProfile!.climbedBoulders![a]!['date']);
        DateTime dateB =
            DateTime.parse(currentProfile!.climbedBoulders![b]!['date']);
        return dateA.compareTo(dateB);
      });

      int maxFlahsedGrade = 0;
      int maxToppedGrade = 0;

      for (var boulderID in boulderIDs) {
        Stream<Iterable<CloudBoulder>> boulderStream =
            firebaseService.getBoulder(boulderID: boulderID);
        Iterable<CloudBoulder> boulders = await boulderStream.first;
        CloudBoulder currentBoulder = boulders.first;
        int gradeNumberSetter =
            currentProfile!.climbedBoulders![boulderID]["gradeNumber"];
        bool flashed = currentProfile!.climbedBoulders![boulderID]["flashed"];
        if (flashed && gradeNumberSetter > maxFlahsedGrade) {
          maxFlahsedGrade = gradeNumberSetter;
        }
        if (gradeNumberSetter > maxToppedGrade) {
          maxToppedGrade = gradeNumberSetter;
        }
        DateTime toppedDate =
            currentProfile!.climbedBoulders![boulderID]["date"];
        double boulderPoints = currentProfile!.climbedBoulders![boulderID]["boulderPoints"];

        firebaseService.updateBoulder(
            boulderID: currentBoulder.boulderID,
            climberTopped: updateClimberToppedMap(
                currentProfile: currentProfile!,
                boulderPoints: boulderPoints,
                toppedDate: toppedDate,
                existingData: currentBoulder.climberTopped));

        firebaseService.updateUser(
            currentProfile: currentProfile!,
            dateBoulderTopped: updateDateBoulderToppedMap(
                boulder: currentBoulder,
                userID: currentProfile!.userID,
                flashed: flashed,
                maxFlahsedGrade: maxFlahsedGrade,
                maxToppedGrade: maxToppedGrade));
        currentProfile!.climbedBoulders!.remove(boulderID);
      }
    }
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    await _initSettings();
    _initSettingData();
  }

  _initSettingData() {
    if (currentSettings!.settingsGradeColour != null) {
      for (var entry in currentSettings!.settingsGradeColour!.entries) {
        String name = entry.key
            .toLowerCase(); // Convert name to lowercase for consistency
        Map<String, dynamic> data = entry.value;
        int maxGrade = data["max"] ?? 0;

        gradeNumberToColour[maxGrade] = name;
      }
    } else {
      String currentColour = getNextColor(null);
      int iteration = 0;
      for (int gradeCounter in allGrading.keys) {
        gradeNumberToColour[gradeCounter] = currentColour;

        if (iteration % 3 == 2) {
          currentColour = getNextColor(currentColour);
        }

        iteration++;
      }
    }
    gradeNumberToColour = Map.fromEntries(
      gradeNumberToColour.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    return gradeNumberToColour;
  }

  String getNextColor(String? currentColour) {
    if (currentColour != null) {
      return "blue";
    } else {
      return "blue";
    }
  }

  Future<CloudSettings?> _initSettings() async {
    final CloudSettings? tempSettings =
        await firebaseService.getSettings(currentProfile!.settingsID);
    setState(() {
      currentSettings = tempSettings;
    });
    return currentSettings;
  }

  Future<CloudProfile?> _initializeCurrentProfile() async {
    await for (final profiles
        in firebaseService.getUser(userID: userId.toString())) {
      final CloudProfile profile = profiles.first;
      setState(() {
        currentProfile = profile;
      });
      return currentProfile;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: appBarStyle,
        ),
        backgroundColor: profileAppBar,
      ),
      body: Column(
        children: [
          // Your dropdown button
          DropdownButton<TimePeriod>(
            value: selectedTimePeriod,
            onChanged: (TimePeriod? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedTimePeriod = newValue;
                });
              }
            },
            items: TimePeriod.values.map((TimePeriod value) {
              return DropdownMenuItem<TimePeriod>(
                value: value,
                child: Text(timePeriodStrings[value]!),
              );
            }).toList(),
          ),
          // Your StreamBuilder
          Expanded(
            child: StreamBuilder<Iterable<CloudProfile>>(
                stream: firebaseService.getUser(userID: userId),
                builder: (BuildContext context,
                    AsyncSnapshot<Iterable<CloudProfile>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // Check if there is data
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data available.');
                  }

                  CloudProfile currentProfile = snapshot.data!.first;

                  // Get points data using the getPoints function
                  return FutureBuilder<PointsData>(
                    future: getPoints(
                      currentProfile,
                      selectedTimePeriod,
                      gradeNumberToColour,
                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<PointsData> pointsSnapshot) {
                      if (pointsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (pointsSnapshot.hasError) {
                        return Text('Error: ${pointsSnapshot.error}');
                      }

                      // Access the PointsData object from the snapshot
                      PointsData pointsData = pointsSnapshot.data!;

                      // Render your UI with the updated points information
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                  'Boulder Points: ${pointsData.pointsBoulder}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Challenge Points: ${pointsData.pointsChallenges}'),
                            ),
                            if (currentProfile.isSetter)
                              ListTile(
                                title: Text(
                                    'Setter Points: ${pointsData.pointsSetter}'),
                              ),
                            const SizedBox(
                              height: 40,
                            ),
                            OverflowBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextButton(
                                    child: const Text('Max Grade'),
                                    onPressed: () {
                                      setState(() {
                                        chartSelection = "maxGrade";
                                      });
                                    }),
                                TextButton(
                                    child: const Text('Climbs'),
                                    onPressed: () {
                                      setState(() {
                                        chartSelection = "climbs";
                                      });
                                    }),
                                Visibility(
                                  visible: currentProfile.isSetter,
                                  child: TextButton(
                                      child: const Text('Setter Data'),
                                      onPressed: () {
                                        setState(() {
                                          chartSelection = "SetterData";
                                        });
                                      }),
                                ),
                                Visibility(
                                  visible: currentProfile.isSetter,
                                  child: TextButton(
                                      child: const Text('Setter Pie'),
                                      onPressed: () {
                                        setState(() {
                                          chartSelection = "SetterDataPie";
                                        });
                                      }),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 37,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 16, left: 6),
                              child: SizedBox(
                                height: 500,
                                child: currentSettings != null
                                    ? LineChartGraph(
                                        currentSettings: currentSettings!,
                                        chartSelection: chartSelection,
                                        graphData: pointsData,
                                        selectedTimePeriod: selectedTimePeriod,
                                        gradingSystem:
                                            currentProfile.gradingSystem,
                                        gradeNumberToColour:
                                            gradeNumberToColour)
                                    : const Text("Loading"),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}

Future<PointsData> getPoints(
  CloudProfile currentProfile,
  TimePeriod selectedTimePeriod,
  Map<int, String> gradeNumberToColour,
) async {
  DateTime dateThreshold = calculateDateThreshold(selectedTimePeriod);
  double pointsBoulder = 0;
  double pointsSetter = 0;
  double pointsChallenges = 0;
  int amountBoulder = 0;
  int amountSetter = 0;
  int amountChallenges = 0;
  LinkedHashMap<DateTime, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<DateTime, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<DateTime, Map<String, int>> boulderSetColours = LinkedHashMap();
  LinkedHashMap<String, int> boulderSetSplit = LinkedHashMap();

  try {
    if (currentProfile.climbedBoulders != null) {
      if (selectedTimePeriod != TimePeriod.allTime) {
        for (var entry in currentProfile.climbedBoulders!.entries) {
          int boulderGradeNumber = entry.value["gradeNumber"];
          String? boulderGradeColour =
              findGradeColour(gradeNumberToColour, boulderGradeNumber);
          // String? boulderGradeColour = gradeNumberToColour[boulderGradeNumber];
          // String? boulderGradeColour = boulderGradeNumber.toString();
          DateTime entryDate = entry.value['date'].toDate();

          DateTime entryDateWithoutTime =
              DateTime(entryDate.year, entryDate.month, entryDate.day);

          if (entryDateWithoutTime.isAfter(dateThreshold)) {
            pointsBoulder += entry.value["boulderPoints"];
            amountBoulder += 1;
            boulderClimbedAmount[entryDateWithoutTime] =
                (boulderClimbedAmount[entryDateWithoutTime] ?? 0) + 1;

            if (boulderClimbedColours.containsKey(entryDateWithoutTime)) {
              if (boulderClimbedColours[entryDateWithoutTime]!
                  .containsKey(boulderGradeColour)) {
                boulderClimbedColours[entryDateWithoutTime]![
                    boulderGradeColour!] = (boulderClimbedColours[
                            entryDateWithoutTime]![boulderGradeColour] ??
                        0) +
                    1;
              } else {
                boulderClimbedColours[entryDateWithoutTime]![
                    boulderGradeColour!] = 1;
              }
            } else {
              boulderClimbedColours[entryDateWithoutTime] = {
                boulderGradeColour!: 1
              };
            }

            int boulderGrade = entry.value["gradeNumber"];

            if (entry.value["flashed"]) {
              if (boulderClimbedMaxFlashed.containsKey(entryDateWithoutTime)) {
                if (boulderClimbedMaxFlashed[entryDateWithoutTime]! <
                    boulderGrade) {
                  boulderClimbedMaxFlashed[entryDateWithoutTime] = boulderGrade;
                }
              } else {
                boulderClimbedMaxFlashed[entryDateWithoutTime] = boulderGrade;
              }
            }
            if (boulderClimbedMaxClimbed.containsKey(entryDateWithoutTime)) {
              if (boulderClimbedMaxClimbed[entryDateWithoutTime]! <
                  boulderGrade) {
                boulderClimbedMaxClimbed[entryDateWithoutTime] = boulderGrade;
              }
            } else {
              boulderClimbedMaxClimbed[entryDateWithoutTime] = boulderGrade;
            }
          }
        }
        for (var entry in currentProfile.setBoulders!.entries) {
          DateTime entryDate = entry.value['setDateBoulder'].toDate();
          DateTime entryDateWithoutTime =
              DateTime(entryDate.year, entryDate.month, entryDate.day);
          if (entryDateWithoutTime.isAfter(dateThreshold)) {
            pointsSetter += entry.value["setterPoints"];
            amountSetter += 1;
            boulderSetAmount[entryDateWithoutTime] =
                (boulderSetAmount[entryDateWithoutTime] ?? 0) + 1;
            String boulderGradeColour = entry.value["gradeColour"];
            boulderSetSplit[boulderGradeColour] ?? 0 + 1;
            boulderSetSplit[boulderGradeColour] =
                (boulderSetSplit[boulderGradeColour] ?? 0) + 1;

            if (boulderSetColours.containsKey(entryDateWithoutTime)) {
              if (boulderSetColours[entryDateWithoutTime]!
                  .containsKey(boulderGradeColour)) {
                boulderSetColours[entryDateWithoutTime]![boulderGradeColour] =
                    (boulderSetColours[entryDateWithoutTime]![
                                boulderGradeColour] ??
                            0) +
                        1;
              } else {
                boulderSetColours[entryDateWithoutTime]![boulderGradeColour] =
                    1;
              }
            } else {
              boulderSetColours[entryDateWithoutTime] = {boulderGradeColour: 1};
            }
          }
        }
        // for when looking at all times:
      } else {
        pointsBoulder = currentProfile.boulderPoints;
        pointsSetter = currentProfile.setterPoints;
        pointsChallenges = currentProfile.challengePoints;
        amountBoulder = currentProfile.climbedBoulders?.length ?? 0;
        amountSetter = currentProfile.setBoulders?.length ?? 0;
        amountChallenges = currentProfile.challengeProfile?.length ?? 0;
        for (var entry in currentProfile.climbedBoulders!.entries) {
          DateTime entryDate = entry.value['date'].toDate();
          DateTime entryDateWithoutTime =
              DateTime(entryDate.year, entryDate.month, entryDate.day);
          boulderClimbedAmount[entryDateWithoutTime] =
              (boulderClimbedAmount[entryDateWithoutTime] ?? 0) + 1;

          int boulderGrade = entry.value["gradeNumber"];

          if (entry.value["flashed"]) {
            if (boulderClimbedMaxFlashed.containsKey(entryDateWithoutTime)) {
              if (boulderClimbedMaxFlashed[entryDateWithoutTime]! <
                  boulderGrade) {
                boulderClimbedMaxFlashed[entryDateWithoutTime] = boulderGrade;
              }
            } else {
              boulderClimbedMaxFlashed[entryDateWithoutTime] = boulderGrade;
            }
          }
          if (boulderClimbedMaxClimbed.containsKey(entryDateWithoutTime)) {
            boulderClimbedAmount[entryDateWithoutTime] =
                (boulderClimbedAmount[entryDateWithoutTime] ?? 0) + 1;
          } else {
            boulderClimbedMaxClimbed[entryDateWithoutTime] = boulderGrade;
          }
        }

        for (var entry in currentProfile.setBoulders!.entries) {
          DateTime entryDate = entry.value['setDateBoulder'].toDate();
          DateTime entryDateWithoutTime =
              DateTime(entryDate.year, entryDate.month, entryDate.day);
          boulderSetAmount[entryDateWithoutTime] =
              (boulderSetAmount[entryDateWithoutTime] ?? 0) + 1;
          String boulderGradeColour = entry.value["gradeColour"];
          boulderSetSplit[boulderGradeColour] ?? 0 + 1;
          boulderSetSplit[boulderGradeColour] =
              (boulderSetSplit[boulderGradeColour] ?? 0) + 1;

          if (boulderSetColours.containsKey(entryDateWithoutTime)) {
            if (boulderSetColours[entryDateWithoutTime]!
                .containsKey(boulderGradeColour)) {
              boulderSetColours[entryDateWithoutTime]![boulderGradeColour] =
                  (boulderSetColours[entryDateWithoutTime]![
                              boulderGradeColour] ??
                          0) +
                      1;
            } else {
              boulderSetColours[entryDateWithoutTime]![boulderGradeColour] = 1;
            }
          } else {
            boulderSetColours[entryDateWithoutTime] = {boulderGradeColour: 1};
          }
        }
      }
      // IF the profile have not done anything:
    } else {
      pointsBoulder = 0;
      pointsSetter = 0;
      pointsChallenges = 0;
      amountBoulder = 0;
      amountSetter = 0;
      amountChallenges = 0;
    }
    return PointsData(
      pointsBoulder: pointsBoulder,
      pointsSetter: pointsSetter,
      pointsChallenges: pointsChallenges,
      amountBoulder: amountBoulder,
      amountSetter: amountSetter,
      amountChallenges: amountChallenges,
      boulderClimbedAmount: boulderClimbedAmount,
      boulderClimbedMaxClimbed: boulderClimbedMaxClimbed,
      boulderClimbedMaxFlashed: boulderClimbedMaxFlashed,
      boulderClimbedColours: boulderClimbedColours,
      boulderSetAmount: boulderSetAmount,
      boulderSetColours: boulderSetColours,
      boulderSetSplit: boulderSetSplit,
    );
  } catch (e) {
    return PointsData(
      pointsBoulder: 0,
      pointsSetter: 0,
      pointsChallenges: 0,
      amountBoulder: 0,
      amountSetter: 0,
      amountChallenges: 0,
      boulderClimbedAmount: boulderClimbedAmount,
      boulderClimbedMaxClimbed: boulderClimbedMaxClimbed,
      boulderClimbedMaxFlashed: boulderClimbedMaxFlashed,
      boulderClimbedColours: boulderClimbedColours,
      boulderSetAmount: boulderSetAmount,
      boulderSetColours: boulderSetColours,
      boulderSetSplit: boulderSetSplit,
    );
  }
}

String? findGradeColour(Map<int, String> gradeNumberToColour, int gradeNumber) {
  // Iterate through the sorted keys in gradeNumberToColour
  for (int key in gradeNumberToColour.keys.toList()..sort()) {
    if (gradeNumber <= key) {
      return gradeNumberToColour[key];
    }
  }
  return null; // Return null if no match is found
}

class PointsData {
  double pointsBoulder;
  double pointsSetter;
  double pointsChallenges;
  int amountBoulder;
  int amountSetter;
  int amountChallenges;
  LinkedHashMap<DateTime, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<DateTime, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<DateTime, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<DateTime, Map<String, int>> boulderSetColours = LinkedHashMap();
  LinkedHashMap<String, int> boulderSetSplit = LinkedHashMap();

  PointsData({
    required this.pointsBoulder,
    required this.pointsSetter,
    required this.pointsChallenges,
    required this.amountBoulder,
    required this.amountSetter,
    required this.amountChallenges,
    required this.boulderClimbedAmount,
    required this.boulderClimbedMaxClimbed,
    required this.boulderClimbedMaxFlashed,
    required this.boulderClimbedColours,
    required this.boulderSetAmount,
    required this.boulderSetColours,
    required this.boulderSetSplit,
  });
}
