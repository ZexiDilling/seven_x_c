// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/enums/menu_action.dart';
import 'package:seven_x_c/helpters/painter.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/stripping_boulder.dart';
import 'package:seven_x_c/utilities/dialogs/error_dialog.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/add_new_boulder.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/show_boulder_info.dart';
import 'package:seven_x_c/utilities/dialogs/logout_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/slides/filter_silde.dart';
import 'package:vector_math/vector_math_64.dart' as VM;

GlobalKey _gymKey = GlobalKey();

class GymView extends StatefulWidget {
  const GymView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GymViewState createState() => _GymViewState();
}

class _GymViewState extends State<GymView> {
  final List<CircleInfo> allBoulders = [];
  final double minZoomThreshold =
      0; // Adjust this threshold as needed this is for changing when you can add boulders. set to zero for testing purpose
  // TODO: Handle this case.
  final TransformationController _controller = TransformationController();
  String get userId => AuthService.firebase().currentUser!.id;

  late CloudProfile? currentProfile;
  bool profileLoaded = false;
  bool editing = false;
  bool filterEnabled = false;

  late final FirebaseCloudStorage _boulderService;
  late final FirebaseCloudStorage _userService;

  late Stream<Iterable<CloudBoulder>> filteredBouldersStream;

  Stream<Iterable<CloudBoulder>> getFilteredBouldersStream() {
    return _boulderService.getAllBoulders().map((boulders) {
      if (selectedColors.isNotEmpty) {
        boulders = boulders.where((boulder) =>
            selectedColors.contains(boulder.gradeColour.toLowerCase()));
      }

      boulders = boulders.where((boulder) =>
          boulder.gradeNumberSetter >= gradeSliderRange.start &&
          boulder.gradeNumberSetter <= gradeSliderRange.end);

      if (missingFilter) {
        // Filter out boulders where the current user has topped
        boulders = boulders.where((boulder) {
          var userClimbInfo = boulder.climberTopped?[currentProfile!.userID];
          return (userClimbInfo?['topped'] ?? false) == false;
        });
      }

      if (newFilter) {
        // Filter boulders where setDate is less than 5 days ago
        final currentDate = DateTime.now();
        boulders = boulders.where((boulder) {
          final setDate = (boulder.setDateBoulder).toDate();
          return currentDate.difference(setDate).inDays < 5;
        });
      }

      if (updateFilter) {
        // Filter boulders where updateDate is different from setDate
        boulders = boulders.where((boulder) {
          final setDate = (boulder.setDateBoulder).toDate();
          final updateDate = (boulder.updateDateBoulder)?.toDate();

          // Include the boulder in the result if both dates are non-null and different
          return updateDate != null && setDate != updateDate;
        });
      }

      if (compFilter) {
        // Filter boulders where comp is true
        boulders = boulders.where((boulder) => boulder.compBoulder == true);
      }

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
    filteredBouldersStream = getFilteredBouldersStream();
  }

  Future<void> _initializeCurrentProfile() async {
    await for (final profiles
        in _userService.getUser(userID: userId.toString())) {
      if (profiles.isNotEmpty) {
        final CloudProfile profile = profiles.first;
        if (profile.displayName == "") {
          Navigator.of(context).popAndPushNamed(profileSettings);
        } else {
          setState(() {
            currentProfile = profile;
            profileLoaded = true;
          });
        }
      } else {
        Navigator.of(context).popAndPushNamed(profileSettings);
      }
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
        title: StreamBuilder<Iterable<CloudBoulder>>(
          stream: getFilteredBouldersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Stream is still loading
              return const Text('DTU Climbing - ??');
            }

            if (snapshot.hasError) {
              // Handle error
              return Text('Error: ${snapshot.error}');
            }

            // Use the length of the boulders list to update the app bar title
            final bouldersCount = snapshot.data?.length ?? 0;
            return Text('DTU Climbing - $bouldersCount');
          },
        ),
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
          extraMenu(context)
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

  PopupMenuButton<MenuAction> extraMenu(BuildContext context) {
    return PopupMenuButton<MenuAction>(
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
            Navigator.of(context).pushNamed(profileSettings);

          case MenuAction.stripping:
            Map<String, WallRegion> wallRegionMap = {
              for (var region in wallRegions) region.wallID: region
            };
            try {
              setState(() {
                stripping(context, setState, filteredBouldersStream,
                    _boulderService, wallRegionMap);
              });
            } catch (error) {
              showErrorDialog(context, error.toString());
            }
            for (WallRegion wall in wallRegions) {
              wallRegionMap[wall.wallID]!.isSelected = false;
            }
          case MenuAction.adminPanel:
            Navigator.of(context).pushNamed(adminPanel);
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: MenuAction.settings,
            child: Text("Settings"),
          ),
          const PopupMenuItem(
            value: MenuAction.logout,
            child: Text("Log out"),
          ),
          if (currentProfile!.isSetter | currentProfile!.isAdmin)
            const PopupMenuItem(
              value: MenuAction.stripping,
              child: Text("Stripping"),
            ),
          if (currentProfile!.isAdmin)
            const PopupMenuItem(
              value: MenuAction.adminPanel,
              child: Text("Admin"),
            )
        ];
      },
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
      final setters = await userService.getSetters();
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
          double regionTop = region.wallXMax;
          double regionBottom = region.wallXMin;

          if (tempCenterY >= regionBottom && tempCenterY <= regionTop) {
            wall = region.wallName;
            break;
          }
        }
        try {
          setState(() {
            showAddNewBoulder(
                context,
                _boulderService,
                _userService,
                tempCenterX,
                tempCenterY,
                wall!,
                gradingSystem,
                currentProfile,
                setters);
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
            setState(() {
              showBoulderInformation(context, boulders, setState,
                  currentProfile, _boulderService, _userService, setters);
            });

            break;
          }
        }
      }
    }
  }
}
