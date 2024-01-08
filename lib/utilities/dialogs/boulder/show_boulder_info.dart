import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/charts/charts.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:seven_x_c/utilities/info_data/boulder_info.dart';

Future<void> showBoulderInformation(
    BuildContext context,
    CloudBoulder boulder,
    setState,
    CloudProfile currentProfile,
    FirebaseCloudStorage boulderService,
    FirebaseCloudStorage userService,
    Stream<Iterable<CloudProfile>> settersStream) async {
  int attempts = 0;
  bool flashed = false;
  bool topped = false;
  // const gradingSystem = "coloured";
  // const gradingSystem = "v_grade";
  // const gradingSystem = "french";
  String gradingSystem = currentProfile.gradingSystem.toString().toLowerCase();
  String? gradingShow = "";
  bool editing = false;
  int difficultyLevel = 1;
  String? gradeColorChoice = "";
  String? gradeColors = "";
  String? selectedGrade = '';
  Color? gradeColour;
  int? gradeValue = 0;
  Color? holdColour = getColorFromName(boulder.holdColour);
  double boulderPoints = 0.0;
  List<String> allGradeColorChoice = [];
  bool voted = false;
  String labelText = "Vote a Grade";

  bool active = boulder.active;
  bool updated = false;
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
              await userService.getUser(userID: userId.toString()).first;
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
      flashed = userClimbInfo['flashed'] ?? false;
      topped = userClimbInfo['topped'] ?? false;
      gradeValue = userClimbInfo["gradeNumber"] ?? 0;

      if (userClimbInfo["gradeColour"] != "" &&
          userClimbInfo["gradeColour"] != null) {
        voted = true;
      }
      gradeColour = getColorFromName(userClimbInfo["gradeColour"] ??
          boulder.gradeColour);
      print("gradeColor - $gradeColour");
      gradeColorChoice = gradeColorMap[gradeColour];
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
                            color: getColorFromName(
                                boulder.holdColour), // Outline color
                          ),
                          child: Center(
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: boulder.hiddenGrade == true
                                    ? hiddenGradeColor
                                    : getColorFromName(capitalizeFirstLetter(
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
                              labelText =
                                  editing ? "Vote a Grade" : "Choose a Grade";
                              gradeColour =
                                  getColorFromName(boulder.gradeColour);
                              gradeColorChoice = gradeColorMap[gradeColour];
                              gradeValue = boulder.gradeNumberSetter;
                              difficultyLevel = getdifficultyFromArrow(
                                  getArrowFromNumberAndColor(
                                      gradeValue!, boulder.gradeColour));
                              setState(() {
                                editing = !editing;
                              });
                            },
                          ),
                      ],
                    ),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: !editing,
                              child: Column(
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
                                          attempts = (attempts - 1)
                                              .clamp(0, double.infinity)
                                              .toInt();
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
                                ],
                              ),
                            ),
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
                                                      boulderService
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
                                            boulderService.updatBoulder(
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
                                          value: updated,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              updated = value ?? false;
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
                                            setState(() {
                                              compBoulder = value ?? false;
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
                                        child: DropdownButtonFormField<Color>(
                                          value: gradeColour,
                                          onChanged: (Color? value) {
                                            setState(() {
                                              gradeColour = value;
                                              gradeColorChoice =
                                                  gradeColorMap[gradeColour];
                                              voted = true;
                                            });
                                          },
                                          items: gradeColorMap.entries.map(
                                              (MapEntry<Color, String> entry) {
                                            return DropdownMenuItem(
                                              value: entry.key,
                                              child: Text(entry.value),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                              labelText: labelText),
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
                                          });
                                        },
                                      ),
                                      const Text('Grade Colour Chart'),
                                      SizedBox(
                                        width: 250,
                                        height: 150,
                                        child: BarChart(
                                          BarChartData(
                                            gridData:
                                                const FlGridData(show: false),
                                            groupsSpace: 12,
                                            borderData:
                                                FlBorderData(show: false),
                                            titlesData:
                                                const FlTitlesData(show: false),
                                            barGroups: getGradeColourChartData(
                                                boulder),
                                          ),
                                        ),
                                      ),
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
                                              if (allGradeColorChoice.length ==
                                                  1) {
                                                gradeColorChoice =
                                                    allGradeColorChoice[0];
                                              }
                                              gradeColors = allGradeColorChoice
                                                  .join(', ');
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
                                          decoration: InputDecoration(
                                              labelText: labelText),
                                        ),
                                      ),
                                      Text(
                                          "Grade: ${capitalizeFirstLetter(gradeColors!)}"),
                                      if (allGradeColorChoice.length >
                                          1) // Show radio buttons if there is more than one color
                                        ...allGradeColorChoice.map(
                                            (color) => RadioListTile<String>(
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
                                        height: 200,
                                        child: BarChart(
                                          BarChartData(
                                            gridData:
                                                const FlGridData(show: false),
                                            groupsSpace: 12,
                                            borderData:
                                                FlBorderData(show: false),
                                            titlesData: FlTitlesData(
                                                show: true,
                                                topTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                leftTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                rightTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (double
                                                                value,
                                                            TitleMeta meta) =>
                                                        getBottomTitlesNumberGrade(
                                                            value,
                                                            meta,
                                                            gradingSystem),
                                                  ),
                                                )),
                                            barGroups: getGradeNumberChartData(
                                                boulder, gradingSystem),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            Row(children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: ListView.builder(
                                  itemCount: toppersList.length,
                                  itemBuilder: (context, index) {
                                    // Access climber information from the map
                                    String name = toppersList[index]['name'];
                                    bool flashed =
                                        toppersList[index]['flashed'];

                                    return Card(
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(name),
                                            const SizedBox(width: 10),
                                            Text(flashed ? "F" : "T"),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Row(
                        children: [
                          Visibility(
                            visible: !editing,
                            child: ElevatedButton(
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
                                  boulderID: boulder.boulderID,
                                  climberTopped: updateClimberToppedMap(
                                      currentProfile: currentProfile,
                                      attempts: attempts,
                                      flashed: flashed,
                                      topped: topped,
                                      existingData: boulder.climberTopped,
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
                                          topped: topped,
                                          attempts: attempts,
                                          flashed: flashed,
                                          gradeColour: gradeColorChoice,
                                          gradeArrow: difficultyLevel,
                                          boulderPoints: boulderPoints,
                                          existingData:
                                              currentProfile.climbedBoulders));
                                }
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ),
                          Visibility(
                              visible: editing,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (gradingSystem == "coloured") {
                                      gradeValue = difficultyLevelToArrow(
                                          difficultyLevel, gradeColorChoice!);
                                    } else {
                                      gradeValue = null;
                                    }
                                    boulderService.updatBoulder(
                                      boulderID: boulder.boulderID,
                                      updateDateBoulder: Timestamp.now(),
                                      topOut: topOut,
                                      hiddenGrade: hiddenGrade,
                                      setter: selectedSetter,
                                      holdColour: holdColorMap[holdColour],
                                      gradeColour: gradeColorChoice,
                                      gradeNumberSetter: gradeValue,
                                      compBoulder: compBoulder,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Apply"))),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Info button pressed
                              // You can add logic to display additional information
                              // For example, show a Snackbar or navigate to another screen
                            },
                            child: const Text('Info'),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            }
          });
    },
  );
}
