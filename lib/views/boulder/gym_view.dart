// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/enums/menu_action.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/boulder_info.dart';
import 'package:seven_x_c/utilities/dialogs/boulder_info_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/logout_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/slides/filter.dart';

import 'package:vector_math/vector_math_64.dart' as VM;

void main() {
  runApp(const MaterialApp(
    home: GymView(),
  ));
}

GlobalKey _gymKey = GlobalKey();

class GymView extends StatefulWidget {
  const GymView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GymViewState createState() => _GymViewState();
}

class _GymViewState extends State<GymView> {
  final List<CircleInfo> allBoulders = [];
  final double minZoomThreshold = 0; // Adjust this threshold as needed
  final TransformationController _controller = TransformationController();
  String get userId => AuthService.firebase().currentUser!.id;

  late CloudProfile? currentProfile;
  bool profileLoaded = false;
  bool editing = false;
  bool filterEnabled = false;

  late final FirebaseCloudStorage _boulderService;
  late final FirebaseCloudStorage _userService;

  Stream<Iterable<CloudBoulder>> getFilteredBouldersStream() {
  // Replace this with your actual filtering logic based on the drawer values
  return _boulderService.getAllBoulders().map((boulders) {
    // Example: Filter based on selected regions
     if (selectedColors.isNotEmpty) {
      boulders = boulders.where((boulder) =>
          selectedColors.contains(boulder.gradeColour.toLowerCase()));
    }

    // Example: Filter based on the gradeRangeSlider
    boulders = boulders.where((boulder) =>
        boulder.gradeNumberSetter >= gradeSliderRange.start &&
        boulder.gradeNumberSetter <= gradeSliderRange.end);

    // If no filters are applied, return the original stream
    return boulders;
  });
}

  @override
  void initState() {
    _boulderService = FirebaseCloudStorage();
    _userService = FirebaseCloudStorage();

    _initializeCurrentProfile();
    super.initState();
  }

  Future<void> _initializeCurrentProfile() async {
    await for (final profiles
        in _userService.getUser(userID: userId.toString())) {
      final CloudProfile profile = profiles.first;
      setState(() {
        currentProfile = profile;
        profileLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!profileLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("DTU Climbing"),
        backgroundColor: const Color.fromRGBO(255, 17, 0, 1),
        actions: [
          if (currentProfile!.isAdmin || currentProfile!.isSetter)
            IconButton(
              icon: Icon(editing ? Icons.edit : Icons.done),
              onPressed: () {
                setState(() {
                  editing = !editing;
                });
              },
            ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Open the Drawer to show the filter panel
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                    break;
                  }
                case MenuAction.settings:
                  // Navigate to the settings screen
                  Navigator.of(context).pushNamed(profileSettings);
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log out"),
                ),
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.settings,
                  child: Text("Settings"),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: getFilteredBouldersStream(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allBoulders = snapshot.data as Iterable<CloudBoulder>;
                return GestureDetector(
                  key: _gymKey,
                  onTapUp: (details) {
                    _tapping(context, details, allBoulders, currentProfile,
                        _userService);
                  },
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/background/dtu_climbing.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: CustomPaint(
                        painter: GymPainter(allBoulders, currentProfile!),
                      ),
                    ),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      drawer: filterDrawer(context, setState, currentProfile!),
    );
  }

  Future<void> _tapping(BuildContext context, TapUpDetails details,
      Iterable<CloudBoulder> allBoulders, currentProfile, userService) async {
    // Only add circles when zoomed in
    final gradingSystem =
        (currentProfile.gradingSystem).toString().toLowerCase();
    if (_controller.value.getMaxScaleOnAxis() >= minZoomThreshold) {
      final RenderBox referenceBox =
          _gymKey.currentContext?.findRenderObject() as RenderBox;

      // Convert the tap position to scene coordinates considering the transformation
      final localPosition = referenceBox.globalToLocal(details.globalPosition);

      // Create a copy of the transformation matrix and invert it
      final Matrix4 invertedMatrix = _controller.value.clone()..invert();

      // Create a Vector4 from the tap position
      final VM.Vector4 tapVector =
          VM.Vector4(localPosition.dx, localPosition.dy, 0, 1);

      // Transform the tap position using the inverted matrix
      final VM.Vector4 transformedPosition =
          invertedMatrix.transform(tapVector);
      const double minDistance =
          minBoulderDistance; // Set a minimum distance to avoid overlap

      if (editing) {
        // Check for existing circles and avoid overlap
        double tempCenterX = transformedPosition.x;
        double tempCenterY = transformedPosition.y;

        for (final existingBoulder in allBoulders) {
          double distance = calculateDistance(
            existingBoulder.cordX,
            existingBoulder.cordY,
            tempCenterX,
            tempCenterY,
          );

          if (distance < minDistance) {
            // Adjust the X position based on the number of boulders below it
            tempCenterX += minBoulderDistance;
          }
        }

        String? wall;

        for (final region in wallRegions) {
          double regionTop = region.regionTop;
          double regionBottom = region.regionBottom;

          if (tempCenterY >= regionBottom && tempCenterY <= regionTop) {
            wall = region.attribute;
            break;
          }
        }
        try {
          final setters = await userService.getSetters();
          setState(() {
            showAddNewBoulder(context, _boulderService, _userService,
                tempCenterX, tempCenterY, wall!, gradingSystem, setters);
          });
        } catch (error) {
          // Handle the error
          // ignore: avoid_print
          print(error);
        }
      } else {
        for (final boulders in allBoulders) {
          double distance = (boulders.cordX - transformedPosition.x).abs() +
              (boulders.cordY - transformedPosition.y).abs();
          if (distance < minDistance) {
            // Tapped inside the circle, perform the desired action
            showBoulderInformation(context, boulders, setState, currentProfile,
                _boulderService, _userService);
            break;
          }
        }
      }
    }
  }
}
