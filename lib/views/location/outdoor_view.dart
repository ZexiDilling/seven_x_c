import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/constants/outdoor_info.dart';
import 'package:seven_x_c/constants/outdoor_info.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/constants/slide_up_const.dart';
import 'package:seven_x_c/enums/menu_action.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/auth/bloc/auth_bloc.dart';
import 'package:seven_x_c/services/auth/bloc/auth_event.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/utilities/dialogs/slides/filter_silde.dart';

import 'package:seven_x_c/services/cloude/location_data/cloud_outdoor_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/logout_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/slides/comp_slide.dart';
import 'package:seven_x_c/utilities/dialogs/slides/slide_up.dart';
import 'package:seven_x_c/utilities/polygone/polygone_painter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vector_math/vector_math_64.dart' as VM;

GlobalKey _gymKey = GlobalKey();

class OutdoorView extends StatefulWidget {
  const OutdoorView({super.key});
  @override
  State<OutdoorView> createState() => _OutdoorView();
}

class _OutdoorView extends State<OutdoorView> {
  late CloudProfile? currentProfile;
  CloudSettings? currentSettings;
  CloudOutdoorData? currentOutdoorData;
  bool profileLoaded = false;
  late final FirebaseCloudStorage _fireBaseService;
  String get userId => AuthService.firebase().currentUser!.id;
  String currentLocation = "kjugge";
  String locationOverview = "KjuggeOverview";
  String subLocation = "";
  Iterable? areaBoulders;
  bool overviewMap = true;
  bool detailMap = false;
  bool regionPainter = false;

  // map thingys
  final double minZoomThreshold = boulderSingleShow;
  final TransformationController _controller = TransformationController();
  double currentScale = 1.0;
  int topCounter = 0;
  bool filterEnabled = false;

  // editing the area
  bool editing = false;
  bool showAll = false;
  bool moveBoulder = false;
  bool moveMultipleBoulders = false;
  String selectedBoulder = "";
  List offsets = [];
  Map<String, List<List<Offset>>> convertedPolygons = {
    "overview": [],
    "sublocation": [],
  };

  @override
  void initState() {
    _fireBaseService = FirebaseCloudStorage();

    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    await _initializeCurrentProfile();
    // await _initSettings();
    await _initOutdoorData();
    convertedPolygons = convertPolygons(outsideRegions);
    // _initSettingData();
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

  Future<CloudOutdoorData?> _initOutdoorData() async {
    final CloudOutdoorData? tempOutdoorData =
        await _fireBaseService.getOutdoorData(currentProfile!.settingsID);
    setState(() {
      currentOutdoorData = tempOutdoorData;
    });
    return currentOutdoorData;
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
      appBar: appBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder(
              stream: getFilteredBouldersStream(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allBoulders = snapshot.data;
                      return SlidingUpPanel(
                          minHeight: slideUpMinHeight,
                          maxHeight: MediaQuery.of(context).size.height *
                              slideUpMaxHeight,
                          panel: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          collapsed: slideUpCollapsContent(),
                          body: GestureDetector(
                            key: _gymKey,
                            onTapUp: (details) {
                              regionPainter
                                  ? overviewMap
                                      ? print("hej")
                                      // drawRegions(
                                      //     'assets/background/$locationOverview.jpg')
                                      : drawRegions(
                                          'assets/background/$subLocation.jpg')
                                  : overviewMap
                                      ? _tapSelectSubMap(
                                          context, constraints, details)
                                      : detailMap
                                          ? _tapSelectSubMap(
                                              context, constraints, details)
                                          : _tapselectedBoulder(
                                              context,
                                              constraints,
                                              details,
                                              allBoulders,
                                              currentProfile,
                                              _fireBaseService);
                            },
                            onDoubleTapDown: (details) {
                              _doubleTapping(context, constraints, details);
                              setState(() {
                                currentScale =
                                    _controller.value.getMaxScaleOnAxis();
                              });
                            },
                            child: InteractiveViewer(
                              transformationController: _controller,
                              minScale: 0.5,
                              maxScale: 10.0,
                              onInteractionEnd: (details) {
                                setState(() {
                                  currentScale =
                                      _controller.value.getMaxScaleOnAxis();
                                });
                              },
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Stack(children: [
                                  overviewMap
                                      ? Image.asset(
                                          'assets/background/$locationOverview.jpg',
                                          fit: BoxFit.fill,
                                        )
                                      : (() {
                                          if (subLocation.isNotEmpty) {
                                            final imagePath =
                                                'assets/background/$subLocation.jpg';
                                            return Image.asset(
                                              imagePath,
                                              fit: BoxFit.fill,
                                            );
                                          } else {
                                            return Container(); // or any default widget
                                          }
                                        })(),
                                  CustomPaint(
                                      painter: RegionPainter(
                                          outsideRegions, constraints))
                                ]),
                              ),
                            ),
                          ));
                    } else {
                      return const CircularProgressIndicator();
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              });
        },
      ), // Replace this with your actual content
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: overviewMap ? Text(currentLocation) : Text(subLocation),
      backgroundColor: dtuClimbingAppBar,
      actions: [
        const SizedBox(),
        if (editing)
          IconButton(
            icon: Icon(
              showAll
                  ? IconManager.showDeactivatedBoulders
                  : IconManager.showDeactivatedBoulders,
              color: showAll
                  ? IconManagerColours.active
                  : IconManagerColours.inActive,
            ),
            onPressed: () {
              setState(() {
                showAll = !showAll;
              });
            },
          ),
        if (editing)
          IconButton(
            icon: Icon(
              moveMultipleBoulders
                  ? IconManager.moveMultipleBoulders
                  : IconManager.moveMultipleBoulders,
              color: moveMultipleBoulders
                  ? IconManagerColours.active
                  : IconManagerColours.inActive,
            ),
            onPressed: () {
              setState(() {
                moveMultipleBoulders = !moveMultipleBoulders;
              });
            },
          ),
        if (currentProfile!.isAdmin && !moveBoulder ||
            currentProfile!.isSetter && !moveBoulder)
          IconButton(
            icon: Icon(
              editing ? IconManager.editing : IconManager.editing,
              color: editing
                  ? IconManagerColours.active
                  : IconManagerColours.inActive,
            ),
            onPressed: () {
              setState(() {
                editing = !editing;
              });
            },
          ),
        if (moveBoulder)
          IconButton(
            icon: const Icon(IconManager.cancel),
            onPressed: () {
              setState(() {
                moveBoulder = false;
                selectedBoulder = "";
              });
            },
          ),
        if (currentProfile!.isAdmin)
          IconButton(
            icon: Icon(
              editing ? IconManager.editing : IconManager.editing,
              color: regionPainter
                  ? IconManagerColours.active
                  : IconManagerColours.inActive,
            ),
            onPressed: () {
              setState(() {
                regionPainter = !regionPainter;
              });
            },
          ),
        dropDownMenu(context, currentSettings)
      ],
    );
  }

  PopupMenuButton<MenuActionMain> dropDownMenu(
      BuildContext context, CloudSettings? currentSettings) {
    return PopupMenuButton<MenuActionMain>(
      onSelected: (value) async {
        switch (value) {
          case MenuActionMain.logout:
            final shouldLogout = await showLogOutDialog(context);
            if (shouldLogout) {
              // ignore: use_build_context_synchronously
              context.read<AuthBloc>().add(
                    const AuthEventLogOut(),
                  );
              break;
            }
          case MenuActionMain.settings:
            Navigator.of(context).pushNamed(profileSettings).then((_) {
              _initializeData();
            });
            break;

          case MenuActionMain.adminPanel:
            Navigator.of(context).pushNamed(adminPanel);
          case MenuActionMain.rankings:
            Navigator.of(context).pushNamed(rankView);
          case MenuActionMain.profile:
            Navigator.of(context).pushNamed(
              profileView,
              arguments: currentSettings!,
            );

          case MenuActionMain.location:
            Navigator.of(context).pushNamed(
              // locationView,
              mapView,
              arguments: currentSettings!,
            );
          case MenuActionMain.stripping:
          // TODO: Handle this case.
          case MenuActionMain.comp:
          // TODO: Handle this case.
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: MenuActionMain.profile,
            child: Text("Profile"),
          ),
          const PopupMenuItem(
            value: MenuActionMain.rankings,
            child: Text("Rankings"),
          ),
          const PopupMenuItem(
            value: MenuActionMain.settings,
            child: Text("Settings"),
          ),
          if (currentProfile!.isAdmin)
            const PopupMenuItem(
              value: MenuActionMain.adminPanel,
              child: Text("Admin"),
            ),
          if (currentProfile!.isAdmin)
            const PopupMenuItem(
                value: MenuActionMain.location, child: Text("Change Location")),
          const PopupMenuItem(
            value: MenuActionMain.logout,
            child: Text("Log out"),
          ),
        ];
      },
    );
  }

  Stream<Iterable<Map<String, dynamic>?>> getFilteredBouldersStream() {
    return _fireBaseService
        .getAllOutdoorBoulders(currentLocation)
        .map((boulders) {
      if (showAllBouldersFilter) {
        return boulders;
      } else {
        Iterable<Map<String, dynamic>?> filteredBoulders = boulders;

        if (missingFilter) {
          // Filter out boulders where the current user has topped
          filteredBoulders = filteredBoulders.where((boulder) {
            var userClimbInfo =
                boulder?['outdoorDataBouldersTopped']?[currentProfile!.userID];
            return (userClimbInfo?['topped'] ?? false) == false;
          });
        }

        if (tagFilter.isNotEmpty) {
          // Filter boulders based on tags
          filteredBoulders = filteredBoulders.where((boulder) =>
              (boulder?['outdoorSections']?['tags'] as List<dynamic>? ?? [])
                  .any((tag) => tagFilter.contains(tag)));
        }

        return filteredBoulders;
      }
    });
  }

  Future<void> _doubleTapping(BuildContext context, BoxConstraints constraints,
      TapDownDetails details) async {
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

    final Offset center = Offset(
      (((transformedPosition.x) / 2) * constraints.maxWidth),
      ((transformedPosition.y) / 2) * constraints.maxHeight,
    );
    _controller.value = Matrix4.identity()
      ..translate(-center.dx * 2.0, -center.dy * 2.0)
      ..scale(3.0);
  }

  Future<void> _tapSelectSubMap(BuildContext context,
      BoxConstraints constraints, TapUpDetails details) async {
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
    double tempCenterX = transformedPosition.x;
    double tempCenterY = transformedPosition.y;

    // print("Offset(${tempCenterX/constraints.maxWidth}, ${tempCenterY/constraints.maxHeight})");
    // dynamic offset = (tempCenterX / constraints.maxWidth, tempCenterY / constraints.maxHeight);
    // offsets.add(offset);
    // print(offsets);
    final tappedPolygon = outsideRegions.firstWhere(
      (region) {
        return _isPointInsidePolygon(tempCenterX, tempCenterY,
            region.regionPolygonOverview, constraints);
      },
    );

    if (tappedPolygon != null) {
      setState(() {
        subLocation = tappedPolygon.imageName;
        overviewMap = false;
        detailMap = !detailMap;
      });
    }
  }

  Future<void> _tapselectedBoulder(
      BuildContext context,
      BoxConstraints constraints,
      TapUpDetails details,
      Iterable<Map<String, dynamic>?>? allBoulders,
      CloudProfile? currentProfile,
      FirebaseCloudStorage fireBaseService) async {
    final gradingSystem =
        (currentProfile!.gradingSystem).toString().toLowerCase();
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

      if (editing || moveBoulder) {
        // Check for existing circles and avoid overlap
        double tempCenterX = transformedPosition.x;
        double tempCenterY = transformedPosition.y;

        for (final existingBoulder in allBoulders!) {
          double distance = calculateDistance(
            existingBoulder!["cordX"] * constraints.maxWidth,
            existingBoulder["cordY"] * constraints.maxHeight,
            tempCenterX,
            tempCenterY,
          );

          if (distance < minDistance) {
            // Adjust the X position based on the number of boulders below it
            tempCenterX -= minBoulderDistance;
          }
        }

        String? regionName;
        String lowestRegionName = "";
        double regionTestValue = 1;

        for (final key in currentOutdoorData!.outdoorSections!.keys) {
          final region = currentOutdoorData!.outdoorSections?[key];

          double regionTop = region['regionYMaX'] as double;
          double regionBottom = region['regionYMin'] as double;

          if (regionBottom < regionTestValue) {
            regionTestValue = regionBottom;
            lowestRegionName = region.regionName;
          }
          if (tempCenterY / constraints.maxHeight >= regionBottom &&
              tempCenterY / constraints.maxHeight <= regionTop) {
            regionName = region.regionName;
            break;
          }
        }
        regionName ??= lowestRegionName;
        if (moveBoulder) {
          fireBaseService.updateBoulder(
              boulderID: selectedBoulder,
              cordX: tempCenterX / constraints.maxWidth,
              cordY: tempCenterY / constraints.maxHeight);
          setState(() {
            moveBoulder = false;
            selectedBoulder = "";
          });
        } else if (moveMultipleBoulders) {
          Map<String, dynamic>? closestBoulder;
          for (final boulders in allBoulders) {
            double distance = ((boulders!["cordX"] * constraints.maxWidth) -
                        transformedPosition.x)
                    .abs() +
                ((boulders["cordY"] * constraints.maxHeight) -
                        transformedPosition.y)
                    .abs();

            if (distance < minDistance) {
              minDistance = distance;
              closestBoulder = boulders;
            }
            if (closestBoulder != null) {
              setState(() {
                moveBoulder = true;
                selectedBoulder = closestBoulder!["boulderID"];
              });
            }
          }
        } else {
          try {
            setState(() {
              addNewOutdoorClimb(
                context,
                constraints,
                currentProfile,
                tempCenterX,
                tempCenterY,
                subLocation,
                gradingSystem,
                _fireBaseService,
                currentSettings!,
                currentOutdoorData,
              );
            });
          } catch (error) {
            // Handle the error
            // ignore: avoid_print
            print(error);
          }
        }
      } else {
        Map<String, dynamic>? closestBoulder;
        for (final boulders in allBoulders!) {
          double distance = ((boulders!["cordX"] * constraints.maxWidth) -
                      transformedPosition.x)
                  .abs() +
              ((boulders["cordY"] * constraints.maxHeight) -
                      transformedPosition.y)
                  .abs();

          if (distance < minDistance) {
            minDistance = distance;
            closestBoulder = boulders;
          }
          if (closestBoulder != null) {
            List<String> challengesOverview = await _fireBaseService
                .grabBoulderChallenges(boulderID: closestBoulder["boulderID"]);
            challengesOverview.add("create");
            // Tapped inside the circle, perform the desired action
            // ignore: use_build_context_synchronously
            final result = await showOutdoorBoulderInformation(
              context,
              setState,
              closestBoulder,
              currentProfile,
            );
            if (result == true) {
              setState(() {
                moveBoulder = true;
                selectedBoulder = closestBoulder!["boulderID"];
              });
            }
            break;
          }
        }
      }
    }
  }

  Map<String, List<List<Offset>>> convertPolygons(
      List<OutsideRegion>? outsideRegions) {
    if (outsideRegions != null) {
      for (var region in outsideRegions) {
        List<Offset> polygonOverview =
            region.regionPolygonOverview.map((point) {
          return Offset(point.dx, point.dy); // Access dx and dy properties
        }).toList();
        convertedPolygons["overview"]!.add(polygonOverview);

        List<Offset> polygonSublocation =
            region.regionPolygonSublocation.map((point) {
          return Offset(point.dx, point.dy); // Access dx and dy properties
        }).toList();
        convertedPolygons["sublocation"]!.add(polygonSublocation);
      }
    }
    return convertedPolygons;
  }
}

bool _isPointInsidePolygon(tempCenterX, tempCenterY, List<Offset> polygon,
    BoxConstraints constraints) {
  int i, j = polygon.length - 1;
  bool isInside = false;

  for (i = 0; i < polygon.length; i++) {
    if ((polygon[i].dy * constraints.maxHeight > tempCenterY) != (polygon[j].dy * constraints.maxHeight > tempCenterY) &&
        (tempCenterX <
            (polygon[j].dx * constraints.maxWidth - polygon[i].dx * constraints.maxWidth) *
                    (tempCenterY - polygon[i].dy * constraints.maxHeight) /
                    (polygon[j].dy * constraints.maxHeight - polygon[i].dy * constraints.maxHeight) +
                polygon[i].dx * constraints.maxWidth)) {
      isInside = !isInside;
    }
    j = i;
  }

  return isInside;
}

showOutdoorBoulderInformation(
    BuildContext context,
    void Function(VoidCallback fn) setState,
    Map<String, dynamic> closestBoulder,
    CloudProfile currentProfile) {}

void addNewOutdoorClimb(
    BuildContext context,
    BoxConstraints constraints,
    CloudProfile currentProfile,
    double tempCenterX,
    double tempCenterY,
    String subLocation,
    String gradingSystem,
    FirebaseCloudStorage fireBaseService,
    CloudSettings cloudSettings,
    CloudOutdoorData? currentOutdoorData) {}
