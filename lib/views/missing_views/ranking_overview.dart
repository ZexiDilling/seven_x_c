import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

enum TimePeriod { week, month, semester, year, allTime }

class Ranking {
  final String name;
  final int score;

  Ranking({required this.name, required this.score});
}

class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> with TickerProviderStateMixin {
  TimePeriod selectedTimePeriod = TimePeriod.week;
  late TabController _tabController;
  late final FirebaseCloudStorage _userService;
  String currentTabCriteria = 'points';

  @override
  void initState() {
    super.initState();
    _userService = FirebaseCloudStorage();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // Update the current tab criteria when the tab is changed
    setState(() {
      currentTabCriteria = getCriteriaForTab(_tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rankings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Points'),
              Tab(text: 'Tops'),
              Tab(text: 'Setter'),
              Tab(text: 'Amount'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            RankingTab(criteria: "points", timePeriod: selectedTimePeriod),
            RankingTab(
                criteria: "bouldersClimbed", timePeriod: selectedTimePeriod),
            RankingTab(
                criteria: "setterPoints", timePeriod: selectedTimePeriod),
            RankingTab(criteria: "bouldersSet", timePeriod: selectedTimePeriod),
          ],
        ),
      ),
    );
  }

  String getCriteriaForTab(int tabIndex) {
    // Add logic to determine criteria based on tab index
    switch (tabIndex) {
      case 0:
        return 'points';
      case 1:
        return 'bouldersClimbed';
      case 2:
        return 'setterPoints';
      case 3:
        return 'bouldersSet';
      default:
        return 'points'; // Default criteria
    }
  }

  String getTimePeriodLabel(TimePeriod timePeriod) {
    switch (timePeriod) {
      case TimePeriod.week:
        return 'Week';
      case TimePeriod.month:
        return 'Month';
      case TimePeriod.semester:
        return 'Semester';
      case TimePeriod.year:
        return 'Year';
      case TimePeriod.allTime:
        return 'allTime';
    }
  }

  void updateRankings(FirebaseCloudStorage userService,
      TimePeriod selectedTimePeriod, String criteria) {
    print(criteria);
    Stream<Iterable<CloudProfile>> allUsers = userService.getAllUsers();
    allUsers.listen((Iterable<CloudProfile> users) {
      // Filter users based on different criteria
      List<CloudProfile> filteredUsers = users.where((user) {
        if (user.climbedBoulders != null) {
          // Replace 'dateThreshold' with the threshold DateTime you want to use
          DateTime dateThreshold = calculateDateThreshold(selectedTimePeriod);

          // Filter based on different criteria
          switch (criteria) {
            case 'points':
              return user.climbedBoulders!.entries.any((entry) {
                DateTime entryDate = entry.value['date'].toDate();
                double entryPoints = (entry.value['points'] ?? 0).toDouble();
                return entryDate.isAfter(dateThreshold) && entryPoints > 0.0;
              });

            // Add cases for other criteria
            case 'bouldersClimbed':
              // Handle bouldersClimbed criteria
              break;

            case 'setterPoints':
              // Handle setterPoints criteria
              break;

            case 'bouldersSet':
              // Handle bouldersSet criteria
              break;

            // Add more cases for additional criteria

            default:
              return false;
          }
        }
        return false;
      }).toList();

      // Do something with the filtered users
      // For example, you can update the state or perform other operations
    });
  }
}

DateTime calculateDateThreshold(TimePeriod timePeriod) {
  DateTime currentTime = DateTime.now();
  switch (timePeriod) {
    case TimePeriod.week:
      return currentTime.subtract(Duration(days: 7));
    case TimePeriod.month:
      return currentTime.subtract(Duration(days: 30));
    case TimePeriod.semester:
      // Adjust the duration as needed
      return currentTime.subtract(Duration(days: 180));
    case TimePeriod.year:
      return currentTime.subtract(Duration(days: 365));
    default:
      return DateTime(0); // Or handle the default case accordingly
  }
}

class RankingTab extends StatelessWidget {
  final String criteria;
  final TimePeriod timePeriod;

  RankingTab({required this.criteria, required this.timePeriod});

  @override
  Widget build(BuildContext context) {
    print(criteria);
    List<String> rankings = getRankingsBasedOnCriteria(criteria, timePeriod);

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

  List<String> getRankingsBasedOnCriteria(
      String criteria, TimePeriod timePeriod) {
        print(criteria);
    // Implement your logic to fetch rankings based on criteria and time period
    // For example, you might make a network request or filter existing data.
    // Return the rankings data as needed.
    return [criteria];
  }
}
