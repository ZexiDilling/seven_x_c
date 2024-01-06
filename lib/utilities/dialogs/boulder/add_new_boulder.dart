import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
// import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';
import 'package:seven_x_c/utilities/dialogs/error_dialog.dart';

Future<void> showAddNewBoulder(
    BuildContext context,
    boulderService,
    userService,
    double centerX,
    double centerY,
    String wall,
    gradingSystem,
    Stream<Iterable<CloudProfile>> settersStream) async {
  Color? holdColour;
  Color? gradeColor;
  bool topOut = false;
  bool compBoulder = false;
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
                                          // If the grade color changes, reset the selected grade
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
                          CheckboxListTile(
                            title: const Text('Top Out'),
                            value: topOut,
                            onChanged: (bool? value) {
                              setState(() {
                                topOut = value ?? false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Comp'),
                            value: compBoulder,
                            onChanged: (bool? value) {
                              setState(() {
                                compBoulder = value ?? false;
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

                          try {
                            await boulderService.createNewBoulder(
                                setter: selectedSetter,
                                cordX: centerX,
                                cordY: centerY,
                                wall: wall,
                                holdColour: holdColorMap[holdColour],
                                gradeColour: gradeColorChoice,
                                gradeNumberSetter: gradeValue,
                                topOut: topOut,
                                active: true,
                                compBoulder: compBoulder,
                                setDateBoulder: Timestamp.now());
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (e.toString().contains(
                                "type 'Null' is not a subtype of type 'String' of 'holdColour'")) {
                              // ignore: use_build_context_synchronously
                              showErrorDialog(context, "Missing Hold Colour");
                            } else {
                              // ignore: use_build_context_synchronously
                              showErrorDialog(context, "$e");
                            }
                          }
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
