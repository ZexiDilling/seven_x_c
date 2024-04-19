import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/gym_data/cloud_gym_data.dart';
import 'package:seven_x_c/services/cloude/gym_data/cloud_settings.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/generics/yes_no.dart';

Future<void> showAddNewBoulder(
    BuildContext context,
    BoxConstraints constraints,
    CloudProfile currentProfile,
    CloudComp? currentComp,
    bool compView,
    double centerX,
    double centerY,
    String wall,
    String gradingSystem,
    Map<String, Map<String, int>> colorToGrade,
    FirebaseCloudStorage fireBaseService,
    CloudSettings currentSettings,
    CloudGymData currentGymData,
    Stream<Iterable<CloudProfile>> settersStream) async {
  bool gymSetterTeam = false;
  bool guestSetterTeam = false;
  bool topOut = false;
  bool gotZone = false;
  bool hiddenGrade = compView;
  bool compBoulder = compView;
  String selectedGrade = '';
  double setterPoints = 0.0;
  List tags = [];
  bool knownSetter = false;

  int? difficultyLevel = 3;
  // const gradingSystem = "colour";
  // const gradingSystem = "french";
  // const gradingSystem = "v_grade";
  String? gradeColorChoice;
  String? holdColorChoice;
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
              setters.addAll([gymSetterName, guestSetterName]);
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
                                child: Text('Select Hold Colour'),
                              ),
                              ...currentSettings.settingsHoldColour!.entries
                                  .map((entry) {
                                String holdColorName = entry.key;
                                return DropdownMenuItem(
                                  value: holdColorName,
                                  child: Container(
                                    color: nameToColor(currentSettings
                                        .settingsHoldColour![holdColorName]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text(capitalize(holdColorName)),
                                    ),
                                  ),
                                );
                              }),
                            ],
                            decoration:
                                const InputDecoration(labelText: 'Hold Color'),
                          ),
                          gradingSystem == "coloured"
                              ? Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: gradeColorChoice,
                                      onChanged: (String? value) {
                                        setState(() {
                                          gradeColorChoice = value;
                                        });
                                      },
                                      items: [
                                        // Add an empty item at the beginning
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('Select Grade Color'),
                                        ),
                                        // Map the entries from colorToGrade
                                        ...colorToGrade.entries.map((entry) {
                                          String colorName = entry.key;
                                          return DropdownMenuItem(
                                            value: colorName,
                                            child: Container(
                                                color: nameToColor(currentSettings
                                                        .settingsGradeColour![
                                                    colorName]),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: Text(
                                                      capitalize(colorName)),
                                                )),
                                          );
                                        }),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Grade Color',
                                      ),
                                    ),
                                    Slider(
                                      value: difficultyLevel != null
                                          ? difficultyLevel!.toDouble()
                                          : 3.0,
                                      min: 1,
                                      max: 5,
                                      divisions:
                                          4, // Number of divisions between min and max values
                                      label: difficultyLevel != null
                                          ? arrowDict()[difficultyLevel]![
                                              'difficulty']
                                          : arrowDict()[3]!['difficulty'],
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
                                                    gradeColorChoice = value!;
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
                          SizedBox(
                            height: 500,
                            width: 1000,
                            child: GridView.count(
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 5,
                              crossAxisCount: 3,
                              childAspectRatio: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children:
                                  List.generate(climbTags().length, (index) {
                                String tagName = climbTags()[index];
                                bool isSelected = tags.contains(tagName);
                                return ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isSelected) {
                                        tags.remove(tagName);
                                      } else {
                                        tags.add(tagName);
                                      }
                                    });
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        isSelected
                                            ? Colors.green
                                            : Colors
                                                .blue, // Change colors as needed
                                      ),
                                      shape: MaterialStateProperty.all<
                                          OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust radius as needed
                                        ),
                                      ),
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        EdgeInsets.zero,
                                      ),
                                      minimumSize:
                                          MaterialStateProperty.all<Size>(
                                        Size(double.infinity, 40.0),
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text(
                                      tagName,
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black),
                                      // Adjust font size as needed
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (holdColorChoice == null ||
                              gradeColorChoice == null) {
                            showErrorDialog(
                                context, "Please select Colours/grades");
                          } else {
                            if (selectedGrade == "") {
                              gradeValue = difficultyLevelToArrow(
                                  difficultyLevel!, gradeColorChoice!);
                            }
                            if (difficultyLevel == null) {
                              var arrow = getArrowFromNumberAndColor(
                                  gradeValue, gradeColorChoice!);
                              difficultyLevel = getdifficultyFromArrow(arrow);
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
                              var setterProfiles = await fireBaseService
                                  .getUserFromDisplayName(selectedSetter)
                                  .first;
                              if (setterProfiles.isNotEmpty) {
                                knownSetter = true;
                                CloudProfile setterProfile =
                                    setterProfiles.first;
                                setterPoints = calculateSetterPoints(
                                    setterProfile, gradeColorChoice!);
                              }

                              newBoulder =
                                  await fireBaseService.createNewBoulder(
                                      setter: gymSetterTeam == true
                                          ? gymSetterName
                                          : (guestSetterTeam == true
                                              ? guestSetterName
                                              : selectedSetter),
                                      cordX: centerX / constraints.maxWidth,
                                      cordY: centerY / constraints.maxHeight,
                                      wall: wall,
                                      holdColour: holdColorChoice!,
                                      gradeColour: gradeColorChoice!,
                                      gradeNumberSetter: gradeValue,
                                      gradeDifficulty: difficultyLevel!,
                                      topOut: topOut,
                                      active: true,
                                      hiddenGrade: hiddenGrade,
                                      compBoulder: compBoulder,
                                      gotZone: gotZone,
                                      tags: tags,
                                      setterPoint: setterPoints,
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
                                if (currentComp.bouldersComp == null) {
                                  fireBaseService.updatComp(
                                      compID: currentComp.compID,
                                      bouldersComp: updateBoulderCompSet(
                                          currentComp: currentComp,
                                          boulder: newBoulder));
                                } else {
                                  if (!currentComp.bouldersComp!
                                      .containsKey(newBoulder.boulderID)) {
                                    fireBaseService.updatComp(
                                        compID: currentComp.compID,
                                        bouldersComp: updateBoulderCompSet(
                                            currentComp: currentComp,
                                            boulder: newBoulder,
                                            existingData:
                                                currentComp.bouldersComp));
                                  }
                                }
                              }
                            }

                            if (newBoulder != null) {
                              if (knownSetter) {
                                var setterProfiles = await fireBaseService
                                    .getUserFromDisplayName(selectedSetter)
                                    .first;
                                try {
                                  CloudProfile setterProfile =
                                      setterProfiles.first;
                                  await fireBaseService.updateUser(
                                    currentProfile: setterProfile,
                                    dateBoulderSet: updateDateBoulderSet(
                                      setterProfile: setterProfile,
                                      boulderId: newBoulder.boulderID,
                                      newBoulder: newBoulder,
                                      setterPoints: setterPoints,
                                      existingData:
                                          setterProfile.dateBoulderSet,
                                    ),
                                    setterPoints: updatePoints(
                                        points: setterPoints,
                                        existingData:
                                            setterProfile.setterPoints),
                                  );
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  showErrorDialog(context, "$e");
                                }
                              }
                              try {
                                String setterID = "";

                                Iterable<CloudProfile> setterProfiles =
                                    await fireBaseService
                                        .getUserFromDisplayName(selectedSetter)
                                        .first;

                                if (setterProfiles.isNotEmpty) {
                                  CloudProfile setterProfile =
                                      setterProfiles.first;
                                  setterID = setterProfile.userID;
                                } else {
                                  setterID = selectedSetter;
                                }

                                await fireBaseService.updateGymData(
                                    gymDataID: currentGymData.gymDataID,
                                    gymDataBoulders: updateGymDataBoulders(
                                        setterID: setterID,
                                        newBoulder: newBoulder,
                                        existingData:
                                            currentGymData.gymDataBoulders));
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                showErrorDialog(context, "$e");
                              }
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

double calculateSetterPoints(
    CloudProfile setterProfile, String boulderGradeColour) {
  // Calculate points based on the conditions
  double points = defaultSetterPoints;
  // Get the setBoulders map from the setterProfile
  Map<String, dynamic> setBoulders = setterProfile.setBoulders ?? {};
  String currentGradeColour = boulderGradeColour;
  // Bonus points for green and yellow
  if (currentGradeColour.toLowerCase() == 'green') {
    points += 3;
  } else if (currentGradeColour.toLowerCase() == 'yellow') {
    points += 2;
  }

  // If setBoulders is null or empty, return default points
  if (setBoulders.isEmpty) {
    return points + 5;
  }

  // Extracting colours from setBoulders
  List<String> gradeColours = [];
  for (var boulderData in setBoulders.values) {
    if (boulderData is Map<String, dynamic> &&
        boulderData['gradeColour'] is String) {
      gradeColours.add(boulderData['gradeColour']);
    }
  }

  // Count occurrences of each colour
  Map<String, int> colourOccurrences = {};
  for (String colour in gradeColours) {
    colourOccurrences[colour] = (colourOccurrences[colour] ?? 0) + 1;
  }

  // Sorting colours by occurrence in descending order
  List<String> mostCreatedColours = colourOccurrences.keys.toList()
    ..sort((a, b) => colourOccurrences[b]!.compareTo(colourOccurrences[a]!));

  // The least created colour is the last colour in the sorted list
  String leastCreatedColour =
      mostCreatedColours.isEmpty ? '' : mostCreatedColours.last;

  // Get the index of the newBoulder's gradeColour in the most created colours list
  int gradeColourIndex = mostCreatedColours.indexOf(currentGradeColour);

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
  if (currentGradeColour == leastCreatedColour) {
    points += 2;
  }

  return points;
}
