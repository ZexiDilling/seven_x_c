import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/services/cloude/location_data/cloud_settings.dart';


String? filterDropdownValue;
bool missingFilter = false;
bool newFilter = false;
bool updateFilter = false;
bool compFilter = false;
List<String> tagFilter = [];
RangeValues gradeSliderRange = RangeValues(
    allGrading.keys.first.toDouble(), allGrading.keys.last.toDouble());

Drawer filterDrawer(BuildContext context, setState, CloudProfile currentProfile,
    CloudSettings currentSettings) {
  String gradingSystem = "";

  if (currentProfile.gradingSystem == "Coloured") {
    gradingSystem = "french";
  } else {
    gradingSystem = currentProfile.gradingSystem.toLowerCase();
  }

  String mapLabelToValue(double label) {
    int currentValue = label.round();

    String startGrade = allGrading[currentValue]![gradingSystem] ?? '';

    return startGrade;
  }

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        PreferredSize(
          preferredSize:
              const Size.fromHeight(80.0), // Set your preferred height
          child: AppBar(
            title: const Text('Filter'),
          ),
        ),
        gradeFilterSlider(setState, mapLabelToValue),
        Column(
          children: _createColorRows(setState, currentSettings),
        ),
        specFilterCheck(setState),
        ListTile(
          title: const Text('Clear Filters'),
          onTap: () {
            setState(() {
              filterDropdownValue = null;
              gradeSliderRange = RangeValues(
                allGrading.keys.first.toDouble(),
                allGrading.keys.last.toDouble(),
              );
              selectedColors.clear();
              missingFilter = false;
              newFilter = false;
              updateFilter = false;
              compFilter = false;
              tagFilter = [];
            });
            // Navigator.pop(context); // Close the Drawer
          },
        ),
      ],
    ),
  );
}

ListTile specFilterCheck(setState) {
  return ListTile(
    subtitle: Column(
      children: [
        CheckboxListTile(
          title: const Text("Missing"),
          value: missingFilter,
          onChanged: (value) {
            setState(() {
              missingFilter = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('New'),
          value: newFilter,
          onChanged: (value) {
            setState(() {
              newFilter = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Updated'),
          value: updateFilter,
          onChanged: (value) {
            setState(() {
              updateFilter = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Comp'),
          value: compFilter,
          onChanged: (value) {
            setState(() {
              compFilter = value!;
            });
          },
        ),
        SizedBox(
          height: 250,
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
              bool isSelected = tagFilter.contains(tagName);
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      tagFilter.remove(tagName);
                    } else {
                      tagFilter.add(tagName);
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
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.zero,
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(double.infinity, 40.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    tagName,
                    style: const TextStyle(fontSize: 10.0, color: Colors.black),
                    // Adjust font size as needed
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

RangeSlider gradeFilterSlider(
    setState, String Function(double label) mapLabelToValue) {
  return RangeSlider(
    values: gradeSliderRange,
    onChanged: (RangeValues newValues) {
      setState(() {
        gradeSliderRange = newValues;
      });
    },
    min: allGrading.keys.first.toDouble(),
    max: allGrading.keys.last.toDouble(),
    divisions: allGrading.keys.length - 1,
    labels: RangeLabels(
      mapLabelToValue(gradeSliderRange.start),
      mapLabelToValue(gradeSliderRange.end),
    ),
  );
}

Set<String> selectedColors = {};

List<Widget> _createColorRows(setState, CloudSettings currentSettings) {
  List<Widget> colorRows = [];

  Map<String, dynamic>? settingsGradeColour =
      currentSettings.settingsGradeColour;

  if (settingsGradeColour == null || settingsGradeColour.isEmpty) {
    // Handle the case where settingsGradeColour is null or empty
    return colorRows;
  }

  List<MapEntry<String, dynamic>> colorEntries =
      settingsGradeColour.entries.toList(growable: false);

  // Sort the color entries based on the "min" value
  colorEntries.sort((a, b) => a.value['min'].compareTo(b.value['min']));

  const colorsPerRow = 4;

  for (int i = 0; i < colorEntries.length; i += colorsPerRow) {
    List<MapEntry<String, dynamic>> rowColors =
        colorEntries.skip(i).take(colorsPerRow).toList(growable: false);

    List<Widget> buttons = rowColors.map((entry) {
      Color color =
          nameToColor(currentSettings.settingsGradeColour![entry.key]);
      String label = entry.key;

      bool isSelected = selectedColors.contains(label.toLowerCase());

      return InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedColors.remove(label.toLowerCase());
            } else {
              selectedColors.add(label.toLowerCase());
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : color.withOpacity(0.5),
              border: Border.all(
                color: Colors.white,
                width: 0.0,
              ),
            ),
            child: Center(
              child: Text(
                "",
                style: TextStyle(
                  color: isSelected
                      ? nameToColor(currentSettings.settingsGradeColour![label])
                      : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    colorRows.add(Row(children: buttons));
  }

  return colorRows;
}
