import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/constants/other_const.dart';
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
  Iterable? areaBoulders;

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
                            onTapUp: (details) {},
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
                                  SvgPicture.asset(
                                    'assets/background/dtu_climbing.svg',
                                    semanticsLabel: "background",
                                    fit: BoxFit.fill,
                                  ),
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
      title: Text(currentLocation),
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

    final Offset center = Offset(
      (((transformedPosition.x) / 2) * constraints.maxWidth),
      ((transformedPosition.y) / 2) * constraints.maxHeight,
    );
    _controller.value = Matrix4.identity()
      ..translate(-center.dx * 2.0, -center.dy * 2.0)
      ..scale(3.0);
  }
}
