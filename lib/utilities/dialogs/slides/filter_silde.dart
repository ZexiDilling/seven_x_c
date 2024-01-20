import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';


String? filterDropdownValue;
bool missingFilter = false;
bool newFilter = false;
bool updateFilter = false;
bool compFilter = false;
RangeValues gradeSliderRange = RangeValues(
    allGrading.keys.first.toDouble(), allGrading.keys.last.toDouble());

Drawer filterDrawer(
    BuildContext context, setState, CloudProfile currentProfile) {
  String gradingSystem = "";

  if (currentProfile.gradingSystem == "Coloured") {
    gradingSystem = "french";
  } else {
    gradingSystem = currentProfile.gradingSystem;
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
          children: _createColorRows(setState),
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
    title: const Text('Checkboxes'),
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

List<Widget> _createColorRows(setState) {
  List<Widget> colorRows = [];

  List<MapEntry<Color, String>> colorEntries =
      gradeColorMap.entries.toList(growable: false);

  const colorsPerRow = 4;

  for (int i = 0; i < colorEntries.length; i += colorsPerRow) {
    List<MapEntry<Color, String>> rowColors =
        colorEntries.skip(i).take(colorsPerRow).toList(growable: false);

    List<Widget> buttons = rowColors.map((entry) {
      Color color = entry.key;
      String label = entry.value;

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
                  color: isSelected ? getColorFromName(label) : Colors.black,
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

List<MapEntry<Color, String>> getVibrantColors() {
  // Increase saturation for vibrant colors
  List<MapEntry<Color, String>> vibrantColors = gradeColorMap.entries
      .map((entry) =>
          MapEntry(_adjustColorSaturation(entry.key, 1.5), entry.value))
      .toList(growable: false);

  return vibrantColors;
}

Color _adjustColorSaturation(Color color, double factor) {
  final double hslSaturation = color.computeLuminance();

  return HSLColor.fromColor(color)
      .withSaturation(hslSaturation * factor)
      .toColor();
}
