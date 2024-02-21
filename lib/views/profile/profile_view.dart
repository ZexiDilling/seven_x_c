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
import 'package:seven_x_c/views/profile/point_gather.dart';

Map<String, String> selectedTime = {
  "year": "2024",
  "semester": "spring",
  "month": "2",
  "week": "8"
};
bool setterViewGrade = true;
bool perTimeInterval = false;

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
    if (currentProfile!.setBoulders != null &&
        currentProfile!.setBoulders!.isNotEmpty) {
      var boulderIDs = currentProfile!.setBoulders!.keys.toList();
      boulderIDs.sort((a, b) {
        Timestamp timestampA =
            currentProfile!.setBoulders![a]!['setDateBoulder'] as Timestamp;
        Timestamp timestampB =
            currentProfile!.setBoulders![b]!['setDateBoulder'] as Timestamp;

        DateTime dateA = timestampA.toDate();
        DateTime dateB = timestampB.toDate();
        return dateA.compareTo(dateB);
      });
      for (var currentBoulderID in boulderIDs) {
        double setterPoints = currentProfile!.setBoulders![currentBoulderID]
                ["setterPoints"] ??
            0.0;

        firebaseService.updateUser(
            currentProfile: currentProfile!,
            dateBoulderSet: updateBoulderSet(
                setterProfile: currentProfile!,
                boulderId: currentBoulderID,
                setterPoints: setterPoints,
                existingData: currentProfile!.dateBoulderSet));

        currentProfile!.setBoulders!.remove(currentBoulderID);
        firebaseService.updateUser(
            currentProfile: currentProfile!,
            setBoulders: currentProfile!.setBoulders);
      }
    }
    if (currentProfile!.climbedBoulders != null &&
        currentProfile!.climbedBoulders!.isNotEmpty) {
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
        firebaseService.updateUser(
            currentProfile: currentProfile!,
            climbedBoulders: currentProfile!.climbedBoulders);
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
                  return FutureBuilder<PointsData>(
                    future: getPoints(
                      currentProfile,
                      selectedTime,
                      selectedTimePeriod,
                      gradeNumberToColour,
                      perTimeInterval,
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
                                height: 300,
                                child: currentSettings != null
                                    ? LineChartGraph(
                                        currentSettings: currentSettings!,
                                        chartSelection: chartSelection,
                                        graphData: pointsData,
                                        selectedTimePeriod: selectedTimePeriod,
                                        gradingSystem:
                                            currentProfile.gradingSystem,
                                        gradeNumberToColour:
                                            gradeNumberToColour,
                                        setterViewGrade: setterViewGrade,
                                      )
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
