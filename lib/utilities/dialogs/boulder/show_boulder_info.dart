import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/constants/challenge_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/helpters/bonus_functions.dart';
import 'package:seven_x_c/services/cloude/settings/cloud_settings.dart';
import 'package:seven_x_c/utilities/dialogs/challenge/challenge_create.dart';
import 'package:seven_x_c/helpters/comp/comp_calculations.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/challenges/cloud_challenges.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/charts/barcharts_gradings.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/challenge/add_exisiting.dart';
import 'package:seven_x_c/utilities/dialogs/generics/info_popup.dart';
import 'package:seven_x_c/utilities/dialogs/generics/yes_no.dart';

Future<bool> showBoulderInformation(
    BuildContext context,
    setState,
    CloudBoulder boulder,
    CloudProfile currentProfile,
    CloudComp? currentComp,
    bool compView,
    FirebaseCloudStorage fireBaseService,
    CloudSettings currentSettings,
    Stream<Iterable<CloudProfile>> settersStream,
    List<String> challengesOverview) async {
  int attempts = 0;
  int repeats = 0;
  bool flashed = false;
  bool topped = false;
  String gradingSystem = currentProfile.gradingSystem.toString().toLowerCase();
  String? gradingShow = "";
  bool editing = false;
  bool moveBoulder = false;
  // ignore: unused_local_variable
  String selectedBoulder = "";
  int difficultyLevel = 1;
  String? holdColorChoice;
  String? gradeColorChoice;
  String gradeColors = "";
  String? selectedGrade = '';
  int? gradeValue = 0;
  List<String> allGradeColorChoice = [];
  String labelText = "Vote a Grade";
  bool expandPanelState = false;

  // size of grading circle:
  double circleWidth = 40;
  double circleHeight = 40;

  Map<String, bool> expandedStates = {};

  bool active = boulder.active;
  bool updatedBoulder = false;
  bool topOut = boulder.topOut;
  bool compBoulder = boulder.compBoulder;
  bool hiddenGrade = boulder.hiddenGrade;

  List<Map<String, dynamic>> toppersList = [];

  if (boulder.climberTopped != null &&
      boulder.climberTopped is Map<String, dynamic>) {
    boulder.climberTopped!.forEach(
      (userId, climbInfo) async {
        if (climbInfo['topped'] == true) {
          final profiles =
              await fireBaseService.getUser(userID: userId.toString()).first;
          final tempProfile = profiles.isNotEmpty ? profiles.first : null;
          if (tempProfile!.isAnonymous) {
            // Add climber information to the toppersList map
            toppersList.add({
              'name': "Anonymous",
              'flashed': climbInfo['flashed'] ?? false,
            });
          } else {
            // Add climber information to the toppersList map
            toppersList.add({
              'name': tempProfile.displayName,
              'flashed': climbInfo['flashed'] ?? false,
            });
          }
        }
      },
    );
    if (boulder.climberTopped!.containsKey(currentProfile.userID)) {
      var userClimbInfo = boulder.climberTopped![currentProfile.userID];
      attempts = userClimbInfo['attempts'] ?? 0;
      repeats = userClimbInfo["repeats"] ?? 0;
      flashed = userClimbInfo['flashed'] ?? false;
      topped = userClimbInfo['topped'] ?? false;
      gradeValue = userClimbInfo["gradeNumber"] ?? 0;

      if (userClimbInfo["gradeColour"] != "" &&
          userClimbInfo["gradeColour"] != null) {}
      gradeColorChoice = userClimbInfo["gradeColour"] ?? boulder.gradeColour;
      difficultyLevel = userClimbInfo["gradeArrow"] ?? 3;
      selectedGrade = allGrading[gradeValue]![gradingSystem];
    }
  }

  if (gradingSystem == "coloured") {
    gradingShow = getArrowFromNumberAndColor(
        boulder.gradeNumberSetter, boulder.gradeColour);
  } else {
    gradingShow = allGrading[boulder.gradeNumberSetter]![gradingSystem.toLowerCase()];
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder(
          stream: settersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final Iterable<CloudProfile> profiles = snapshot.data!;
              final List<String> setters = profiles.isNotEmpty
                  ? profiles.map((profile) => profile.displayName).toList()
                  : [];

              String selectedSetter = setters.isNotEmpty ? boulder.setter : '';

              if (!setters.contains(selectedSetter)) {
                selectedSetter = setters.first;
              }

              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        const SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 150,
                          child: Card(
                            child: ListTile(
                              tileColor: const Color.fromARGB(111, 80, 94, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                              ),
                              leading: Container(
                                width: circleWidth,
                                height: circleHeight,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: nameToColor(
                                      currentSettings.settingsHoldColour![
                                          boulder.holdColour]), // Outline color
                                ),
                                child: Center(
                                  child: gradingInnerCirleDrawing(
                                      circleWidth,
                                      circleHeight,
                                      boulder,
                                      currentSettings,
                                      gradingShow),
                                ),
                              ),
                              title: Text("Setter: ${boulder.setter}",
                                  style: TextStyle(
                                    fontSize: (boulder.setter.length > 10)
                                        ? 15.0
                                        : 15.0,
                                  )),
                              subtitle: Text(boulder.boulderName ?? ""),
                              trailing: topOut
                                  ? const Icon(IconManager.topOut,
                                      size: 25.0, color: Colors.green)
                                  : const Text(""),
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: currentProfile.isAdmin ||
                                      currentProfile.isSetter,
                                  child: IconButton(
                                    icon: Icon(editing
                                        ? IconManager.editing
                                        : IconManager.doneEdditing),
                                    onPressed: () {
                                      labelText = editing
                                          ? "Vote a Grade"
                                          : "Choose a Grade";
                                      gradeColorChoice = boulder.gradeColour;
                                      gradeValue = boulder.gradeNumberSetter;
                                      difficultyLevel = getdifficultyFromArrow(
                                          getArrowFromNumberAndColor(
                                              gradeValue!,
                                              boulder.gradeColour));
                                      setState(() {
                                        editing = !editing;
                                      });
                                    },
                                  ),
                                ),
                                Visibility(
                                    visible: currentProfile.isAdmin ||
                                        currentProfile.isSetter,
                                    child: IconButton(
                                        icon:
                                            const Icon(IconManager.moveBoulder),
                                        onPressed: () {
                                          setState(() {
                                            moveBoulder = true;
                                            selectedBoulder = boulder.boulderID;
                                          });
                                          Navigator.of(context).pop(true);
                                        }))
                              ],
                            ),
                            Visibility(
                              visible: !editing,
                              child: Column(
                                children: [
                                  Row(children: [
                                    const Text("Topped"),
                                    Checkbox(
                                      value: topped,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          topped = value ?? false;

                                          if (compView) {
                                            if (currentComp!.activeComp) {
                                              updateCompCalculations(
                                                  fireBaseService,
                                                  currentComp,
                                                  boulder,
                                                  currentProfile,
                                                  flashed,
                                                  attempts);
                                            } else {
                                              showErrorDialog(context,
                                                  "Comp have beel closed");
                                            }
                                          }
                                          if (topped) {
                                            updateUserTopped(
                                                fireBaseService,
                                                currentProfile,
                                                boulder,
                                                flashed,
                                                topped,
                                                attempts,
                                                repeats);
                                          } else {
                                            flashed = false;

                                            updateUserUndoTop(fireBaseService,
                                                currentProfile, boulder);
                                          }
                                        });
                                      },
                                    ),
                                    const Spacer(),
                                    const Text("Flashed"),
                                    Checkbox(
                                      value: flashed,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          flashed = value ?? false;
                                          topped = value ?? false;
                                          attempts = 1;
                                          if (compView) {
                                            if (currentComp!.activeComp) {
                                              updateCompCalculations(
                                                  fireBaseService,
                                                  currentComp,
                                                  boulder,
                                                  currentProfile,
                                                  flashed,
                                                  attempts);
                                            } else {
                                              showErrorDialog(context,
                                                  "Comp have beel closed");
                                            }
                                          }
                                          if (flashed) {
                                            updateUserTopped(
                                                fireBaseService,
                                                currentProfile,
                                                boulder,
                                                flashed,
                                                topped,
                                                attempts,
                                                repeats);
                                          } else {
                                            updateUserRemovedFlashed(
                                                fireBaseService,
                                                currentProfile,
                                                boulder,
                                                flashed,
                                                topped,
                                                attempts,
                                                repeats);
                                          }
                                        });
                                      },
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  topped == true
                                      ? Column(
                                          children: [
                                            Text(
                                                "Topped in ${attempts == 0 ? '??' : attempts}"),
                                            Row(children: [
                                              const Text('Repeats:'),
                                              IconButton(
                                                icon: const Icon(
                                                    IconManager.decreaseNumber),
                                                onPressed: () {
                                                  setState(() {
                                                    repeats = (repeats - 1)
                                                        .clamp(
                                                            0, double.infinity)
                                                        .toInt();
                                                    fireBaseService.updateBoulder(
                                                        boulderID:
                                                            boulder.boulderID,
                                                        climberTopped:
                                                            updateClimberToppedMap(
                                                                currentProfile:
                                                                    currentProfile,
                                                                repeats:
                                                                    repeats,
                                                                existingData:
                                                                    boulder
                                                                        .climberTopped));
                                                    updateUserReapet(
                                                        fireBaseService,
                                                        currentProfile,
                                                        boulder,
                                                        repeats);
                                                  });
                                                },
                                              ),
                                              Text('$repeats'),
                                              IconButton(
                                                icon: const Icon(
                                                    IconManager.increaseNumber),
                                                onPressed: () {
                                                  setState(() {
                                                    repeats++;
                                                    fireBaseService.updateBoulder(
                                                        boulderID:
                                                            boulder.boulderID,
                                                        climberTopped:
                                                            updateClimberToppedMap(
                                                                currentProfile:
                                                                    currentProfile,
                                                                repeats:
                                                                    repeats,
                                                                existingData:
                                                                    boulder
                                                                        .climberTopped));
                                                    updateUserReapet(
                                                        fireBaseService,
                                                        currentProfile,
                                                        boulder,
                                                        repeats);
                                                  });
                                                },
                                              ),
                                            ])
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            const Text(""),
                                            Row(children: [
                                              const Text('Attempts:'),
                                              IconButton(
                                                icon: const Icon(
                                                    IconManager.decreaseNumber),
                                                onPressed: () {
                                                  setState(() {
                                                    attempts = (attempts - 1)
                                                        .clamp(
                                                            0, double.infinity)
                                                        .toInt();
                                                    fireBaseService.updateBoulder(
                                                        boulderID: boulder
                                                            .boulderID,
                                                        climberTopped:
                                                            updateClimberToppedMap(
                                                                currentProfile:
                                                                    currentProfile,
                                                                attempts:
                                                                    attempts,
                                                                existingData:
                                                                    boulder
                                                                        .climberTopped));
                                                  });
                                                },
                                              ),
                                              Text('$attempts'),
                                              IconButton(
                                                icon: const Icon(
                                                    IconManager.increaseNumber),
                                                onPressed: () {
                                                  setState(() {
                                                    attempts++;

                                                    fireBaseService.updateBoulder(
                                                        boulderID: boulder
                                                            .boulderID,
                                                        climberTopped:
                                                            updateClimberToppedMap(
                                                                currentProfile:
                                                                    currentProfile,
                                                                attempts:
                                                                    attempts,
                                                                existingData:
                                                                    boulder
                                                                        .climberTopped));
                                                    if (attempts > 1) {
                                                      flashed = false;
                                                    }
                                                  });
                                                },
                                              ),
                                            ])
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            // Edeting the boulder
                            Visibility(
                                visible: editing,
                                child: Column(
                                  children: [
                                    Row(children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Confirmation'),
                                                content: const Text(
                                                    'Are you sure you want to delete this boulder?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {                                                 
                                                      fireBaseService
                                                          .deleteBoulder(
                                                              boulderID: boulder
                                                                  .boulderID);
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            fireBaseService.updateBoulder(
                                                boulderID: boulder.boulderID,
                                                active: !active);
                                            active = !active;
                                          },
                                          child: Text(
                                              active ? "Inactive" : "Active"))
                                    ]),
                                    Row(
                                      children: [
                                        const Text("Updated?"),
                                        Checkbox(
                                          value: updatedBoulder,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              updatedBoulder = value ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Top out"),
                                        Checkbox(
                                          value: topOut,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              topOut = value ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Comp Boulder"),
                                        Checkbox(
                                          value: compBoulder,
                                          onChanged: (bool? value) {
                                            setState(() async {
                                              bool check = false;
                                              compBoulder = value ?? false;
                                              if (compBoulder) {
                                                check =
                                                    await showConfirmationDialog(
                                                        context,
                                                        "Add boulder to comp? ");
                                              }
                                              if (check) {
                                                if (currentComp != null) {
                                                  fireBaseService.updatComp(
                                                      compID:
                                                          currentComp.compID,
                                                      bouldersComp:
                                                          updateBoulderCompSet(
                                                        currentComp:
                                                            currentComp,
                                                        boulder: boulder,
                                                        existingData:
                                                            currentComp
                                                                .bouldersComp,
                                                      ));
                                                  fireBaseService.updateBoulder(
                                                    boulderID:
                                                        boulder.boulderID,
                                                    compBoulder: compBoulder,
                                                  );
                                                } else {
                                                  // ignore: use_build_context_synchronously
                                                  showErrorDialog(context,
                                                      "MISSING COMP!!! ");
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Hid Grade?"),
                                        Checkbox(
                                          value: hiddenGrade,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              hiddenGrade = value ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    DropdownButtonFormField<String>(
                                      value: selectedSetter,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedSetter =
                                              value ?? setters.first;
                                        });
                                      },
                                      items: setters.map((String setter) {
                                        return DropdownMenuItem(
                                          value: setter,
                                          child: Text(setter),
                                        );
                                      }).toList(),
                                      decoration: const InputDecoration(
                                          labelText: 'Choose Setter'),
                                    ),
                                    const SizedBox(height: 20),
                                    DropdownButtonFormField<String>(
                                      value: holdColorChoice,
                                      onChanged: (value) {
                                        setState(() {
                                          holdColorChoice = value!;
                                        });
                                      },
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('Select Hold Color'),
                                        ),
                                        ...currentSettings
                                            .settingsHoldColour!.entries
                                            .map((entry) {
                                          String holdColorName = entry.key;
                                          return DropdownMenuItem(
                                            value: holdColorName,
                                            child: Text(holdColorName),
                                          );
                                        }),
                                      ],
                                      decoration: const InputDecoration(
                                          labelText: 'Hold Color'),
                                    ),
                                  ],
                                )),
                            const SizedBox(width: 20),
                            // Grading set up:
                            gradingSystem == "coloured"
                                ? Column(
                                    children: [
                                      SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField<String>(
                                          value: gradeColorChoice,
                                          onChanged: (String? value) {
                                            setState(() {
                                              gradeColorChoice = value!;

                                              updateUsersVotedForGrade(
                                                  fireBaseService,
                                                  boulder,
                                                  currentProfile,
                                                  gradingSystem,
                                                  gradeValue,
                                                  difficultyLevel,
                                                  gradeColorChoice);
                                            });
                                          },
                                          items: [
                                            // Add an empty item at the beginning
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text('Select Grade Color'),
                                            ),
                                            // Map the entries from colorToGrade
                                            ...colorToGrade.entries
                                                .map((entry) {
                                              String colorName = entry.key;
                                              return DropdownMenuItem(
                                                value: colorName,
                                                child: Text(colorName),
                                              );
                                            }),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Grade Color',
                                          ),
                                        ),
                                      ),
                                      Slider(
                                        value: difficultyLevel.toDouble(),
                                        min: 1,
                                        max: 5,
                                        divisions: 4,
                                        label: arrowDict()[difficultyLevel]![
                                            'difficulty'],
                                        onChanged: (double value) {
                                          setState(() {
                                            difficultyLevel = value.toInt();
                                            updateUsersVotedForGrade(
                                                fireBaseService,
                                                boulder,
                                                currentProfile,
                                                gradingSystem,
                                                gradeValue,
                                                difficultyLevel,
                                                gradeColorChoice);
                                          });
                                        },
                                      ),
                                      const Text('Grade Colour Chart'),
                                      barGraphColours(boulder, currentSettings),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField<String>(
                                          value: selectedGrade!.isNotEmpty
                                              ? selectedGrade
                                              : null,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedGrade = value ?? '';
                                              gradeValue = getGradeValue(
                                                  gradingSystem,
                                                  selectedGrade!);
                                              allGradeColorChoice =
                                                  mapNumberToColors(
                                                      gradeValue!);

                                              gradeColorChoice =
                                                  allGradeColorChoice[0];

                                              gradeColors = allGradeColorChoice
                                                  .join(', ');
                                              updateUsersVotedForGrade(
                                                  fireBaseService,
                                                  boulder,
                                                  currentProfile,
                                                  gradingSystem,
                                                  gradeValue,
                                                  difficultyLevel,
                                                  gradeColorChoice);
                                            });
                                          },
                                          items: climbingGrades[gradingSystem]!
                                              .map<DropdownMenuItem<String>>(
                                                  (String grade) {
                                            return DropdownMenuItem(
                                              value: grade,
                                              child: Text(grade),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                              labelText: labelText),
                                        ),
                                      ),
                                      Text(
                                          "Grade: ${capitalizeFirstLetter(gradeColors)}"),
                                      if (allGradeColorChoice.length >
                                          1) // Show radio buttons if there is more than one color
                                        ...allGradeColorChoice.map(
                                            (color) => RadioListTile<String>(
                                                  title: Text(color),
                                                  value: color,
                                                  groupValue: gradeColorChoice,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      gradeColorChoice = value!;
                                                      updateUsersVotedForGrade(
                                                          fireBaseService,
                                                          boulder,
                                                          currentProfile,
                                                          gradingSystem,
                                                          gradeValue,
                                                          difficultyLevel,
                                                          gradeColorChoice);
                                                    });
                                                  },
                                                )),
                                      const SizedBox(height: 20),
                                      barChartGradeNumbering(gradingSystem,
                                          currentSettings, boulder),
                                    ],
                                  ),

                            const SizedBox(height: 30),
                            ExpansionPanelList(
                              elevation: 1,
                              expandedHeaderPadding: const EdgeInsets.all(0),
                              children: [
                                ExpansionPanel(
                                  headerBuilder: (context, isExpanded) {
                                    return ListTile(
                                      title: Text(
                                          "Challenges - ${challengesOverview.length - 1}"),
                                    );
                                  },
                                  body: Column(
                                    children:
                                        challengesOverview.map((challenge) {
                                      // Use the expanded state for each challenge
                                      bool isExpanded =
                                          expandedStates[challenge] ?? false;
                                      Map<String, dynamic>? challengeMap =
                                          boulder.boulderChallenges?[challenge];
                                      bool challengeCompleted;
                                      if (challengeMap == null) {
                                        challengeCompleted = false;
                                      } else {
                                        challengeCompleted =
                                            (challengeMap["completed"])
                                                .contains(
                                                    currentProfile.displayName);
                                      }

                                      return ExpansionPanelList(
                                        elevation: 1,
                                        expandedHeaderPadding:
                                            const EdgeInsets.all(0),
                                        children: [
                                          ExpansionPanel(
                                            headerBuilder:
                                                (context, isExpanded) {
                                              return ListTile(
                                                  title: challenge != "create"
                                                      ? Text(boulder
                                                              .boulderChallenges![
                                                          challenge]["name"])
                                                      : const Text(
                                                          "Add Challenge"),
                                                  tileColor: challengeCompleted
                                                      ? Colors.green
                                                      : Colors.amber);
                                            },
                                            body: Column(
                                              children: [
                                                challenge != "create"
                                                    ? Column(children: [
                                                        Visibility(
                                                            visible:
                                                                challengeMap![
                                                                    "gotCounter"],
                                                            child: Row(
                                                                children: [
                                                                  const Text(
                                                                      'Count:'),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .arrow_downward),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        challengeMap[
                                                                            "runningCount"] = (challengeMap["runningCount"] -
                                                                                1)
                                                                            .clamp(0,
                                                                                double.infinity)
                                                                            .toInt();
                                                                        fireBaseService.updateUser(
                                                                            currentProfile:
                                                                                currentProfile,
                                                                            challengePoints:
                                                                                updatePoints(points: -challengeMap["points"], existingData: currentProfile.challengePoints));
                                                                        fireBaseService.updateChallenge(
                                                                            challengeID:
                                                                                challenge,
                                                                            challengeCounter:
                                                                                challengeMap["runningCount"]);
                                                                      });
                                                                    },
                                                                  ),
                                                                  Text(
                                                                      '${challengeMap["runningCount"]}'),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .arrow_upward),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        if (challengeMap["runningCount"] <
                                                                            maxChallangeCounter) {
                                                                          challengeMap[
                                                                              "runningCount"]++;
                                                                          fireBaseService.updateChallenge(
                                                                              challengeID: challenge,
                                                                              challengeCounter: challengeMap["runningCount"]);
                                                                          fireBaseService.updateUser(
                                                                              currentProfile: currentProfile,
                                                                              challengePoints: updatePoints(
                                                                                points: challengeMap["points"],
                                                                                existingData: currentProfile.challengePoints,
                                                                              ));
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                ])),
                                                        Row(
                                                          children: [
                                                            Visibility(
                                                              visible:
                                                                  !challengeMap[
                                                                      "gotCounter"],
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  CloudChallenge?
                                                                      currentChallenge =
                                                                      await fireBaseService
                                                                          .getchallenge(
                                                                              challengeMap["name"]);
                                                                  if (challengeCompleted) {
                                                                    fireBaseService.updateBoulder(
                                                                        boulderID:
                                                                            boulder
                                                                                .boulderID,
                                                                        boulderChallenges: updateBoulderChallengeMap(
                                                                            currentChallenge:
                                                                                currentChallenge!,
                                                                            completed:
                                                                                true,
                                                                            removeUser:
                                                                                true,
                                                                            currentProfile:
                                                                                currentProfile));

                                                                    fireBaseService.updateUser(
                                                                        currentProfile:
                                                                            currentProfile,
                                                                        challengePoints: updatePoints(
                                                                            points:
                                                                                -challengeMap["points"],
                                                                            existingData: currentProfile.challengePoints));
                                                                  } else {
                                                                    fireBaseService.updateBoulder(
                                                                        boulderID:
                                                                            boulder
                                                                                .boulderID,
                                                                        boulderChallenges: updateBoulderChallengeMap(
                                                                            currentChallenge:
                                                                                currentChallenge!,
                                                                            removeUser:
                                                                                false,
                                                                            completed:
                                                                                true,
                                                                            currentProfile:
                                                                                currentProfile));
                                                                    fireBaseService.updateUser(
                                                                        currentProfile:
                                                                            currentProfile,
                                                                        challengePoints: updatePoints(
                                                                            points:
                                                                                challengeMap["points"],
                                                                            existingData: currentProfile.challengePoints));
                                                                    challengeCompleted =
                                                                        true;
                                                                  }
                                                                },
                                                                child: Text(
                                                                    challengeCompleted
                                                                        ? "Un-Done"
                                                                        : "Done"),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                showInformationPopup(
                                                                    context,
                                                                    challengeMap[
                                                                        "description"]);
                                                              },
                                                              child: const Text(
                                                                  "Info"),
                                                            ),
                                                          ],
                                                        ),
                                                      ])
                                                    : Row(
                                                        children: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Stream<
                                                                        Iterable<
                                                                            CloudChallenge>>
                                                                    challengeStream =
                                                                    fireBaseService
                                                                        .getAllChallenges();
                                                                showAddExisitingChallenge(context,
                                                                    challengeStream,
                                                                    fireBaseService:
                                                                        fireBaseService,
                                                                    boulder:
                                                                        boulder,
                                                                    currentProfile:
                                                                        currentProfile);
                                                              },
                                                              child: const Text(
                                                                  "Add exisit")),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                createChallengeDialog(
                                                                    context,
                                                                    setState,
                                                                    fireBaseService,
                                                                    boulder,
                                                                    currentProfile);
                                                              },
                                                              child: const Text(
                                                                  "Create")),
                                                        ],
                                                      )
                                              ],
                                            ),
                                            isExpanded: (challenge != "create")
                                                ? isExpanded
                                                : true,
                                          ),
                                        ],
                                        expansionCallback:
                                            (panelIndex, isExpanded) {
                                          setState(() {
                                            expandedStates[challenge] =
                                                isExpanded;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  isExpanded: expandPanelState,
                                ),
                              ],
                              expansionCallback: (panelIndex, isExpanded) {
                                setState(() {
                                  expandPanelState = !expandPanelState;
                                });
                              },
                            ),

                            const SizedBox(height: 20),
                            Row(children: [
                              climberTopList(toppersList),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Visibility(
                          visible: editing,
                          child: ElevatedButton(
                              onPressed: () {
                                if (holdColorChoice == null ||
                                    gradeColorChoice == null) {
                                  showErrorDialog(
                                      context, "Please select color and grade");
                                } else {
                                  if (gradingSystem == "coloured") {
                                    gradeValue = difficultyLevelToArrow(
                                        difficultyLevel, gradeColorChoice!);
                                  } else {
                                    gradeValue = null;
                                  }
                                  fireBaseService.updateBoulder(
                                      boulderID: boulder.boulderID,
                                      updateDateBoulder: updatedBoulder
                                          ? Timestamp.now()
                                          : null,
                                      topOut: topOut,
                                      hiddenGrade: hiddenGrade,
                                      setter: selectedSetter,
                                      holdColour: holdColorChoice,
                                      gradeColour: gradeColorChoice,
                                      gradeNumberSetter: gradeValue,
                                      compBoulder: compBoulder,
                                      climberTopped:
                                          updatedBoulder ? {} : null);
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text("Apply")))
                    ],
                  );
                },
              );
            }
          });
    },
  );
  return moveBoulder;
}

Map<String, dynamic>? updateUsersVotedForGrade(
    FirebaseCloudStorage boulderService,
    CloudBoulder boulder,
    CloudProfile currentProfile,
    String gradingSystem,
    int? gradeValue,
    int? difficultyLevel,
    String? gradeColorChoice) {
  if (gradingSystem == "coloured") {
    gradeValue = difficultyLevelToArrow(difficultyLevel!, gradeColorChoice!);
  } else {
    String arrow = getArrowFromNumberAndColor(gradeValue!, gradeColorChoice!);
    difficultyLevel = getdifficultyFromArrow(arrow);
  }
  boulder.climberTopped = updateClimberToppedMap(
    currentProfile: currentProfile,
    gradeNumberVoted: gradeValue,
    gradeColourVoted: gradeColorChoice,
    gradeArrowVoted: difficultyLevel,
    existingData: boulder.climberTopped,
  );
  boulderService.updateBoulder(
      boulderID: boulder.boulderID, climberTopped: boulder.climberTopped);
  return boulder.climberTopped;
}

void updateUserReapet(FirebaseCloudStorage userService,
    CloudProfile currentProfile, CloudBoulder boulder, int newRepeats) {
  int currentRepeats =
      boulder.climberTopped![currentProfile.userID]["newRepeats"];
  double orgBoulderPoints =
      boulder.climberTopped![currentProfile.userID]["boulderPoints"];
  double orgRepeatPoints =
      boulder.climberTopped![currentProfile.userID]["boulderPoints"] ?? 0;
  double repeatPoints;

  if (newRepeats > currentRepeats) {
    repeatPoints = calculateRepeatPoints(
        currentProfile, boulder, newRepeats, orgBoulderPoints);
  } else {
    repeatPoints = -calculateRepeatPoints(
        currentProfile, boulder, newRepeats, orgBoulderPoints);
  }

  double newRepeatPoints = orgRepeatPoints + repeatPoints;
  userService.updateUser(
      boulderPoints: updatePoints(
          points: newRepeatPoints, existingData: currentProfile.boulderPoints),
      currentProfile: currentProfile);
}

double calculateRepeatPoints(CloudProfile currentProfile, CloudBoulder boulder,
    int repeats, double orgBoulderPoints) {
  double repeatPoints = orgBoulderPoints *
      (repeats > 0 ? repeatsMultiplier - (repeats - 1) * repeatsDecrement : 0);
  if (repeatPoints > 0) {
    return repeatPoints;
  } else {
    return 0.0;
  }
}

int checkGrade(CloudProfile currentProfile, String boulderID, String style) {
  int maxValue = 0;
  DateTime currentDate = DateTime.now();
  String year = currentDate.year.toString();
  int comparedMonth = currentDate.month.toInt();
  // String currentMonth = comparedMonth.toString();
  int boulderGrade = 0;
  for (var month in currentProfile.dateBoulderTopped![year]!) {
    for (var week in currentProfile.dateBoulderTopped![year]![month]) {
      if (comparedMonth - month < 2) {
        for (var day in currentProfile.dateBoulderTopped![year]![month][week]) {
          for (var boulder in currentProfile.dateBoulderTopped![year]![month]
              [week][day]) {
            boulderGrade = currentProfile.dateBoulderTopped![year]![month][week]
                [day][boulder]["gradeSetter"];
            if (maxValue < boulderGrade) {
              maxValue = boulderGrade;
            }
          }
        }
      }
    }
  }
  return maxValue;
}

double calculateMultiplierFromGrade(
    int gradeNumber, int maxFlahsedGrade, int maxToppedGrade, bool flashed) {
  double baseMultiplier = 1.0;
  double newMultiplier;
  if (gradeNumber > maxFlahsedGrade && flashed) {
    newMultiplier = baseMultiplier + newFlashGradeMultiplier;
  }

  int gradeDiffer = gradeNumber - maxToppedGrade;

  if (gradeDiffer < 0) {
    newMultiplier = baseMultiplier + newToppedGradeMultiplier;
  } else if (gradeDiffer == 0) {
    newMultiplier = baseMultiplier;
  } else {
    newMultiplier = max(baseMultiplier - (decrementMultipler * gradeDiffer), 0);
  }

  return newMultiplier;
}

double calculateboulderPoints(CloudProfile currentProfile, CloudBoulder boulder,
    int repeats, bool flashed) {
  double boulderPoints = defaultBoulderPoints;
  int gradeNumber = boulder.gradeNumberSetter;
  int maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  int maxToppedGrade = currentProfile.maxToppedGrade;

  boulderPoints = boulderPoints *
      calculateMultiplierFromGrade(
        gradeNumber,
        maxFlahsedGrade,
        maxToppedGrade,
        flashed,
      );
  // Check if the user have points from this boulder
  if (boulder.climberTopped != null) {
    if (boulder.climberTopped!.containsKey((currentProfile.userID))) {
      if (boulder.climberTopped![currentProfile.userID]["topped"] != null)  {
        boulderPoints = boulderPoints *
            (repeats > 0
                ? repeatsMultiplier - (repeats - 1) * repeatsDecrement
                : 0);
      }
    }
  }
  return boulderPoints;
}

void updateUserRemovedFlashed(
    FirebaseCloudStorage firebaseService,
    CloudProfile currentProfile,
    CloudBoulder boulder,
    bool flashed,
    bool topped,
    int attempts,
    int repeats) {
  int maxFlahsedGrade;
  double pointsForTop;
  double pointsForFlash;
  double boulderPoints;
  if (boulder.gradeNumberSetter == currentProfile.maxFlahsedGrade) {
    maxFlahsedGrade = checkGrade(currentProfile, boulder.boulderID, "flashed");
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  pointsForFlash =
      -boulder.climberTopped![currentProfile.userID]["boulderPoints"];

  pointsForTop =
      calculateboulderPoints(currentProfile, boulder, repeats, flashed);

  boulderPoints = pointsForTop - pointsForFlash;

  firebaseService.updateBoulder(
    boulderID: boulder.boulderID,
    climberTopped: updateClimberToppedMap(
        currentProfile: currentProfile,
        attempts: attempts,
        repeats: repeats,
        flashed: flashed,
        topped: topped,
        existingData: boulder.climberTopped),
  );

  firebaseService.updateUser(
      boulderPoints: updatePoints(
          points: boulderPoints, existingData: currentProfile.boulderPoints),
      currentProfile: currentProfile,
      maxFlahsedGrade: maxFlahsedGrade,
      dateBoulderTopped: updateDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          flashed: flashed,
          boulderPoints: boulderPoints,
          maxFlahsedGrade: maxFlahsedGrade,
          existingData: currentProfile.dateBoulderTopped));
}

void updateUserUndoTop(
  FirebaseCloudStorage firebaseService,
  CloudProfile currentProfile,
  CloudBoulder boulder,
) {
  int maxFlahsedGrade;
  int maxToppedGrade;
  double orgBoulderPoints;
  if (boulder.gradeNumberSetter == currentProfile.maxFlahsedGrade) {
    maxFlahsedGrade = checkGrade(currentProfile, boulder.boulderID, "flashed");
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  if (boulder.gradeNumberSetter == currentProfile.maxToppedGrade) {
    maxToppedGrade = checkGrade(currentProfile, boulder.boulderID, "topped");
  } else {
    maxToppedGrade = currentProfile.maxToppedGrade;
  }
  if (boulder.climberTopped![currentProfile.userID] != null) {
    orgBoulderPoints = -(boulder.climberTopped![currentProfile.userID]
                ["boulderPoints"] ??
            0.0) -
        (boulder.climberTopped![currentProfile.userID]["repeatPoints"] ?? 0.0);
  } else {
    orgBoulderPoints = defaultBoulderPoints;
  }

  firebaseService.updateBoulder(
      boulderID: boulder.boulderID,
      climberTopped: updateClimberToppedMap(
          currentProfile: currentProfile,
          attempts: 0,
          flashed: false,
          topped: false,
          repeats: 0,
          boulderPoints: orgBoulderPoints,
          existingData: boulder.climberTopped));

  firebaseService.updateUser(
      currentProfile: currentProfile,
      boulderPoints: updatePoints(
          points: orgBoulderPoints, existingData: currentProfile.boulderPoints),
      maxFlahsedGrade: maxFlahsedGrade,
      maxToppedGrade: maxToppedGrade,
      dateBoulderTopped: removeDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          maxFlahsedGrade: maxFlahsedGrade,
          maxToppedGrade: maxToppedGrade,
          existingData: currentProfile.dateBoulderTopped));
}

void updateUserTopped(
    FirebaseCloudStorage firebaseService,
    CloudProfile currentProfile,
    CloudBoulder boulder,
    bool flashed,
    bool topped,
    int attempts,
    int repeats) {
  double boulderPoints;
  int maxFlahsedGrade;
  int maxToppedGrade;

  if (currentProfile.maxFlahsedGrade < boulder.gradeNumberSetter) {
    maxFlahsedGrade = boulder.gradeNumberSetter;
  } else {
    maxFlahsedGrade = currentProfile.maxFlahsedGrade;
  }
  if (currentProfile.maxToppedGrade < boulder.gradeNumberSetter) {
    maxToppedGrade = boulder.gradeNumberSetter;
  } else {
    maxToppedGrade = currentProfile.maxToppedGrade;
  }
  boulderPoints =
      calculateboulderPoints(currentProfile, boulder, repeats, flashed);

  firebaseService.updateBoulder(
      boulderID: boulder.boulderID,
      climberTopped: updateClimberToppedMap(
          currentProfile: currentProfile,
          attempts: attempts,
          repeats: repeats,
          flashed: flashed,
          topped: topped,
          toppedDate: DateTime.now(),
          boulderPoints: boulderPoints,
          existingData: boulder.climberTopped));

  firebaseService.updateUser(
      boulderPoints: updatePoints(
          points: boulderPoints, existingData: currentProfile.boulderPoints),
      currentProfile: currentProfile,
      maxFlahsedGrade: maxFlahsedGrade,
      maxToppedGrade: maxToppedGrade,
      dateBoulderTopped: updateDateBoulderToppedMap(
          boulder: boulder,
          userID: currentProfile.userID,
          flashed: flashed,
          boulderPoints: boulderPoints,
          maxFlahsedGrade: maxFlahsedGrade,
          maxToppedGrade: maxToppedGrade,
          existingData: currentProfile.dateBoulderTopped));
}

SizedBox climberTopList(List<Map<String, dynamic>> toppersList) {
  return SizedBox(
    width: 200,
    height: 200,
    child: ListView.builder(
      itemCount: toppersList.length,
      itemBuilder: (context, index) {
        // Access climber information from the map
        String name = toppersList[index]['name'];
        bool flashed = toppersList[index]['flashed'];

        return Card(
          child: ListTile(
              title: Text(name, overflow: TextOverflow.ellipsis),
              subtitle: Text(flashed ? "Flashed" : "Topped")),
        );
      },
    ),
  );
}

Container gradingInnerCirleDrawing(double circleWidth, double circleHeight,
    CloudBoulder boulder, CloudSettings currentSettings, String? gradingShow) {

  return Container(
    width: circleWidth * 0.8,
    height: circleHeight * 0.8,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: boulder.hiddenGrade == true
            ? hiddenGradeColor
            : nameToColor(
                currentSettings.settingsHoldColour![boulder.gradeColour])),
    child: Center(
      child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: OutlineText(
            Text(
              capitalize(gradingShow!),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: boulder.gradeColour != "black"
                    ? Colors.black
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: (gradingShow.length > 3 || gradingShow.contains('/'))
                    ? 10 // Font size for the text in the grading cirle. Changes size depending on text length
                    : 15,
              ),
            ),
            strokeWidth: 3,
            strokeColor: Colors.white54,
            overflow: TextOverflow.ellipsis,
          )),
    ),
  );
}

SizedBox barGraphColours(CloudBoulder boulder, CloudSettings currentSettings) {
  print("boulder -$boulder");
  return SizedBox(
    width: 250,
    height: 100,
    child: BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: getGradeColourChartData(boulder, currentSettings),
      ),
    ),
  );
}

SizedBox barChartGradeNumbering(
    String gradingSystem, CloudSettings currentSettings, CloudBoulder boulder) {
  return SizedBox(
    width: 250,
    height: 100,
    child: BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
            show: true,
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) =>
                    getBottomTitlesNumberGrade(value, meta, gradingSystem),
              ),
            )),
        barGroups:
            getGradeNumberChartData(boulder, currentSettings, gradingSystem),
      ),
    ),
  );
}
