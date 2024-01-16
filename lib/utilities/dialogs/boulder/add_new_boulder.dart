import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/generics/yes_no.dart';
// import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';

Future<void> showAddNewBoulder(
  BuildContext context,
  CloudProfile currentProfile,
  CloudComp? currentComp,
  bool compView,
  double centerX,
  double centerY,
  String wall,
  String gradingSystem,
  FirebaseCloudStorage boulderService,
  FirebaseCloudStorage userService,
  FirebaseCloudStorage compService,
  Stream<Iterable<CloudProfile>> settersStream,
) async {
  Color? holdColour;
  Color? gradeColor;
  bool setterTeam = false;
  bool guestSetterTeam = false;
  bool topOut = false;
  bool gotZone = false;
  bool hiddenGrade = compView;
  bool compBoulder = compView;
  String selectedGrade = '';

  int difficultyLevel = 1;
  // const gradingSystem = "colour";
  // const gradingSystem = "french";
  // const gradingSystem = "v_grade";
  String? gradeColorChoice = "";
  String? gradeColors = "";
  var gradeValue = 0;
  List<String> allGradeColorChoice = [];

  showDialog(
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

              String selectedSetter = setters.isNotEmpty ? setters.first : '';
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: const Text('Boulder Setup'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("Wall - $wall"),
                          Text("Grading Style - $gradingSystem"),
                          DropdownButtonFormField<Color>(
                            value: holdColour,
                            onChanged: (Color? value) {
                              setState(() {
                                holdColour = value;
                              });
                            },
                            items: holdColorMap.entries
                                .map((MapEntry<Color, String> entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            decoration:
                                const InputDecoration(labelText: 'Hold Color'),
                          ),
                          gradingSystem == "coloured"
                              ? Column(
                                  children: [
                                    DropdownButtonFormField<Color>(
                                      value: gradeColor,
                                      onChanged: (Color? value) {
                                        setState(() {
                                          gradeColor = value;
                                          gradeColorChoice =
                                              gradeColorMap[gradeColor];
                                        });
                                      },
                                      items: gradeColorMap.entries
                                          .map((MapEntry<Color, String> entry) {
                                        return DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value),
                                        );
                                      }).toList(),
                                      decoration: const InputDecoration(
                                          labelText: 'Grade Color'),
                                    ),
                                    Slider(
                                      value: difficultyLevel.toDouble(),
                                      min: 1,
                                      max: 5,
                                      divisions:
                                          4, // Number of divisions between min and max values
                                      label: arrowDict()[difficultyLevel]![
                                          'difficulty'],
                                      onChanged: (double value) {
                                        setState(() {
                                          difficultyLevel = value.toInt();
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    // Dropdown for selecting grade based on the grading system
                                    DropdownButtonFormField<String>(
                                      value: selectedGrade.isNotEmpty
                                          ? selectedGrade
                                          : null,
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedGrade = value ?? '';
                                          gradeValue = getGradeValue(
                                              gradingSystem, selectedGrade);
                                          allGradeColorChoice =
                                              mapNumberToColors(gradeValue);
                                          if (allGradeColorChoice.length == 1) {
                                            gradeColorChoice =
                                                allGradeColorChoice[0];
                                          }
                                          gradeColors =
                                              allGradeColorChoice.join(', ');
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
                                      decoration: const InputDecoration(
                                          labelText: 'Select Grade'),
                                    ),
                                    Text(
                                        "Grade: ${capitalizeFirstLetter(gradeColors!)}"),
                                    if (allGradeColorChoice.length >
                                        1) // Show radio buttons if there is more than one color
                                      ...allGradeColorChoice
                                          .map((color) => RadioListTile<String>(
                                                title: Text(color),
                                                value: color,
                                                groupValue: gradeColorChoice,
                                                onChanged: (value) {
                                                  setState(() {
                                                    gradeColorChoice = value;
                                                  });
                                                },
                                              ))
                                  ],
                                ),
                          DropdownButtonFormField<String>(
                            value: selectedSetter,
                            onChanged: (String? value) {
                              setState(() {
                                selectedSetter = value ?? setters.first;
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
                          Row(children: [
                            CheckboxListTile(
                                title: const Text(dtuSetterName),
                                value: setterTeam,
                                onChanged: (bool? value) {
                                  setState(() {
                                    setterTeam = value ?? false;
                                    guestSetterTeam = false;
                                  });
                                }),
                            CheckboxListTile(
                                title: const Text(guestSetter),
                                value: guestSetterTeam,
                                onChanged: (bool? value) {
                                  setState(() {
                                    guestSetterTeam = value ?? false;
                                    setterTeam = false;
                                  });
                                })
                          ]),
                          CheckboxListTile(
                              title: const Text('Top Out'),
                              value: topOut,
                              onChanged: (bool? value) {
                                setState(() {
                                  topOut = value ?? false;
                                });
                              }),
                          CheckboxListTile(
                            title: const Text('Comp'),
                            value: compBoulder,
                            onChanged: (bool? value) {
                              setState(() {
                                compBoulder = value ?? false;
                                hiddenGrade = compBoulder;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Hide Grade'),
                            value: hiddenGrade,
                            onChanged: (bool? value) {
                              setState(() {
                                hiddenGrade = value ?? false;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Add Chanllenges'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedGrade == "") {
                            gradeValue = difficultyLevelToArrow(
                                difficultyLevel, gradeColorChoice!);
                          }
                          if (compView && !compBoulder) {
                            // Show a confirmation dialog
                            bool confirmResult = await showConfirmationDialog(
                                context, "Is this boulder a compBoulder?");

                            if (confirmResult) {
                              // If user confirms, toggle the value of compBoulder
                              compBoulder = !compBoulder;
                            }
                          }

                          CloudBoulder? newBoulder;
                          try {
                            newBoulder = await boulderService.createNewBoulder(
                                setter: setterTeam == true
                                    ? dtuSetterName
                                    : (guestSetterTeam == true
                                        ? guestSetter
                                        : selectedSetter),
                                cordX: centerX,
                                cordY: centerY,
                                wall: wall,
                                holdColour: holdColorMap[holdColour]!,
                                gradeColour: gradeColorChoice!,
                                gradeNumberSetter: gradeValue,
                                topOut: topOut,
                                active: true,
                                hiddenGrade: hiddenGrade,
                                compBoulder: compBoulder,
                                gotZone: gotZone,
                                setDateBoulder: Timestamp.now());
                          } catch (e) {
                            if (e.toString().contains(
                                "type 'Null' is not a subtype of type 'String' of 'holdColour'")) {
                              // ignore: use_build_context_synchronously
                              showErrorDialog(context, "Missing Hold Colour");
                            } else {
                              // ignore: use_build_context_synchronously
                              showErrorDialog(context, "$e");
                              newBoulder = null;
                            }
                          }
                          if (currentComp != null && compView) {
                            if (newBoulder != null) {
                              // Check if newBoulder is not already in currentComp.bouldersComp
                              if (!currentComp.bouldersComp!
                                  .containsKey(newBoulder.boulderID)) {
                                compService.updatComp(
                                    compID: currentComp.compID,
                                    bouldersComp: updateBoulderCompSet(
                                        currentComp: currentComp,
                                        boulder: newBoulder,
                                        existingData:
                                            currentComp.bouldersComp));
                              }
                            } 
                          }

                          if (newBoulder != null) {
                            if (!setterTeam && !guestSetterTeam) {
                              try {
                                var setterProfiles = await userService
                                    .getUserFromDisplayName(selectedSetter)
                                    .first;
                                CloudProfile setterProfile =
                                    setterProfiles.first;

                                double setterPoints = calculateSetterPoints(
                                    setterProfile, newBoulder);
                                await userService.updateUser(
                                  currentProfile: setterProfile,
                                  setBoulders: updateBoulderSet(
                                    currentProfile: setterProfile,
                                    newBoulder: newBoulder,
                                    setterPoints: setterPoints,
                                    existingData: setterProfile.setBoulders,
                                  ),
                                  setterPoints: updatePoints(
                                      points: setterPoints,
                                      existingData: setterProfile.setterPoints),
                                );
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                showErrorDialog(context, "$e");
                              }
                            } else {
                              print("FUCK!");
                            }
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      });
}

double calculateSetterPoints(setterProfile, newBoulder) {
  // Calculate points based on the conditions
  double points = defaultSetterPoints;
  // Get the setBoulders map from the setterProfile
  Map<String, dynamic> setBoulders = setterProfile.setBoulders ?? {};

  // Bonus points for green and yellow
  if (newBoulder.gradeColour.toLowerCase() == 'green') {
    points += 3;
  } else if (newBoulder.gradeColour.toLowerCase() == 'yellow') {
    points += 2;
  }

  // If setBoulders is null or empty, return default points
  if (setBoulders.isEmpty) {
    return points + 5;
  }

  // Extracting colours from setBoulders
  List<String> gradeColour = [];
  for (var boulderData in setBoulders.values) {
    if (boulderData is Map<String, dynamic> &&
        boulderData['gradeColour'] is String) {
      gradeColour.add(boulderData['gradeColour']);
    }
  }

  // Count occurrences of each colour
  Map<String, int> colourOccurrences = {};
  for (String colour in gradeColour) {
    colourOccurrences[colour] = (colourOccurrences[colour] ?? 0) + 1;
  }

  // Sorting colours by occurrence in descending order
  List<String> mostCreatedColours = colourOccurrences.keys.toList()
    ..sort((a, b) => colourOccurrences[b]!.compareTo(colourOccurrences[a]!));

  // The least created colour is the last colour in the sorted list
  String leastCreatedColour =
      mostCreatedColours.isEmpty ? '' : mostCreatedColours.last;

  // Get the index of the newBoulder's gradeColour in the most created colours list
  int gradeColourIndex = mostCreatedColours.indexOf(newBoulder.gradeColour);

  if (gradeColourIndex == 0) {
    // Same as most created colour
    points -= 3;
  } else if (gradeColourIndex == 1) {
    // Second most created colour
    points -= 2;
  } else if (gradeColourIndex == 2) {
    // Third most created colour
    points -= 1;
  }

  // Bonus points for least created colour
  if (newBoulder.gradeColour == leastCreatedColour) {
    points += 2;
  }

  return points;
}
