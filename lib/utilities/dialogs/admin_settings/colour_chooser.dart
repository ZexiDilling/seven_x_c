import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:seven_x_c/constants/boulder_info.dart' show allGrading;
import 'package:seven_x_c/helpters/functions.dart'
    show
        tryParseInt,
        updateSettingsGradeColours,
        updateSettingsHoldColours,
        deletSubSettings;
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

showColorPickerDialog(
    BuildContext context,
    FirebaseCloudStorage fireBaseService,
    CloudProfile currentProfile,
    CloudSettings currentSettings,
    String? colourType) {
  TextEditingController nameController = TextEditingController();

  Map<String, dynamic>? colourDict;

  switch (colourType) {
    case "holds":
      colourDict = currentSettings.settingsHoldColour;
      break;
    case "grades":
      colourDict = currentSettings.settingsGradeColour;
      break;
  }

  final List<ColorData> colorsFromFirebase = colourDict?.entries.map((entry) {
        String colorName = entry.key;
        Map<String, dynamic> colorValues = entry.value;

        return ColorData(
          name: colorName,
          alpha: colorValues["alpha"] ?? 10,
          red: colorValues["red"] ?? 0,
          green: colorValues["green"] ?? 0,
          blue: colorValues["blue"] ?? 0,
        );
      }).toList() ??
      [];

  colorsFromFirebase
      .add(ColorData(name: "New", alpha: 10, red: 0, green: 0, blue: 0));

  String selectedColorName = colorsFromFirebase.last.name;
  Color selectedColor = colorsFromFirebase.last.toColor();
  String selectedMinGrade = "0";
  String selectedMaxGrade = "15";
  String currentGradingSystem;
  if (currentProfile.gradingSystem == "coloured")
    {currentGradingSystem = "french";}
  else
  {currentGradingSystem = currentProfile.gradingSystem;}

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Choose a Color"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Color Name"),
                  ),
                  DropdownButton<String>(
                    hint: const Text("Database Colours"),
                    value: selectedColorName,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedColorName = newValue!;
                        ColorData selectedColorData =
                            colorsFromFirebase.firstWhere((colorData) =>
                                colorData.name == selectedColorName);
                        selectedColor = selectedColorData.toColor();
                        nameController.text = selectedColorName;
                        if (colourType == "grades") {
                          selectedMinGrade =
                              colourDict![selectedColorName]["min"].toString();
                          selectedMaxGrade =
                              colourDict[selectedColorName]["max"].toString();
                        }
                      });
                    },
                    items: colorsFromFirebase
                        .map<DropdownMenuItem<String>>((ColorData colorData) {
                      return DropdownMenuItem<String>(
                        value: colorData.name,
                        child: Text(colorData.name),
                      );
                    }).toList(),
                  ),
                  Visibility(
                    visible: colourType == "grades",
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              hint: const Text("Select Min Grade"),
                              value: selectedMinGrade,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedMinGrade = newValue!;
                                });
                              },
                              isExpanded: true,
                              items: buildDropdownItems(currentGradingSystem),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        SizedBox(
                          width: 100,
                          child: DropdownButton<String>(
                            hint: const Text("Select Max Grade"),
                            value: selectedMaxGrade,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMaxGrade = newValue!;
                              });
                            },
                            isExpanded: true,
                            items: buildDropdownItems(currentGradingSystem),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      int alpha = selectedColor.a as int;
                      int red = selectedColor.r as int;
                      int green = selectedColor.g as int;
                      int blue = selectedColor.b as int;
                      String colourName = nameController.text;

                      int? minGradeInt = tryParseInt(selectedMinGrade);
                      int? maxGradeInt = tryParseInt(selectedMaxGrade);
                      switch (colourType) {
                        case "holds":
                          fireBaseService.updateSettings(
                            settingsID: currentSettings.settingsID,
                            settingsHoldColour: updateSettingsHoldColours(
                                colourName: colourName,
                                alpha: alpha,
                                red: red,
                                green: green,
                                blue: blue,
                                existingData:
                                    currentSettings.settingsHoldColour),
                          );
                          break;

                        case "grades":
                          if (minGradeInt != null && maxGradeInt != null) {
                            if (maxGradeInt < minGradeInt) {
                              showErrorDialog(context,
                                  "Min grades needs to be lower than max grade");
                            } else {
                              fireBaseService.updateSettings(
                                settingsID: currentSettings.settingsID,
                                settingsGradeColour: updateSettingsGradeColours(
                                    colourName: colourName,
                                    alpha: alpha,
                                    red: red,
                                    green: green,
                                    blue: blue,
                                    minGrade: minGradeInt,
                                    maxGrade: maxGradeInt,
                                    existingData:
                                        currentSettings.settingsGradeColour),
                              );
                            }
                          }
                          break;

                        default:
                      }

                      Navigator.of(context).pop();
                    },
                    child: const Text("Add"),
                  ),
                  TextButton(
                    onPressed: () {
                      int alpha = selectedColor.a as int;
                      int red = selectedColor.r as int;
                      int green = selectedColor.g as int;
                      int blue = selectedColor.b as int;
                      String colourName = nameController.text;

                      int? minGradeInt = tryParseInt(selectedMinGrade);
                      int? maxGradeInt = tryParseInt(selectedMaxGrade);
                      switch (colourType) {
                        case "holds":
                          fireBaseService.updateSettings(
                            settingsID: currentSettings.settingsID,
                            settingsHoldColour: updateSettingsHoldColours(
                                colourName: colourName,
                                alpha: alpha,
                                red: red,
                                green: green,
                                blue: blue,
                                oldColourName: selectedColorName,
                                existingData:
                                    currentSettings.settingsHoldColour),
                          );
                          break;

                        case "grades":
                          if (minGradeInt != null && maxGradeInt != null) {
                            if (maxGradeInt < minGradeInt) {
                              showErrorDialog(context,
                                  "Min grades needs to be lower than max grade");
                            } else {
                              fireBaseService.updateSettings(
                                settingsID: currentSettings.settingsID,
                                settingsGradeColour: updateSettingsGradeColours(
                                  colourName: colourName,
                                  alpha: alpha,
                                  red: red,
                                  green: green,
                                  blue: blue,
                                  minGrade: minGradeInt,
                                  maxGrade: maxGradeInt,
                                  oldColourName: selectedColorName,
                                  existingData:
                                      currentSettings.settingsGradeColour,
                                ),
                              );
                            }
                          }
                          break;

                        default:
                      }

                      Navigator.of(context).pop();
                    },
                    child: const Text("Update"),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      switch (colourType) {
                        case "holds":
                          fireBaseService.updateSettings(
                              settingsID: currentSettings.settingsID,
                              settingsGradeColour: deletSubSettings(
                                  oldColourName: selectedColorName,
                                  existingData:
                                      currentSettings.settingsHoldColour));
                          break;

                        case "grades":
                          fireBaseService.updateSettings(
                              settingsID: currentSettings.settingsID,
                              settingsGradeColour: deletSubSettings(
                                  oldColourName: selectedColorName,
                                  existingData:
                                      currentSettings.settingsGradeColour));

                          break;

                        default:
                      }

                      Navigator.of(context).pop();
                    },
                    child: const Text("Delete"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

class ColorData {
  final String name;
  final int alpha;
  final int red;
  final int green;
  final int blue;

  ColorData({
    required this.name,
    required this.alpha,
    required this.red,
    required this.green,
    required this.blue,
  });

  Color toColor() {
    return Color.fromARGB(alpha, red, green, blue);
  }
}

List<DropdownMenuItem<String>> buildDropdownItems(String gradingSystem) {
  return allGrading.entries.map((entry) {
    int index = entry.key;
    Map<String, String> grades = entry.value;
    String selectedGrade =
        gradingSystem == "french" ? grades["french"]! : grades["v_grade"]!;
    String label = selectedGrade;
    String uniqueValue = index.toString();
    return DropdownMenuItem<String>(
      value: uniqueValue,
      child: Text(label),
    );
  }).toList();
}
