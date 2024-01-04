import 'package:flutter/material.dart';
import 'package:seven_x_c/helpters/charts.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/utilities/boulder_info.dart';
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
  Color? holdColor;
  Color? gradeColor;
  bool topOut = false;
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
                            value: holdColor,
                            onChanged: (Color? value) {
                              setState(() {
                                holdColor = value;
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
                              holdColour: holdColorMap[holdColor],
                              gradeColour: gradeColorChoice,
                              gradeNumberSetter: gradeValue,
                              topOut: topOut,
                              active: true,
                            );
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

Future<void> showBoulderInformation(BuildContext context, boulder, setState,
    currentProfile, boulderService, userService) async {
  int attempts = 0;
  bool flashed = false;
  bool topped = false;
  // const gradingSystem = "colour";
  // String gradingSystem = currentProfile.gradingSystem.toString().toLowerCase();
  // const gradingSystem = "v_grade";
  const gradingSystem = "french";
  String? gradingShow = "";
  bool editing = false;
  int difficultyLevel = 1;
  String? gradeColorChoice = "";
  String? gradeColors = "";
  String? selectedGrade = '';
  Color? gradeColor;
  int? gradeValue = 0;
  double boulderPoints = 0.0;
  List<String> allGradeColorChoice = [];
  bool voted = false;

  if (boulder.climberTopped != null &&
      boulder.climberTopped is Map<String, dynamic>) {
    if (boulder.climberTopped.containsKey(currentProfile.userID)) {
      var userClimbInfo = boulder.climberTopped[currentProfile.userID];
      attempts = userClimbInfo['attempts'] ?? 0;
      flashed = userClimbInfo['flashed'] ?? false;
      topped = userClimbInfo['topped'] ?? false;
      gradeValue = userClimbInfo["gradeNumber"] ?? 0;

      if (userClimbInfo["gradeColour"] != "" &&
          userClimbInfo["gradeColour"] != null) {
        voted = true;
      }
      gradeColor =
          getColorFromName(userClimbInfo["gradeColour"] ?? boulder.gradeColour);
      gradeColorChoice = gradeColorMap[gradeColor];
      selectedGrade = allGrading[gradeValue]![gradingSystem];
      // difficultyLevel = userClimbInfo["gradeArrowVoted"] ?? 0;
    }
  }

  if (gradingSystem == "coloured") {
    gradingShow = getArrowFromNumberAndColor(
        boulder.gradeNumberSetter, boulder.gradeColour);
  } else {
    gradingShow = allGrading[boulder.gradeNumberSetter]![gradingSystem];
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        getColorFromName(boulder.holdColour), // Outline color
                  ),
                  child: Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getColorFromName(capitalizeFirstLetter(
                            boulder.gradeColour)), // Inside color
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Text(
                            gradingShow!,
                            style: TextStyle(
                              color: Colors
                                  .white, // You can adjust the text color as needed
                              fontWeight: FontWeight.bold,
                              fontSize: (gradingShow.length > 3 ||
                                      gradingShow.contains('/'))
                                  ? 10 // Adjust the font size as needed
                                  : 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("Setter - ${boulder.setter}"),
                if (currentProfile.isAdmin || currentProfile.isSetter)
                  IconButton(
                    icon: Icon(editing ? Icons.edit : Icons.done),
                    onPressed: () {
                      setState(() {
                        editing = !editing;
                      });
                    },
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text("Flashed"),
                    Checkbox(
                      value: flashed,
                      onChanged: (bool? value) {
                        setState(() {
                          flashed = value ?? false;
                          topped = value ?? false;
                          attempts = 1;
                        });
                      },
                    ),
                  ]),
                  Row(children: [
                    const Text("Topped"),
                    Checkbox(
                      value: topped,
                      onChanged: (bool? value) {
                        setState(() {
                          topped = value ?? false;
                          if (attempts == 0) {
                            attempts = 1;
                            flashed = true;
                          } else if (attempts == 1) {
                            flashed = true;
                          }
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Text('Attempts:'),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        setState(() {
                          attempts =
                              (attempts - 1).clamp(0, double.infinity).toInt();
                        });
                      },
                    ),
                    Text('$attempts'),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        setState(() {
                          attempts++;
                          if (attempts > 1) {
                            flashed = false;
                          }
                        });
                      },
                    ),
                  ]),
                  const SizedBox(width: 20),
                  // Grading set up:
                  gradingSystem == "coloured"
                      ? Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: DropdownButtonFormField<Color>(
                                value: gradeColor,
                                onChanged: (Color? value) {
                                  setState(() {
                                    gradeColor = value;
                                    gradeColorChoice =
                                        gradeColorMap[gradeColor];
                                    voted = true;
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
                            ),
                            Slider(
                              value: difficultyLevel.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label:
                                  arrowDict()[difficultyLevel]!['difficulty'],
                              onChanged: (double value) {
                                setState(() {
                                  difficultyLevel = value.toInt();
                                });
                              },
                            ),
                            const Text('Grade Colour Chart'),
                            SizedBox(
                              width: 250,
                              height: 150,
                              child: BarChart(
                                BarChartData(
                                  groupsSpace: 12,
                                  borderData: FlBorderData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  barGroups: getGradeColourChartData(boulder),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: 200,
                              child: DropdownButtonFormField<String>(
                                value: selectedGrade!.isNotEmpty
                                    ? selectedGrade
                                    : null,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedGrade = value ?? '';
                                    gradeValue = getGradeValue(
                                        gradingSystem, selectedGrade!);
                                    allGradeColorChoice =
                                        mapNumberToColors(gradeValue!);
                                    if (allGradeColorChoice.length == 1) {
                                      gradeColorChoice = allGradeColorChoice[0];
                                    }
                                    gradeColors =
                                        allGradeColorChoice.join(', ');
                                  });
                                  voted = true;
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
                                      )),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 250,
                              height: 100,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  groupsSpace: 12,
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                      show: true,
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) =>
                                              getBottomTitlesNumberGrade(value, meta, gradingSystem),
                                        ),
                                      )),
                                  barGroups: getGradeNumberChartData(
                                      boulder, gradingSystem),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (voted) {
                        if (gradingSystem == "coloured") {
                          gradeValue = difficultyLevelToArrow(
                              difficultyLevel, gradeColorChoice!);
                        }
                      } else {
                        gradeValue = null;
                      }
                      boulderService.updatBoulder(
                        boulderID: boulder?.boulderID,
                        climberTopped: updateClimberToppedMap(
                            currentProfile: currentProfile,
                            attempts: attempts,
                            flashed: flashed,
                            topped: topped,
                            existingData: boulder?.climberTopped,
                            gradeNumberVoted: gradeValue,
                            gradeColourVoted: gradeColorChoice,
                            gradeArrowVoted: difficultyLevel),
                      );
                      if (topped == true) {
                        userService.updateUser(
                            boulderPoints: boulderPoints,
                            currentProfile: currentProfile,
                            climbedBoulders: updateClimbedBouldersMap(
                                boulder: boulder,
                                attempts: attempts,
                                flashed: flashed,
                                gradeColour: gradeColorChoice,
                                gradeArrow: difficultyLevel,
                                boulderPoints: boulderPoints,
                                existingData: currentProfile.climbedBoulders));
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Cancelled button pressed
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelled'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Info button pressed
                      // You can add logic to display additional information
                      // For example, show a Snackbar or navigate to another screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Additional information here!'),
                        ),
                      );
                    },
                    child: const Text('Info'),
                  ),
                ],
              )
            ],
          );
        },
      );
    },
  );
}
