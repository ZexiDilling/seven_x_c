import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/enums/menu_action.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_location_data.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/utilities/dialogs/auth/logout_dialog.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  // Init
  late CloudProfile? currentProfile;
  CloudGymData? currentGymData;
  String get userId => AuthService.firebase().currentUser!.id;
  bool isShowingMainData = false;
  late final FirebaseCloudStorage firebaseService;
  CloudSettings? currentSettings;

  @override
  void initState() {
    firebaseService = FirebaseCloudStorage();
    _initializeData();
    super.initState();

    isShowingMainData = true;
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    await _initSettings();
    await _initGymData();
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

  // view_data
  bool isGymSelecter = false;
  bool boulderingSelecter = false;
  bool  sportsClimbingSelecter = false;
  bool tradClimbingSelector = false;
  bool showAllLocations = true;
  List<String> locations = [];

  @override
  Widget build(BuildContext context) {
    if (!isShowingMainData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Iterable<CloudLocationData>>(
          stream: getFilterGymLocations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            if (snapshot.hasError) {
              return Text('Error:  ${snapshot.error}');
            }
            final locationCount = snapshot.data?.length ?? 0;

            return Text("Find a climbing location $locationCount",
                style: locationAppBarStyle);
          },
        ),
        backgroundColor: locationAppBarColor,
        actions: [dropDownMenu(context, currentSettings)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          placementRow(),
          activityRow(),
          searchRow(),
          const SizedBox(height: 20,),
          StreamBuilder<Iterable<CloudLocationData>>(
          stream: getFilterGymLocations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final locations = snapshot.data?.toList() ?? [];

            return Expanded(
              child: locationListView(locations),
            );
          },
        ),
        ],
      ),
    );
  }

  Row placementRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value: isGymSelecter,
          onChanged: (value) {
            setState(() {
              isGymSelecter = value!;
              if (isGymSelecter) {
                locations.add('isGym');
              } else {
                locations.remove('isGym');
              }
            });
          },
        ),
        const Text('Is Gym ?'),
        const SizedBox(width: 20),
        Checkbox(
          value: sportsClimbingSelecter,
          onChanged: (value) {
            setState(() {
              sportsClimbingSelecter = value!;
              if (sportsClimbingSelecter) {
                locations.add('SportsClimbing');
              } else {
                locations.remove('SportsClimbing');
              }
            });
          },
        ),
        const Text('SportsClimbing'),
      ],
    );
  }

  Row activityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value: boulderingSelecter,
          onChanged: (value) {
            setState(() {
              boulderingSelecter = value!;
              if (boulderingSelecter) {
                locations.add('Bouldering');
              } else {
                locations.remove('Bouldering');
              }
            });
          },
        ),
        const Text('Bouldering'),
        const SizedBox(width: 20),
        Checkbox(
          value: tradClimbingSelector,
          onChanged: (value) {
            setState(() {
              tradClimbingSelector = value!;
              if (tradClimbingSelector) {
                locations.add('TradeClimbing');
              } else {
                locations.remove('TradeClimbing');
              }
            });
          },
        ),
        const Text('Trade Climbing'),
      ],
    );
  }

  Row searchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        const SizedBox(width: 10), // Adjust spacing as needed
        ElevatedButton(
          onPressed: () {
            // Implement search action
          },
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget locationListView(List<CloudLocationData> locations) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return ListTile(
          title: Text(location.locationNameID), // Adjust based on your data
          onTap: () {
            // Implement action when location is tapped
          },
        );
      },
    );
  }

  PopupMenuButton<MenuActionLocation> dropDownMenu(
      BuildContext context, CloudSettings? currentSettings) {
    return PopupMenuButton<MenuActionLocation>(
      onSelected: (value) async {
        switch (value) {
          case MenuActionLocation.logout:
            final shouldLogout = await showLogOutDialog(context);
            if (shouldLogout) {
              // ignore: use_build_context_synchronously
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
              break;
            }
          case MenuActionLocation.settings:
            Navigator.of(context).pushNamed(profileSettings).then((_) {
              _initializeData();
            });
            break;

          case MenuActionLocation.adminPanel:
            Navigator.of(context).pushNamed(adminPanel);
          case MenuActionLocation.profile:
            Navigator.of(context).pushNamed(
              profileView,
              arguments: currentSettings!,
            );
          case MenuActionLocation.createLocation:
            Navigator.of(context).pushNamed(
              createLocationView,
            );
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: MenuActionLocation.profile,
            child: Text("Profile"),
          ),
          const PopupMenuItem(
            value: MenuActionLocation.settings,
            child: Text("Settings"),
          ),
          if (currentProfile!.isAdmin)
            const PopupMenuItem(
              value: MenuActionLocation.adminPanel,
              child: Text("Admin"),
            ),
          const PopupMenuItem(
            value: MenuActionLocation.createLocation,
            child: Text("Create new Location"),
          ),
          const PopupMenuItem(
            value: MenuActionLocation.logout,
            child: Text("Log out"),
          ),
        ];
      },
    );
  }

  Stream<Iterable<CloudLocationData>> getFilterGymLocations() {
    return firebaseService.getAllGymLocations().map((locations) {
      if (showAllLocations) {
        return locations;
      } else {
        locations = locations.where((location) =>
            location.isGym == isGymSelecter &&
            location.bouldering == boulderingSelecter &&
            location.sport == sportsClimbingSelecter &&
            location.trad == tradClimbingSelector &&
            location.bouldering == boulderingSelecter);
        return locations;
      }
    });
  }
}
