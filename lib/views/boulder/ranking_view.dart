import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> with TickerProviderStateMixin {
  late TabController _tabController;
  List<TimePeriod> dropdownOptions = [
    TimePeriod.week,
    TimePeriod.month,
    TimePeriod.semester,
    TimePeriod.year,
    TimePeriod.allTime,
  ];
  TimePeriod selectedTimePeriod = TimePeriod.week;
  late final FirebaseCloudStorage firebaseService;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseCloudStorage();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        actions: [
          // Add a DropdownButton in the AppBar
          DropdownButton<TimePeriod>(
            value: selectedTimePeriod,
            onChanged: (value) {
              setState(() {
                selectedTimePeriod = value!;
              });
            },
            items: dropdownOptions.map((option) {
              return DropdownMenuItem<TimePeriod>(
                value: option,
                child: Text(getTimePeriodLabel(option)),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          tabs: const [
            Tab(text: 'Points'),
            Tab(text: 'Tops'),
            Tab(text: 'Challenges'),
            Tab(text: 'Setter-Points'),
            Tab(text: 'Setter-Amount'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RankingTab(
              criteria: 'boulderRankingsByPoints',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService),
          RankingTab(
              criteria: 'boulderRankingsByAmount',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService),
          RankingTab(
              criteria: 'challengeRankings',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService),
          RankingTab(
              criteria: 'setterRankingsByAmount',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService),
          RankingTab(
              criteria: 'setterRankingsByPoints',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService),
        ],
      ),
    );
  }
}

class RankingTab extends StatelessWidget {
  final String criteria;
  final TimePeriod timePeriod;
  final FirebaseCloudStorage firebaseService;

  const RankingTab({
    required this.criteria,
    required this.timePeriod,
    required this.firebaseService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getRankingsBasedOnCriteria(firebaseService, timePeriod, criteria),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error gracefully
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          // Handle case where data is not available
          return Text('No data available.');
        } else {
          List<String> rankings = snapshot.data!;
          return SizedBox(
            height: 100,
            width: 100,
            child: ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(rankings[index]),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<List<String>> getRankingsBasedOnCriteria(
    FirebaseCloudStorage userService,
    TimePeriod selectedTimePeriod,
    String criteria,
  ) async {
    try {
      // Fetch all users
      Iterable<CloudProfile> users = await userService.getAllUsers().first;
      print(criteria);
      // Filter users based on different criteria
      Map<String, dynamic> filteredRankings = {};

      if (users.isNotEmpty) {
        DateTime dateThreshold = calculateDateThreshold(selectedTimePeriod);
        double points = 0;
        int amount = 0;

        for (var user in users) {
          if (user.climbedBoulders != null) {
            switch (criteria) {
              case 'boulderRankingsByPoints':

                for (var entry in user.climbedBoulders!.entries) {
                  DateTime entryDate = entry.value['date'].toDate();
                  if (entryDate.isAfter(dateThreshold)) {
                    points += entry.value["boulderPoints"];
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = points
                    : filteredRankings[user.displayName] = points;

                break;

              case 'boulderRankingsByAmount':
                for (var entry in user.climbedBoulders!.entries) {
                  DateTime entryDate = entry.value['date'].toDate();
                  if (entryDate.isAfter(dateThreshold)) {
                    amount += 1;
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = amount
                    : filteredRankings[user.displayName] = amount;
                break;

              case 'challengeRankings':
                // Handle setterPoints criteria
                break;

              case 'setterRankingsByAmount':
              if (user.setBoulders !=null){
                for (var entry in user.setBoulders!.entries) {
                  DateTime entryDate = entry.value['setDateBoulder'].toDate();
                  
                  if (entryDate.isAfter(dateThreshold)) {
                  
                    points += entry.value["setterPoints"];
                    
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = points
                    : filteredRankings[user.displayName] = points;
}
                break;
              case "setterRankingsByPoints":
              if (user.setBoulders !=null){
                for (var entry in user.setBoulders!.entries) {
                  DateTime entryDate = entry.value['setDateBoulder'].toDate();
                  if (entryDate.isAfter(dateThreshold)) {
                    amount += 1;
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = amount
                    : filteredRankings[user.displayName] = amount;
              }
                break;
            }
          }
        }
      }
      return mapSorter(filteredRankings);
    } catch (e) {
      print(e);
      return [];
    }
  }

  List<String> mapSorter(Map<String, dynamic> filteredRankings) {
    var sortedKeys = filteredRankings.keys.toList(growable: false)
      ..sort((k1, k2) => filteredRankings[k1].compareTo(filteredRankings[k2]));

    LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => filteredRankings[k]);

    List<String> resultList = [];

    // Iterate over the sorted map and create a list of strings
    for (var entry in sortedMap.entries) {
      String keyValueString = "${entry.key} - ${entry.value}";
      resultList.add(keyValueString);
    }

    // Print the result list
    return resultList;
  }
}
