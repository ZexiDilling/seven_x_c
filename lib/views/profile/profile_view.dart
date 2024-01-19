import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/charts/profile_charts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final FirebaseCloudStorage _userService;
  TimePeriod selectedTimePeriod = TimePeriod.week;
  String get userId => AuthService.firebase().currentUser!.id;
  late bool isShowingMainData;

  String chartSelection = "maxGrade";

  @override
  void initState() {
    super.initState();
    _userService = FirebaseCloudStorage();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
            items: TimePeriod.values.map((TimePeriod timePeriod) {
              return DropdownMenuItem<TimePeriod>(
                value: timePeriod,
                child: Text(timePeriod.toString()),
              );
            }).toList(),
          ),
          // Your StreamBuilder
          Expanded(
            child: StreamBuilder<Iterable<CloudProfile>>(
                stream: _userService.getUser(userID: userId),
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
                    future: getPoints(currentProfile, selectedTimePeriod),
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
                            const Text(
                              "Chart",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            OverflowBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextButton(
                                    child: const Text('Max Grade'),
                                    onPressed: () {  setState((){
                                      chartSelection = "maxGrade";});
                                    }),
                                TextButton(
                                    child: const Text('Climbs'),
                                    onPressed: () {  setState((){
                                      chartSelection = "climbs";});
                                    }),
                                Visibility(
                                  visible: currentProfile.isSetter,
                                  child: TextButton(
                                      child: const Text('Setter Data'),
                                      onPressed: () { setState((){
                                        chartSelection = "SetterData";});
                                      }),
                                ),
                                Visibility(
                                  visible: currentProfile.isSetter,
                                  child: TextButton(
                                      child: const Text('Setter Pie'),
                                      onPressed: () { setState(() {
                                        chartSelection = "SetterDataPie";
                                      });
                                      print(pointsData.boulderSetSplit);
                                        
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
                                
                                child: LineChartGraph(
                                    chartSelection: chartSelection,
                                    graphData: pointsData,
                                    selectedTimePeriod: selectedTimePeriod),
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
  LinkedHashMap<DateTime, int> boulderSetAmount = LinkedHashMap();
  LinkedHashMap<DateTime, Map<String, int>> boulderSetColours = LinkedHashMap();
  LinkedHashMap<String, int> boulderSetSplit = LinkedHashMap();

  try {
    if (selectedTimePeriod != TimePeriod.allTime) {
      if (currentProfile.climbedBoulders != null) {
        for (var entry in currentProfile.climbedBoulders!.entries) {
          DateTime entryDate = entry.value['date'].toDate();
          DateTime entryDateWithoutTime =
              DateTime(entryDate.year, entryDate.month, entryDate.day);
          if (entryDateWithoutTime.isAfter(dateThreshold)) {
            pointsBoulder += entry.value["points"];
            amountBoulder += 1;
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
            boulderSetSplit[boulderGradeColour] ?? 0 + 1;boulderSetSplit[boulderGradeColour] = (boulderSetSplit[boulderGradeColour] ?? 0) + 1;
  
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
      }
    } else {
      print("testing?");
      pointsBoulder = currentProfile.boulderPoints;
      pointsSetter = currentProfile.setterPoints;
      pointsChallenges = currentProfile.challengePoints;
      amountBoulder = currentProfile.climbedBoulders!.length;
      amountSetter = currentProfile.setBoulders!.length;
      //TOdo fixc thisd " "
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
      boulderSetAmount: boulderSetAmount,
      boulderSetColours: boulderSetColours,
      boulderSetSplit: boulderSetSplit,
    );
  }
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
    required this.boulderSetAmount,
    required this.boulderSetColours,
    required this.boulderSetSplit,
  });
}
