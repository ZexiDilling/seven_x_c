import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

showColorPickerDialog(BuildContext context) {
  TextEditingController nameController = TextEditingController();

  final List<ColorData> colorsFromFirebase = [
    
    ColorData(name: "Red", alpha: 255, red: 255, green: 0, blue: 0),
    ColorData(name: "Blue", alpha: 255, red: 0, green: 0, blue: 255),
    ColorData(name: "Green", alpha: 255, red: 0, green: 255, blue: 0),
    ColorData(name: "New", alpha: 255, red: 0, green: 0, blue: 0),
    // Add more colors as needed
  ];
  String selectedColorName = colorsFromFirebase.first.name;
  Color selectedColor = colorsFromFirebase.last.toColor();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Choose a Color"),
            content: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Color Name'),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text('Select a color from Firebase'),
                  value: selectedColorName,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedColorName = newValue!;
                      ColorData selectedColorData =
                          colorsFromFirebase.firstWhere((colorData) =>
                              colorData.name == selectedColorName);
                      selectedColor = selectedColorData.toColor();
                      nameController.text = selectedColorName;
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
                const SizedBox(height: 16),
                SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color;
                        nameController.text =
                            ''; 
                      });
                    },
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
              ],
            ),
            actions: [

              TextButton(
                onPressed: () {
                  // Here you can use the selectedColor and entered name for further actions
                  int alpha = selectedColor.alpha;
                  int red = selectedColor.red;
                  int green = selectedColor.green;
                  int blue = selectedColor.blue;
                  String colorName = nameController.text;

                  // Do something with the color values (ARGB) and name
                  print("Selected Color: A=$alpha, R=$red, G=$green, B=$blue");
                  print("Color Name: $colorName");

                  Navigator.of(context).pop();
                },
                child: const Text("Add"),
              ),
                            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Update"),
              ),
                            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
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
