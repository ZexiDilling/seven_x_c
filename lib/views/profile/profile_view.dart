import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/graph_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/helpters/time_calculations.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/charts/profile_charts.dart';
import 'package:seven_x_c/views/profile/point_gather.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late CloudProfile? currentProfile;
  CloudSettings? currentSettings;
  CloudGymData? currentGymData;
  late final FirebaseCloudStorage firebaseService;
  TimePeriod selectedTimePeriod = TimePeriod.week;
  String get userId => AuthService.firebase().currentUser!.id;
  late bool isShowingMainData;
  Map<int, String> gradeNumberToColour = {};
  String chartSelection = "maxGrade";

  bool setterViewGrade = true;
  bool perTimeInterval = false;
  String graphStyle = "climber";
  bool gradeVsColour = true;
  bool colourVsValue = true;

  Map<String, String> selectedTime = getSelectedTime(DateTime.now());
  String selectedSetter = "All";

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
            dateBoulderSet: updateDateBoulderSet(
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
    await _initGymData();
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

  Future<CloudGymData?> _initGymData() async {
    final CloudGymData? tempGymData =
        await firebaseService.getGymData(currentProfile!.settingsID);
    setState(() {
      currentGymData = tempGymData;
    });
    return currentGymData;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: DropdownButton<TimePeriod>(
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
              ),
              const Text("Per Time"),
              Checkbox(
                value: perTimeInterval,
                onChanged: (value) {
                  if (chartSelection == "maxGrade") {
                    setState(() {
                      perTimeInterval = value ?? false;
                    });
                  }
                },
                activeColor:
                    chartSelection == "maxGrade" ? Colors.blue : Colors.grey,
                checkColor: chartSelection == "maxGrade"
                    ? Colors.white
                    : const Color.fromARGB(255, 233, 229, 229),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () {
                  _showCharExplanation(context);
                },
                icon: const Icon(IconManager.info),
              ),
              IconButton(
                onPressed: () {
                  selectedTime = getSelectedTime(DateTime.now());
                  setState(() {
                    selectedTime = selectedTime;
                  });
                },
                icon: const Icon(IconManager.reset),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  switch (selectedTimePeriod) {
                    case TimePeriod.week:
                      selectedTime = weekAdjustment(selectedTime, false);

                    case TimePeriod.month:
                      selectedTime = montAdjustment(selectedTime, false);

                    case TimePeriod.semester:
                      selectedTime = semesterAdjustment(selectedTime, false);
                    case TimePeriod.year:
                      selectedTime = yearAdjustment(selectedTime, false);
                  }
                  setState(() {
                    selectedTime = selectedTime;
                  });
                },
                icon: const Icon(IconManager.leftArrow),
                iconSize: iconSizeChart,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: switch (selectedTimePeriod) {
                    TimePeriod.week => Text(
                        weekLable(selectedTime),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    TimePeriod.month => Text(
                        monthLable(selectedTime),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    TimePeriod.semester => Text(
                        semesterLable(selectedTime),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    TimePeriod.year => Text(
                        yearLable(selectedTime),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                  }),
              Visibility(
                visible: true,
                child: IconButton(
                  onPressed: () {
                    switch (selectedTimePeriod) {
                      case TimePeriod.week:
                        selectedTime = weekAdjustment(selectedTime, true);

                      case TimePeriod.month:
                        selectedTime = montAdjustment(selectedTime, true);

                      case TimePeriod.semester:
                        selectedTime = semesterAdjustment(selectedTime, true);
                      case TimePeriod.year:
                        selectedTime = yearAdjustment(selectedTime, true);
                    }
                    setState(() {
                      selectedTime = selectedTime;
                    });
                  },
                  icon: const Icon(IconManager.rightArrow),
                  iconSize: iconSizeChart,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
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

                  if (currentGymData == null) {
                    return const CircularProgressIndicator();
                  }

                  CloudProfile currentProfile = snapshot.data!.first;

                  // Get points data using the getPoints function

                  return FutureBuilder<PointsData>(
                    future: getPoints(
                      currentProfile,
                      currentGymData!,
                      selectedTime,
                      selectedTimePeriod,
                      gradeNumberToColour,
                      perTimeInterval,
                      graphStyle,
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            chartSelection == "maxGrade"
                                                ? buttonBackgroundColorActive
                                                : buttonBackgroundColorInactibe,
                                      ),
                                      child: const Text('Max Grade'),
                                      onPressed: () {
                                        setState(() {
                                          graphStyle = "climber";
                                          chartSelection = "maxGrade";
                                        });
                                      }),
                                  TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            chartSelection == "climbs"
                                                ? buttonBackgroundColorActive
                                                : buttonBackgroundColorInactibe,
                                      ),
                                      child: const Text('Climbs'),
                                      onPressed: () {
                                        setState(() {
                                          graphStyle = "climber";
                                          chartSelection = "climbs";
                                        });
                                      }),
                                  Visibility(
                                    visible: currentProfile.isSetter,
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: chartSelection ==
                                                  "AllSetterData"
                                              ? buttonBackgroundColorActive
                                              : buttonBackgroundColorInactibe,
                                        ),
                                        child: const Text('All Setter Data'),
                                        onPressed: () {
                                          setState(() {
                                            graphStyle = "allSetterData";
                                            chartSelection = "AllSetterData";
                                          });
                                        }),
                                  ),
                                  Visibility(
                                    visible: currentProfile.isSetter,
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: chartSelection ==
                                                  "SetterData"
                                              ? buttonBackgroundColorActive
                                              : buttonBackgroundColorInactibe,
                                        ),
                                        child: const Text('Own Setter Data'),
                                        onPressed: () {
                                          setState(() {
                                            graphStyle = "setter";
                                            chartSelection = "SetterData";
                                          });
                                        }),
                                  ),
                                  Visibility(
                                    visible: currentProfile.isSetter,
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: chartSelection ==
                                                  "SetterDataPie"
                                              ? buttonBackgroundColorActive
                                              : buttonBackgroundColorInactibe,
                                        ),
                                        child: const Text('Setter Pie'),
                                        onPressed: () {
                                          setState(() {
                                            graphStyle = "setter";
                                            chartSelection = "SetterDataPie";
                                          });
                                        }),
                                  )
                                ],
                              ),
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
                                    ? pointsData.gotData
                                        ? LineChartGraph(
                                            currentProfile: currentProfile,
                                            currentSettings: currentSettings!,
                                            chartSelection: chartSelection,
                                            graphData: pointsData,
                                            selectedTimePeriod:
                                                selectedTimePeriod,
                                            gradingSystem:
                                                currentProfile.gradingSystem,
                                            gradeNumberToColour:
                                                gradeNumberToColour,
                                            setterViewGrade: setterViewGrade,
                                            gradeVsColour: gradeVsColour,
                                            colourVsValue: colourVsValue,
                                            selectedSetter: selectedSetter,
                                          )
                                        : const Text(
                                            "No Data For Selected Time Periode")
                                    : const Text("Loading"),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                child: switch (graphStyle) {
                              "climber" => GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 10 / 3,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0,
                                  ),
                                  itemCount: 9,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String text = '';
                                    Color? diffBoxColour;
                                    switch (index) {
                                      case 0:
                                        text =
                                            'BP: ${pointsData.pointsBoulder}';
                                        break;
                                      case 1:
                                        text =
                                            'BC: ${pointsData.amountBoulderClimbed}';
                                        break;
                                      case 2:
                                        text =
                                            'BF: ${pointsData.amountBoulderFlashed}';

                                        break;
                                      case 3:
                                        text =
                                            'MF: ${pointsData.maxBoulderFlashed}';
                                        if (pointsData
                                                .maxBoulderFlashedColour !=
                                            "") {
                                          diffBoxColour = nameToColor(
                                              currentSettings!
                                                      .settingsGradeColour![
                                                  pointsData
                                                      .maxBoulderFlashedColour]);
                                        }
                                        break;
                                      case 4:
                                        text =
                                            'MC: ${pointsData.maxBoulderClimbed}';
                                        if (pointsData
                                                .maxBoulderClimbedColour !=
                                            "") {
                                          diffBoxColour = nameToColor(
                                              currentSettings!
                                                      .settingsGradeColour![
                                                  pointsData
                                                      .maxBoulderClimbedColour]);
                                        }
                                        break;
                                      case 5:
                                        text = 'DC: ${pointsData.daysClimbed}';
                                        break;
                                      case 6:
                                        text =
                                            'CP: ${pointsData.pointsChallenges}';
                                        break;
                                      case 7:
                                        text =
                                            'CD: ${pointsData.amountChallengesDone}';
                                        break;
                                      case 8:
                                        text =
                                            'CC: ${pointsData.amountChallengesCreated}';
                                        break;
                                    }

                                    // Customize the content of each grid item as needed
                                    return SizedBox(
                                      height:
                                          5.0, // Adjust the height as needed
                                      width: 5.0,
                                      child: Container(
                                        color:
                                            diffBoxColour ?? boxBackgroundColor,
                                        child: Center(
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color:
                                                  boxTextColour, // Set the text color
                                              fontSize:
                                                  boxTextSize, // Set the font size
                                              fontWeight: FontWeight
                                                  .bold, // Set the font weight
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              "setter" => Column(children: [
                                  Row(
                                    children: [
                                      const Text("Grade/Holds"),
                                      Checkbox(
                                          value: setterViewGrade,
                                          onChanged: (value) {
                                            setState(() {
                                              setterViewGrade =
                                                  !setterViewGrade;
                                            });
                                          }),
                                    ],
                                  ),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 10 / 3,
                                      crossAxisSpacing: 10.0,
                                      mainAxisSpacing: 10.0,
                                    ),
                                    itemCount: 3,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String text = '';
                                      Color? diffBoxColour;
                                      switch (index) {
                                        case 0:
                                          text =
                                              'SP: ${pointsData.pointsSetter}';
                                          break;
                                        case 1:
                                          text =
                                              'BC: ${pointsData.amountSetter}';
                                          break;
                                        case 2:
                                          text =
                                              'BF: ${pointsData.daysSetting}';
                                          break;
                                      }

                                      // Customize the content of each grid item as needed
                                      return Container(
                                        color: diffBoxColour ??
                                            boxBackgroundColor, // Set the color or customize as needed
                                        child: Center(
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              color:
                                                  boxTextColour, // Set the text color
                                              fontSize:
                                                  boxTextSize, // Set the font size
                                              fontWeight: FontWeight
                                                  .bold, // Set the font weight
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                              "allSetterData" => Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Grade/Colour"),
                                        Checkbox(
                                            value: gradeVsColour,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  gradeVsColour =
                                                      !gradeVsColour;
                                                },
                                              );
                                            }),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("GradeColour/GradeValue"),
                                        Checkbox(
                                            value: colourVsValue,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  colourVsValue =
                                                      !colourVsValue;
                                                },
                                              );
                                            }),
                                      ],
                                    ),
                                    DropdownButton(
                                      value: selectedSetter,
                                      items: pointsData.allSetters
                                          .map<DropdownMenuItem<String>>(
                                              (String setter) {
                                        return DropdownMenuItem<String>(
                                          value: setter,
                                          child: Text(setter),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedSetter = newValue;
                                          });
                                        }
                                      },
                                    ),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 10 / 3,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                      ),
                                      itemCount: 9,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String text = '';
                                        Color? diffBoxColour;
                                        switch (index) {
                                          case 0:
                                            text =
                                                'Green: ${pointsData.boulderSetGradeColours["all"]!["green"] ?? 0}';
                                            break;
                                          case 1:
                                            text =
                                                'Yellow: ${pointsData.boulderSetGradeColours["all"]!["yellow"] ?? 0}';
                                            break;
                                          case 2:
                                            text =
                                                'Blue: ${pointsData.boulderSetGradeColours["all"]!["blue"] ?? 0}';
                                            break;
                                          case 3:
                                            text =
                                                'Purple: ${pointsData.boulderSetGradeColours["all"]!["purple"] ?? 0}';
                                          case 4:
                                            text =
                                                'Red: ${pointsData.boulderSetGradeColours["all"]!["red"] ?? 0}';
                                          case 5:
                                            text =
                                                'Black: ${pointsData.boulderSetGradeColours["all"]!["black"] ?? 0}';
                                          case 6:
                                            text =
                                                'Silver: ${pointsData.boulderSetGradeColours["all"]!["silver"] ?? 0}';
                                        }

                                        // Customize the content of each grid item as needed
                                        return Container(
                                          color: diffBoxColour ??
                                              boxBackgroundColor, // Set the color or customize as needed
                                          child: Center(
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color:
                                                    boxTextColour, // Set the text color
                                                fontSize:
                                                    boxTextSize, // Set the font size
                                                fontWeight: FontWeight
                                                    .bold, // Set the font weight
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              String() => null,
                            }),
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

void _showCharExplanation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Chart Explanatiopns"),
        content: const Text(
          "Info dump: \n"
          'BP: Boulder Points\n'
          'BC: Amount Boulder Climbed\n'
          'BF: Amount Boulder Flashed\n'
          'MF: Max Flashed Boulder Grade\n'
          'MC: Max Climbed Boulder Grade\n'
          'DC: Days Climbed\n'
          'Challenge is not updated yet\n'
          'CP: Challenge Points\n'
          'CD: Challenge Done\n'
          'CC: Challenge Created',
        ),
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
