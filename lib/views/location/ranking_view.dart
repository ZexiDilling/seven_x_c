import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/graph_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/views/location/ranking_view_data.dart';
import '../../helpters/time_calculations.dart'
    show
        TimePeriod,
        getSelectedTime,
        montAdjustment,
        monthLable,
        semesterAdjustment,
        semesterLable,
        timePeriodStrings,
        weekAdjustment,
        weekLable,
        yearAdjustment,
        yearLable;
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> with TickerProviderStateMixin {
  TimePeriod selectedTimePeriod = TimePeriod.week;
  late final FirebaseCloudStorage firebaseService;
  Map<String, String> selectedTime = getSelectedTime(DateTime.now());
  CloudSettings? currentSettings;
  CloudGymData? currentGymData;
  CloudProfile? currentProfile;
  String get userId => AuthService.firebase().currentUser!.id;
  String rankingSelected = "boulderRankingsByAmount";

  Future<CloudGymData?> _initGymData() async {
    final CloudGymData? tempGymData =
        await firebaseService.getGymData(currentProfile!.settingsID);
    setState(() {
      currentGymData = tempGymData;
    });
    return currentGymData;
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
  void initState() {
    firebaseService = FirebaseCloudStorage();
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    await _initSettings();
    await _initGymData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rankings",
          style: appBarStyle,
        ),
        backgroundColor: profileAppBar,
      ),
      body: Column(
        children: [
          time_periode_selector(context),
          const SizedBox(
            height: 25,
          ),
          time_selector(),
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
                    return FutureBuilder<RankingData>(
                        future: getRankingsBasedOnCriteria(firebaseService,
                            selectedTimePeriod, rankingSelected, selectedTime),
                        builder: (BuildContext context,
                            AsyncSnapshot<RankingData> rankingSnapshot) {
                          if (rankingSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (rankingSnapshot.hasError) {
                            return Text('Error: ${rankingSnapshot.error}');
                          }

                          // Access the PointsData object from the snapshot
                          RankingData rankingData = rankingSnapshot.data!;
                          // Render your UI with the updated points information)
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: headlines),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: buttonLayout,
                                  ),
                                ),
                                const SizedBox(
                                  height: 37,
                                ),
                                rankingData.gotData
                                    ? rankingLayout(rankingData, currentProfile!)
                                    : const Text(
                                        "No Data for selected time periode")
                              ],
                            ),
                          );
                        });
                  }))
        ],
      ),
    );
  }
SizedBox rankingLayout(RankingData rankingData, CloudProfile currentProfile) {
  int nameLength = 25; 
  return SizedBox(
    height: 500,
    child: ListView.builder(
      itemCount: rankingData.rankings.length,
      itemBuilder: (context, index) {
        final entry = rankingData.rankings[index].split(' - ');
        final isCurrentUser = entry[0] == currentProfile.displayName;
        final user = entry[0].length > nameLength ? entry[0].substring(0, nameLength) : entry[0];
        final details = entry[1];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
            color: isCurrentUser ? Colors.blue[100] : Colors.white,
          ),
          child: ListTile(
            title: Text(
              user,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(details),
          ),
        );
      },
    ),
  );
}


  List<Widget> get headlines {
    return <Widget>[
      const SizedBox(
        width: 200,
        child: Text(
          "Boulders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      const SizedBox(
        width: 50,
        child: Text(
          "Setters",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ];
  }

  List<Widget> get buttonLayout {
    return <Widget>[
      TextButton(
          style: TextButton.styleFrom(
            backgroundColor: rankingSelected == "boulderRankingsByPoints"
                ? buttonBackgroundColorActive
                : buttonBackgroundColorInactibe,
          ),
          child: const Text('Points'),
          onPressed: () {
            setState(() {
              rankingSelected = "boulderRankingsByPoints";
            });
          }),
      TextButton(
          style: TextButton.styleFrom(
            backgroundColor: rankingSelected == "boulderRankingsByAmount"
                ? buttonBackgroundColorActive
                : buttonBackgroundColorInactibe,
          ),
          child: const Text('Tops'),
          onPressed: () {
            setState(() {
              rankingSelected = "boulderRankingsByAmount";
            });
          }),
      TextButton(
          style: TextButton.styleFrom(
            backgroundColor: rankingSelected == "challengeRankings"
                ? buttonBackgroundColorActive
                : buttonBackgroundColorInactibe,
          ),
          child: const Text('Challenge'),
          onPressed: () {
            setState(() {
              rankingSelected = "challengeRankings";
            });
          }),
      TextButton(
          style: TextButton.styleFrom(
            backgroundColor: rankingSelected == "setterRankingsByPoints"
                ? buttonBackgroundColorActive
                : buttonBackgroundColorInactibe,
          ),
          child: const Text('Points'),
          onPressed: () {
            setState(() {
              rankingSelected = "setterRankingsByPoints";
            });
          }),
      TextButton(
          style: TextButton.styleFrom(
            backgroundColor: rankingSelected == "setterRankingsByAmount"
                ? buttonBackgroundColorActive
                : buttonBackgroundColorInactibe,
          ),
          child: const Text('Amount'),
          onPressed: () {
            setState(() {
              rankingSelected = "setterRankingsByAmount";
            });
          }),
    ];
  }

  Row time_selector() {
    return Row(
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
    );
  }

  Row time_periode_selector(BuildContext context) {
    return Row(
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
    );
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
}
