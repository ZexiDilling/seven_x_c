import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_outdorr_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_outdoor_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

Future<void> addNewOutdoorClimb(
  BuildContext context,
  BoxConstraints constraints,
  CloudProfile currentProfile,
  double tempCenterX,
  double tempCenterY,
  String subLocation,
  String gradingSystem,
  FirebaseCloudStorage fireBaseService,
  CloudSettings? currentSettings,
  CloudOutdoorData? currentOutdoorData,
) async {
  List tags = [];
  int selectedRating = 0;
  int? difficultyLevel = 3;
  String selectedGrade = '';
  bool topOut = false;
  String boulderName = "";
  String? gradeColorChoice;

  String? gradeColors = "";
  var gradeValue = 0;
  List<String> allGradeColorChoice = [];

  //making sure that outdoor data is based on a grading sytem, and not colours
  if (gradingSystem == "coloured") {
    gradingSystem = "french";
  }

  TextEditingController boulderNameController = TextEditingController();

  showDialog(
    context: context, // Correct parameter name
    builder: (BuildContext context) {
      // Correct parameter name and type
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Builder setup"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Location - $subLocation"),
                  Text("Grading Style - $gradingSystem"),
                  TextField(
                    controller: boulderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Boulder Name',
                    ),
                    onChanged: (value) {
                      boulderName = value;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < selectedRating
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  Column(
                    children: [
                      // Dropdown for selecting grade based on the grading system
                      DropdownButtonFormField<String>(
                        value: selectedGrade.isNotEmpty ? selectedGrade : null,
                        onChanged: (String? value) {
                          setState(() {
                            selectedGrade = value ?? '';
                            gradeValue =
                                getGradeValue(gradingSystem, selectedGrade);
                            allGradeColorChoice = mapNumberToColors(gradeValue);
                            if (allGradeColorChoice.length == 1) {
                              gradeColorChoice = allGradeColorChoice[0];
                            }
                            gradeColors = allGradeColorChoice.join(', ');
                          });
                        },
                        items: climbingGrades[gradingSystem]!
                            .map<DropdownMenuItem<String>>((String grade) {
                          return DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                        decoration:
                            const InputDecoration(labelText: 'Select Grade'),
                      ),
                      Text("Grade: ${capitalizeFirstLetter(gradeColors!)}"),
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
                  CheckboxListTile(
                    title: const Text('Top Out'),
                    value: topOut,
                    onChanged: (bool? value) {
                      setState(() {
                        topOut = !topOut;
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
                      children: List.generate(climbTags().length, (index) {
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
                              backgroundColor: WidgetStateProperty.all<Color>(
                                isSelected
                                    ? Colors.green
                                    : Colors.blue, // Change colors as needed
                              ),
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust radius as needed
                                ),
                              ),
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.zero,
                              ),
                              minimumSize: WidgetStateProperty.all<Size>(
                                const Size(double.infinity, 40.0),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text(
                              tagName,
                              style: const TextStyle(
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
                  if (selectedGrade == "") {
                    showErrorDialog(context, "Please select grades");
                  }
                  if (difficultyLevel == null) {
                    var arrow = getArrowFromNumberAndColor(
                        gradeValue, gradeColorChoice!);
                    difficultyLevel = getdifficultyFromArrow(arrow);
                  }
                  CloudOutdoorBoulder? newOutdoorBoulder;
                  try {
                    newOutdoorBoulder =
                        await fireBaseService.createNewOutdoorBoulder(
                      outdoorCordX: tempCenterX / constraints.maxWidth,
                      outdoorCordY: tempCenterY / constraints.maxHeight,
                      outdoorBoulderDataNameID:
                          currentOutdoorData!.outdoorDataID,
                      outdoorBoulderSections: subLocation,
                      outdoorGradeColour: gradeColorChoice!,
                      outdoorGradeNumberSetter: gradeValue,
                      outdoorGradeDifficulty: difficultyLevel!,
                      outdoorTopOut: topOut,
                      outdoorActive: true,
                      outdoorTags: tags,
                      outdoorBoulderName: boulderName,
                      outdoorRating: selectedRating,
                    );
                  } catch (e) {
                    if (e
                        .toString()
                        .contains("type 'Null' is not a subtype of type")) {
                      // ignore: use_build_context_synchronously
                      showErrorDialog(context, "Data");
                    } else {
                      // ignore: use_build_context_synchronously
                      showErrorDialog(context, "$e");
                      newOutdoorBoulder = null;
                    }
                  }
                  if (newOutdoorBoulder != null) {
                    fireBaseService.updateOutdoorData(
                        outdoorDataID: currentOutdoorData!.outdoorDataID,
                        outdoorDataBoulders: updateOutdoorDataBoulders(
                            boulderId:
                                newOutdoorBoulder.outdoorBoulderDataNameID,
                            newOutdoorBoulder: newOutdoorBoulder,
                            existingData:
                                currentOutdoorData.outdoorDataBoulders));
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                // Missing adding setter to this one. is only needed if this rolls out more than just kjuge...
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
    },
  );
}
