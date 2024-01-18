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
  late final FirebaseCloudStorage _userService;

  @override
  void initState() {
    super.initState();
    _userService = FirebaseCloudStorage();
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
              userService: _userService),
          RankingTab(
              criteria: 'boulderRankingsByAmount',
              timePeriod: selectedTimePeriod,
              userService: _userService),
          RankingTab(
              criteria: 'challengeRankings',
              timePeriod: selectedTimePeriod,
              userService: _userService),
          RankingTab(
              criteria: 'setterRankingsByAmount',
              timePeriod: selectedTimePeriod,
              userService: _userService),
          RankingTab(
              criteria: 'setterRankingsByPoints',
              timePeriod: selectedTimePeriod,
              userService: _userService),
        ],
      ),
    );
  }
}

class RankingTab extends StatelessWidget {
  final String criteria;
  final TimePeriod timePeriod;
  final FirebaseCloudStorage userService;

  const RankingTab(
      {super.key,
      required this.criteria,
      required this.timePeriod,
      required this.userService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getRankingsBasedOnCriteria(userService, timePeriod, criteria),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while waiting for the data
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else {
          // Use the data to build the widget
          List<String> rankings = snapshot.data ?? [];
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
      String criteria) async {

    try {
      // Fetch all users
      Iterable<CloudProfile> users = await userService.getAllUsers().first;

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
                    points += entry.value["points"];
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
                for (var entry in user.setBoulders!.entries) {
                  DateTime entryDate = entry.value['setDateBoulder'].toDate();
                  if (entryDate.isAfter(dateThreshold)) {
                    points += entry.value["setterPoints"];
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = points
                    : filteredRankings[user.displayName] = points;

                break;
              case "setterRankingsByPoints":
                for (var entry in user.setBoulders!.entries) {
                  DateTime entryDate = entry.value['setDateBoulder'].toDate();
                  if (entryDate.isAfter(dateThreshold)) {
                    amount += 1;
                  }
                }
                user.isAnonymous == true
                    ? filteredRankings["Anonymous"] = amount
                    : filteredRankings[user.displayName] = amount;
                break;
            }
          }
        }
      }

      return mapSorter(filteredRankings);
    } catch (e) {
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
