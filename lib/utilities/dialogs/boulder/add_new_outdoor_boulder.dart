import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_outdoor_data.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

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
  List rating = [];
  int selectedRating = 0;
  int? difficultyLevel = 3;
  String selectedGrade = '';
  // const gradingSystem = "colour";
  // const gradingSystem = "french";
  // const gradingSystem = "v_grade";
  String? gradeColorChoice;

  String? gradeColors = "";
  var gradeValue = 0;
  List<String> allGradeColorChoice = [];

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
                                        color: nameToColor(currentSettings!
                                            .settingsGradeColour![colorName]),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(capitalize(colorName)),
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
                                  ? arrowDict()[difficultyLevel]!['difficulty']
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
                                    gradeColorChoice = allGradeColorChoice[0];
                                  }
                                  gradeColors = allGradeColorChoice.join(', ');
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                isSelected
                                    ? Colors.green
                                    : Colors.blue, // Change colors as needed
                              ),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Adjust radius as needed
                                ),
                              ),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.zero,
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
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
          );
        },
      );
    },
  );
}
