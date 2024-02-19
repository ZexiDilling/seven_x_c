import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:seven_x_c/views/boulder/ranking_view.dart' show semesterMap;

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
  }

  _updateFirebaseData() async {
    if (currentProfile!.climbedBoulders != null) {
      var boulderIDs = currentProfile!.climbedBoulders!.keys.toList();

      boulderIDs.sort((a, b) {
        Timestamp timestampA =
            currentProfile!.climbedBoulders![a]!['date'] as Timestamp;
        Timestamp timestampB =
            currentProfile!.climbedBoulders![b]!['date'] as Timestamp;

        DateTime dateA = timestampA.toDate();
        DateTime dateB = timestampB.toDate();
        return dateA.compareTo(dateB);
      });

      int maxFlahsedGrade = 0;
      int maxToppedGrade = 0;
      Stream<Iterable<CloudBoulder>> allBoulderStream =
          firebaseService.getAllBoulders(false);
      CloudBoulder? tempBoulder;
      for (var currentBoulderID in boulderIDs) {
        Iterable<CloudBoulder> allBoulders = await allBoulderStream.first;
        for (CloudBoulder boulders in allBoulders) {
          if (boulders.boulderID == currentBoulderID) {
            tempBoulder = boulders;
          }
        }

        // CloudBoulder? currentBoulder = (await boulderStream.first).first;
        int gradeNumberSetter =
            currentProfile!.climbedBoulders![currentBoulderID]["gradeNumber"];
        bool flashed = currentProfile!.climbedBoulders![currentBoulderID]
                ["flashed"] ??
            false;
        if (flashed && gradeNumberSetter > maxFlahsedGrade) {
          maxFlahsedGrade = gradeNumberSetter;
        }
        if (gradeNumberSetter > maxToppedGrade) {
          maxToppedGrade = gradeNumberSetter;
        }

        Timestamp timeStampToppedDate = currentProfile!
            .climbedBoulders![currentBoulderID]["date"] as Timestamp;
        DateTime toppedDate = timeStampToppedDate.toDate();

        double boulderPoints = currentProfile!
                .climbedBoulders![currentBoulderID]["boulderPoints"] ??
            0.0;

        firebaseService.updateBoulder(
            boulderID: currentBoulderID,
            climberTopped: updateClimberToppedMap(
                currentProfile: currentProfile!,
                boulderPoints: boulderPoints,
                toppedDate: toppedDate,
                existingData: tempBoulder!.climberTopped));

        firebaseService.updateUser(
            currentProfile: currentProfile!,
            dateBoulderTopped: updateDateBoulderToppedMap(
                boulder: tempBoulder,
                userID: currentProfile!.userID,
                boulderPoints: boulderPoints,
                flashed: flashed,
                maxFlahsedGrade: maxFlahsedGrade,
                maxToppedGrade: maxToppedGrade,
                existingData: currentProfile!.dateBoulderTopped));

        currentProfile!.climbedBoulders!.remove(currentBoulderID);
      }
    }
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    await _initSettings();
    await _updateFirebaseData();
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
                  Map<String, String> selectedTime = {"year": "2024", "semester": "spring", "month": "2", "week": "7"};
                  return FutureBuilder<PointsData>(
                    future: getPoints(
                      currentProfile,
                      selectedTime,
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
  Map<String, String> selectedTime,
  TimePeriod selectedTimePeriod,
  Map<int, String> gradeNumberToColour,
) async {
  double pointsBoulder = 0;
  double pointsSetter = 0;
  double pointsChallenges = 0;
  int amountBoulder = 0;
  int amountSetter = 0;
  int amountChallenges = 0;
  LinkedHashMap<String, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<String, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetColours = LinkedHashMap();
  LinkedHashMap<String, int> boulderSetSplit = LinkedHashMap();
  try {
    if (currentProfile.dateBoulderTopped != null) {
      if (selectedTimePeriod == TimePeriod.year) {
        var yearData = currentProfile.dateBoulderTopped![selectedTime["year"]];
        if (yearData != null) {
          for (var month
              in List.generate(12, (index) => (index + 1).toString())) {
            var monthData = yearData[month];
            {
              boulderClimbedAmount[month] ??= 0;
              boulderClimbedMaxClimbed[month] ??= 0;
              boulderClimbedMaxFlashed[month] ??= 0;
              boulderClimbedColours[month] ??= {};

              for (var weeks in monthData.keys) {
                var weekData = monthData[weeks];
                if (weekData != null) {
                  for (var days in weekData.keys) {
                    var dayData = weekData[days];
                    if (dayData != null) {
                      for (var boulder in dayData.keys) {
                        Map<String, dynamic> boulderData = dayData[boulder];
                        pointsBoulder += boulderData["points"] ?? 0;
                        amountBoulder++;
                        boulderClimbedAmount[month] ??= 0;
                        boulderClimbedAmount[month] =
                            (boulderClimbedAmount[month] ?? 0) + 1;
                        boulderClimbedMaxClimbed[month] ??= 0;
                        if (boulderData["gradeNumber"] >
                            boulderClimbedMaxClimbed[month]) {
                          boulderClimbedMaxClimbed[month] =
                              boulderData["gradeNumber"];
                        }
                        boulderClimbedMaxFlashed[month] ??= 0;
                        if (boulderData["gradeNumber"] >
                            boulderClimbedMaxFlashed[month]) {
                          boulderClimbedMaxFlashed[month] =
                              boulderData["gradeNumber"];
                        }
                        boulderClimbedColours[month] ??= {};
                        boulderClimbedColours[month]![
                            boulderData["gradeColour"]] ??= 0;
                        boulderClimbedColours[month]![
                                boulderData["gradeColour"]] =
                            (boulderClimbedColours[month]![
                                        boulderData["gradeColour"]] ??
                                    0) +
                                1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else if (selectedTimePeriod == TimePeriod.semester) {
        var yearData = currentProfile.dateBoulderTopped![selectedTime["year"]];
        if (yearData != null) {
          for (var month
              in List.generate(12, (index) => (index + 1).toString())) {
            if (semesterMap[selectedTime["semester"]]!.contains(month)) {
              var monthData = yearData[month];
              {
                boulderClimbedAmount[month] ??= 0;
                boulderClimbedMaxClimbed[month] ??= 0;
                boulderClimbedMaxFlashed[month] ??= 0;
                boulderClimbedColours[month] ??= {};

                for (var weeks in monthData.keys) {
                  var weekData = monthData[weeks];
                  if (weekData != null) {
                    for (var days in weekData.keys) {
                      var dayData = weekData[days];
                      if (dayData != null) {
                        for (var boulder in dayData.keys) {
                          Map<String, dynamic> boulderData = dayData[boulder];
                          pointsBoulder += boulderData["points"] ?? 0;
                          amountBoulder++;
                          boulderClimbedAmount[month] ??= 0;
                          boulderClimbedAmount[month] =
                              (boulderClimbedAmount[month] ?? 0) + 1;
                          boulderClimbedMaxClimbed[month] ??= 0;
                          if (boulderData["gradeNumber"] >
                              boulderClimbedMaxClimbed[month]) {
                            boulderClimbedMaxClimbed[month] =
                                boulderData["gradeNumber"];
                          }
                          boulderClimbedMaxFlashed[month] ??= 0;
                          if (boulderData["gradeNumber"] >
                              boulderClimbedMaxFlashed[month]) {
                            boulderClimbedMaxFlashed[month] =
                                boulderData["gradeNumber"];
                          }
                          boulderClimbedColours[month] ??= {};
                          boulderClimbedColours[month]![
                              boulderData["gradeColour"]] ??= 0;
                          boulderClimbedColours[month]![
                                  boulderData["gradeColour"]] =
                              (boulderClimbedColours[month]![
                                          boulderData["gradeColour"]] ??
                                      0) +
                                  1;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else if (selectedTimePeriod == TimePeriod.month) {
        var monthData = currentProfile.dateBoulderTopped![selectedTime["year"]]
            [selectedTime["month"]];
        {
          var allDaysInMonth = List.generate(
            DateTime(
              int.parse(selectedTime["year"]!),
              int.parse(selectedTime["month"]!) + 1,
              0,
            ).day,
            (index) => (index + 1).toString(),
          );

          // Iterate over all possible days in the month
          for (var day in allDaysInMonth) {
            boulderClimbedAmount[day] ??= 0;
            boulderClimbedMaxClimbed[day] ??= 0;
            boulderClimbedMaxFlashed[day] ??= 0;
            boulderClimbedColours[day] ??= {};
          }

          for (var weeks in monthData.keys) {
            var weekData = monthData[weeks];
            if (weekData != null) {
              for (var day in weekData.keys) {
                var dayData = weekData[day];
                if (dayData != null) {
                  for (var boulder in dayData.keys) {
                    Map<String, dynamic> boulderData = dayData[boulder];
                    pointsBoulder += boulderData["points"] ?? 0;
                    amountBoulder++;
                    boulderClimbedAmount[day] ??= 0;
                    boulderClimbedAmount[day] =
                        (boulderClimbedAmount[day] ?? 0) + 1;
                    boulderClimbedMaxClimbed[day] ??= 0;
                    if (boulderData["gradeNumber"] >
                        boulderClimbedMaxClimbed[day]) {
                      boulderClimbedMaxClimbed[day] =
                          boulderData["gradeNumber"];
                    }
                    boulderClimbedMaxFlashed[day] ??= 0;
                    if (boulderData["gradeNumber"] >
                        boulderClimbedMaxFlashed[day]) {
                      boulderClimbedMaxFlashed[day] =
                          boulderData["gradeNumber"];
                    }
                    boulderClimbedColours[day] ??= {};
                    boulderClimbedColours[day]![boulderData["gradeColour"]] ??=
                        0;
                    boulderClimbedColours[day]![boulderData["gradeColour"]] =
                        (boulderClimbedColours[day]![
                                    boulderData["gradeColour"]] ??
                                0) +
                            1;
                  }
                }
              }
            }
          }
        }
      } else if (selectedTimePeriod == TimePeriod.week) {
        var weekData = currentProfile.dateBoulderTopped![selectedTime["year"]]
            [selectedTime["month"]][selectedTime["week"]];

        var allDaysInMonth = List.generate(
          DateTime(
            int.parse(selectedTime["year"]!),
            int.parse(selectedTime["month"]!) + 1,
            0,
          ).day,
          (index) => (index + 1).toString(),
        );

        // Iterate over all possible days in the month
        for (var day in allDaysInMonth) {
          boulderClimbedAmount[day] ??= 0;
          boulderClimbedMaxClimbed[day] ??= 0;
          boulderClimbedMaxFlashed[day] ??= 0;
          boulderClimbedColours[day] ??= {};
        }

        if (weekData != null) {
          for (var day in weekData.keys) {
            var dayData = weekData[day];
            if (dayData != null) {
              for (var boulder in dayData.keys) {
                Map<String, dynamic> boulderData = dayData[boulder];
                pointsBoulder += boulderData["points"] ?? 0;
                amountBoulder++;
                boulderClimbedAmount[day] ??= 0;
                boulderClimbedAmount[day] =
                    (boulderClimbedAmount[day] ?? 0) + 1;
                boulderClimbedMaxClimbed[day] ??= 0;
                if (boulderData["gradeNumber"] >
                    boulderClimbedMaxClimbed[day]) {
                  boulderClimbedMaxClimbed[day] = boulderData["gradeNumber"];
                }
                boulderClimbedMaxFlashed[day] ??= 0;
                if (boulderData["gradeNumber"] >
                    boulderClimbedMaxFlashed[day]) {
                  boulderClimbedMaxFlashed[day] = boulderData["gradeNumber"];
                }
                boulderClimbedColours[day] ??= {};
                boulderClimbedColours[day]![boulderData["gradeColour"]] ??= 0;
                boulderClimbedColours[day]![boulderData["gradeColour"]] =
                    (boulderClimbedColours[day]![boulderData["gradeColour"]] ??
                            0) +
                        1;
              }
            }
          }
        }
      }
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
  LinkedHashMap<String, int> boulderClimbedAmount = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxClimbed = LinkedHashMap();
  LinkedHashMap<String, int> boulderClimbedMaxFlashed = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderClimbedColours =
      LinkedHashMap();
  LinkedHashMap<String, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<String, Map<String, int>> boulderSetColours = LinkedHashMap();
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
