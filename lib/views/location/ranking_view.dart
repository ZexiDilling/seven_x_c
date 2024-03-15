

import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/views/location/ranking_view_data.dart';
import '../../helpters/time_calculations.dart'
    show TimePeriod, getSelectedTime, timePeriodStrings;
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';


class RankView extends StatefulWidget {
  const RankView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RankViewState createState() => _RankViewState();
}

class _RankViewState extends State<RankView> with TickerProviderStateMixin {
  late TabController _tabController;
  TimePeriod selectedTimePeriod = TimePeriod.week;
  late final FirebaseCloudStorage firebaseService;
  Map<String, String> selectedTime = getSelectedTime(DateTime.now());


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
        title: const Text(
          'Rankings',
          style: appBarStyle,
        ),
        backgroundColor: dtuClimbingAppBar,
        actions: [
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
              firebaseService: firebaseService,
              selectedTime: selectedTime,),
          RankingTab(
              criteria: 'boulderRankingsByAmount',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService,
              selectedTime: selectedTime,),
          RankingTab(
              criteria: 'challengeRankings',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService,
              selectedTime: selectedTime,),
          RankingTab(
              criteria: 'setterRankingsByAmount',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService,
              selectedTime: selectedTime,),
          RankingTab(
              criteria: 'setterRankingsByPoints',
              timePeriod: selectedTimePeriod,
              firebaseService: firebaseService,
              selectedTime: selectedTime,),
        ],
      ),
    );
  }
}

class RankingTab extends StatelessWidget {
  final String criteria;
  final TimePeriod timePeriod;
  final FirebaseCloudStorage firebaseService;
  final Map<String, String> selectedTime;


  const RankingTab({
    super.key,
    required this.criteria,
    required this.timePeriod,
    required this.firebaseService,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getRankingsBasedOnCriteria(firebaseService, timePeriod, criteria, selectedTime),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error gracefully
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          // Handle case where data is not available
          return const Text('No data available.');
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

  
}
