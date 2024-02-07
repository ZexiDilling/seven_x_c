// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/enums/menu_action.dart';
import 'package:seven_x_c/helpters/painter.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/auth/logout_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/comp/comp_rank_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/comp/comp_signup_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/stripping_boulder.dart';
import 'package:seven_x_c/utilities/dialogs/info/grading_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/slides/comp_slide.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/add_new_boulder.dart';
import 'package:seven_x_c/utilities/dialogs/boulder/show_boulder_info.dart';
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
      boulderSingleShow; // Adjust this threshold as needed this is for changing when you can add boulders. set to zero for testing purpose
  final TransformationController _controller = TransformationController();
  String get userId => AuthService.firebase().currentUser!.id;

  late CloudProfile? currentProfile;
  bool profileLoaded = false;
  bool editing = false;
  bool moveBoulder = false;
  String selectedBoulder = "";
  bool showWallRegions = false;
  bool filterEnabled = false;
  double currentScale = 1.0;
  int topCounter = 0;
  bool compView = false;
  CloudComp? currentComp;
  late CloudSettings? currentSettings;

  late final FirebaseCloudStorage _fireBaseService;

  late Stream<Iterable<CloudBoulder>> filteredBouldersStream;

  void setCompView(bool value) {
    setState(() {
      compView = value;
    });
  }

  void setCurrentComp(CloudComp value) {
    setState(() {
      currentComp = value;
    });
  }

  void toppedBoulderCount(int value) {
    setState(() {
      topCounter = value;
    });
  }

  Stream<Iterable<CloudBoulder>> getFilteredBouldersStream() {
    return _fireBaseService.getAllBoulders().map((boulders) {
      if (showAllBouldersFilter) {
        return boulders;
      } else {
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

        if (compFilter | compView) {
          // Filter boulders where comp is true
          boulders = boulders.where((boulder) => boulder.compBoulder == true);
        }

        // If no filters are applied, return the original stream
        return boulders;
      }
    });
  }

  @override
  void initState() {
    _fireBaseService = FirebaseCloudStorage();

    _initializeData();
    super.initState();
    filteredBouldersStream = getFilteredBouldersStream();
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    await _initSettings();
    _initSettingData();
  }

  _initSettingData() {
    Map<String, Map<String, int>> colorToGrade = {};

    for (var entry in currentSettings!.settingsGradeColour!.entries) {
      String name =
          entry.key.toLowerCase(); // Convert name to lowercase for consistency
      Map<String, dynamic> data = entry.value;

      int minGrade = data["min"] ?? 0;
      int maxGrade = data["max"] ?? 0;
      colorToGrade[name] = {"min": minGrade, "max": maxGrade};
    }
  }

  Future<CloudSettings?> _initSettings() async {
    final CloudSettings? tempSettings =
        await _fireBaseService.getSettings(currentProfile!.settingsID);
    setState(() {
      currentSettings = tempSettings;
    });
    return currentSettings;
  }

  Future<CloudProfile?> _initializeCurrentProfile() async {
    await for (final profiles
        in _fireBaseService.getUser(userID: userId.toString())) {
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
      return currentProfile;
    }
    return null;
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
              if (currentSettings != null) {
                return Text(currentSettings!.settingsName);
              } else {
                return const Text('Gym View - ??');
              }
            }

            if (snapshot.hasError) {
              return Text('Error:  ${snapshot.error}');
            }
            final bouldersCount = snapshot.data?.length ?? 0;
            topCounter = 0;
            for (CloudBoulder tempBoulder in snapshot.data!) {
              if (tempBoulder.climberTopped != null) {
                if (tempBoulder.climberTopped!.containsKey(userId)) {
                  topCounter++;
                }
              }
            }

            return compView
                ? Text(
                    currentComp!.compName,
                    style: compBarStyle,
                  )
                : moveBoulder
                    ? const Text("MOVING A BOULDER",
                        overflow: TextOverflow.ellipsis)
                    : Column(
                        children: [
                          Text(
                            currentSettings!.settingsName,
                            style: appBarStyle,
                          ),
                          Text(
                            '$topCounter/$bouldersCount',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      );
          },
        ),
        backgroundColor: compView ? compAppBarColour : dtuClimbingAppBar,
        actions: [
          compView
              ? IconButton(
                  onPressed: () {
                    showCompRankings(context,
                        compService: _fireBaseService,
                        currentComp: currentComp!,
                        currentProfile: currentProfile,
                        setCompView: setCompView);
                  },
                  icon: const Icon(IconManager.thropy))
              : const SizedBox(),
          if (editing)
            IconButton(
              icon: Icon(showWallRegions
                  ? IconManager.showWalls
                  : IconManager.doNotShowWalls),
              onPressed: () {
                setState(() {
                  showWallRegions = !showWallRegions;
                });
              },
            ),
          if (currentProfile!.isAdmin && !moveBoulder ||
              currentProfile!.isSetter && !moveBoulder)
            IconButton(
              icon: Icon(
                  editing ? IconManager.edditing : IconManager.doneEdditing),
              onPressed: () {
                setState(() {
                  editing = !editing;
                });
              },
            ),
          if (moveBoulder)
            IconButton(
              icon: Icon(IconManager.cancel),
              onPressed: () {
                setState(() {
                  moveBoulder = false;
                  selectedBoulder = "";
                });
              },
            ),
          dropDownMenu(context)
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return StreamBuilder(
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
                      _tapping(context, constraints, details, allBoulders,
                          currentProfile, _fireBaseService);
                    },
                    onDoubleTapDown: (details) {
                      _doubleTapping(context, constraints, details);
                      setState(() {
                          currentScale = _controller.value.getMaxScaleOnAxis();
                        });
                    },
                    child: InteractiveViewer(
                      transformationController: _controller,
                      minScale: 0.5,
                      maxScale: 5.0,
                      onInteractionEnd: (details) {
                        setState(() {
                          currentScale = _controller.value.getMaxScaleOnAxis();
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/background/dtu_climbing.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: CustomPaint(
                          painter: GymPainter(
                              context,
                              constraints,
                              allBoulders,
                              currentProfile!,
                              currentSettings!,
                              currentScale,
                              compView,
                              showWallRegions),
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
        );
      }),
      drawer: compView
          ? currentProfile!.isAdmin
              ? compDrawer(context, setState, currentComp!, _fireBaseService)
              : null
          : filterDrawer(context, setState, currentProfile!, currentSettings!),
    );
  }

  PopupMenuButton<MenuAction> dropDownMenu(BuildContext context) {
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
                    _fireBaseService, wallRegionMap);
              });
            } catch (error) {
              showErrorDialog(context, error.toString());
            }
            for (WallRegion wall in wallRegions) {
              wallRegionMap[wall.wallID]!.isSelected = false;
            }
          case MenuAction.adminPanel:
            Navigator.of(context).pushNamed(adminPanel);
          case MenuAction.rankings:
            Navigator.of(context).pushNamed(rankView);
          case MenuAction.profile:
            Navigator.of(context).pushNamed(profileView);
          case MenuAction.comp:
            showComp(
              context,
              currentProfile: currentProfile,
              fireBaseService: _fireBaseService,
              compView: compView,
              setCompView: setCompView,
              setComp: setCurrentComp,
            );
          case MenuAction.info:
            showGradeInfo(context, currentSettings!, currentProfile!);
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: MenuAction.profile,
            child: Text("Profile"),
          ),
          const PopupMenuItem(
            value: MenuAction.rankings,
            child: Text("Rankings"),
          ),
          const PopupMenuItem(
            value: MenuAction.settings,
            child: Text("Settings"),
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
            ),
          const PopupMenuItem(
            value: MenuAction.comp,
            child: Text("Comp"),
          ),
          const PopupMenuItem(
            value: MenuAction.info,
            child: Text("Info"),
          ),
          const PopupMenuItem(
            value: MenuAction.logout,
            child: Text("Log out"),
          ),
        ];
      },
    );
  }

  Future<void> _tapping(
      BuildContext context,
      constraints,
      TapUpDetails details,
      Iterable<CloudBoulder> allBoulders,
      currentProfile,
      fireBaseService) async {
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
      double minDistance =
          minBoulderDistance; // Set a minimum distance to avoid overlap
      final setters = await fireBaseService.getSetters();

      if (editing || moveBoulder) {
        // Check for existing circles and avoid overlap
        double tempCenterX = transformedPosition.x;
        double tempCenterY = transformedPosition.y;

        for (final existingBoulder in allBoulders) {
          double distance = calculateDistance(
            existingBoulder.cordX * constraints.maxWidth,
            existingBoulder.cordY * constraints.maxHeight,
            tempCenterX,
            tempCenterY,
          );

          if (distance < minDistance) {
            // Adjust the X position based on the number of boulders below it
            tempCenterX -= minBoulderDistance;
          }
        }

        String? wall;

        for (final region in wallRegions) {
          double regionTop = region.wallYMaX;
          double regionBottom = region.wallYMin;
          if (tempCenterY / constraints.maxHeight >= regionBottom &&
              tempCenterY / constraints.maxHeight <= regionTop) {
            wall = region.wallName;
            break;
          }
        }

        if (moveBoulder) {
          fireBaseService.updateBoulder(
              boulderID: selectedBoulder,
              cordX: tempCenterX / constraints.maxWidth,
              cordY: tempCenterY / constraints.maxHeight);
          setState(() {
            moveBoulder = false;
            selectedBoulder = "";
          });
        } else {
          try {
            setState(() {
              showAddNewBoulder(
                  context,
                  constraints,
                  currentProfile,
                  currentComp,
                  compView,
                  tempCenterX,
                  tempCenterY,
                  wall!,
                  gradingSystem,
                  colorToGrade,
                  _fireBaseService,
                  currentSettings!,
                  setters);
            });
          } catch (error) {
            // Handle the error
            // ignore: avoid_print
            print(error);
          }
        }
      } else {
        CloudBoulder? closestBoulder;
        for (final boulders in allBoulders) {
          double distance = ((boulders.cordX * constraints.maxWidth) -
                      transformedPosition.x)
                  .abs() +
              ((boulders.cordY * constraints.maxHeight) - transformedPosition.y)
                  .abs();

          if (distance < minDistance) {
            minDistance = distance;
            closestBoulder = boulders;
          }
          if (closestBoulder != null) {
            List<String> challengesOverview = await _fireBaseService
                .grabBoulderChallenges(boulderID: closestBoulder.boulderID);
            challengesOverview.add("create");
            // Tapped inside the circle, perform the desired action
            // ignore: use_build_context_synchronously
            final result = await showBoulderInformation(
                context,
                setState,
                closestBoulder,
                currentProfile,
                currentComp,
                compView,
                _fireBaseService,
                currentSettings!,
                setters,
                challengesOverview);
            // setState(() {
            //   showBoulderInformation(
            //       context,
            //       setState,
            //       closestBoulder!,
            //       currentProfile,
            //       currentComp,
            //       compView,
            //       _fireBaseService,
            //       currentSettings!,
            //       setters,
            //       challengesOverview);
            // });
            if (result == true) {
              setState(() {
                moveBoulder = true;
                selectedBoulder = closestBoulder!.boulderID;
              });
            }
            break;
          }
        }
      }
    }
  }

  Future<void> _doubleTapping(context, constraints, details) async {
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
    final VM.Vector4 transformedPosition = invertedMatrix.transform(tapVector);

    final WallRegion nearestWall = findNearestWallRegion(
      transformedPosition,
      wallRegions,
      constraints,
    );
    final Offset center = Offset(
      (((nearestWall.wallXMax + nearestWall.wallXMin) / 2) * constraints.maxWidth),
        ((nearestWall.wallYMaX + nearestWall.wallYMin) / 2) * constraints.maxHeight,
    );

    _controller.value = Matrix4.identity()
      ..translate(-center.dx * 2.0, -center.dy * 2.0)
      ..scale(3.0);

  }

  WallRegion findNearestWallRegion(
    localPosition,
    List<WallRegion> wallRegions,
    BoxConstraints constraints,
  ) {
    WallRegion? nearestWallRegion; // Initialize with null
    double minDistance = double.infinity;

    for (final WallRegion wall in wallRegions) {
      final Offset center = Offset(
        (((wall.wallXMax + wall.wallXMin) / 2) * constraints.maxWidth),
        ((wall.wallYMaX + wall.wallYMin) / 2) * constraints.maxHeight,
      );

      double tempCenterX = localPosition.x;
      double tempCenterY = localPosition.y;

      double distance = calculateDistance(
        center.dx,
        center.dy,
        tempCenterX,
        tempCenterY,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestWallRegion = wall;
      }
    }

    return nearestWallRegion!;
  }
}
