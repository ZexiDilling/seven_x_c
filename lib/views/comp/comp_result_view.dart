import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

class CompResultsView extends StatefulWidget {
  const CompResultsView({super.key});

  @override
  _CompResultsViewState createState() => _CompResultsViewState();
}

class _CompResultsViewState extends State<CompResultsView>
    with TickerProviderStateMixin {
  late final FirebaseCloudStorage _compService;
  late List<CloudComp> allComps;
  CloudComp? selectedComp;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _compService = FirebaseCloudStorage();
    allComps = [];
    selectedComp = null;
    _tabController = TabController(length: 4, vsync: this);
    loadComps();
  }

  Future<void> loadComps() async {
    final comps = await _compService.getAllComps().first;
    setState(() {
      allComps = comps.toList();
      selectedComp = allComps.isNotEmpty ? allComps.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<CloudComp>(
          value: selectedComp,
          onChanged: (CloudComp? newValue) {
            setState(() {
              selectedComp = newValue!;
            });
          },
          items: allComps
              .map((comp) => DropdownMenuItem<CloudComp>(
                    value: comp,
                    child: Text(comp.compName),
                  ))
              .toList(),
        ),
        bottom: TabBar(
          isScrollable: true,
          physics: BouncingScrollPhysics(),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Total Ranking'),
            Tab(text: 'Female Ranking'),
            Tab(text: 'Male Ranking'),
            Tab(text: 'Boulder Info'),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Total Ranking
                  buildRankingTab('total'),

                  // Tab 2: Female Ranking
                  buildRankingTab('female'),

                  // Tab 3: Male Ranking
                  buildRankingTab('male'),

                  // Tab 4: Boulder Info
                  buildBoulderInfoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRankingTab(String rankingType) {
    return FutureBuilder<Widget>(
      future: _buildRankingTabContent(rankingType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Center(child: Text('Error loading data.'));
        } else {
          return snapshot.data ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<Widget> _buildRankingTabContent(String rankingType) async {
    final compResults = selectedComp?.compResults![rankingType];

    if (compResults.isNotEmpty) {
      final sortedEntries = await compResults.entries.toList()
        ..sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) =>
            (a.value['rank'] as int).compareTo(b.value['rank'] as int));

      return Column(
        children: [
          for (var entry in sortedEntries)
            ListTile(
              leading: CircleAvatar(
              backgroundColor: Colors.blue, // Change color as needed
              child: Text(
                entry.value['rank'].toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
              title: Text(entry.key), // Assuming entry.key is the display name
              subtitle: Text(
                  'Points: ${entry.value['points']}, Tops: ${entry.value['tops']}'),
            ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget buildBoulderInfoTab() {
    return FutureBuilder<Widget>(
      future: _buildBoulderInfoTabContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Center(child: Text('Error loading data.'));
        } else {
          return snapshot.data ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<Widget> _buildBoulderInfoTabContent() async {
    final boulders = selectedComp?.bouldersComp;

    if (boulders!.isNotEmpty) {
      
      return Column(
        children: [
          for (var entry in boulders.entries)
            ListTile(
              title: Text(entry.key), // Assuming entry.key is the display name
              subtitle: Text(
                  'Tops: ${entry.value['tops']}, Points: ${entry.value['points']}'),
            ),
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
