import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/other_const.dart';


void showRadomGetter(
  BuildContext context, {
  required List climbers,
}) {
  TextEditingController randomClimberController = TextEditingController();
  List<int> selectedIndices = [];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Random Picker"),
        content: Column(
          children: [
            TextFormField(
              controller: randomClimberController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Random Climber",
                suffixIcon: IconButton(
                  icon: const Icon(IconManager.getRandom),
                  onPressed: () {
                    if (climbers.isNotEmpty) {
                      Random random = Random();
                      int randomIndex;
                      do {
                        randomIndex = random.nextInt(climbers.length);
                      } while (selectedIndices.contains(randomIndex));

                      selectedIndices.add(randomIndex);

                      Map<String, dynamic> randomClimber =
                          climbers[randomIndex];

                      randomClimberController.text =
                          randomClimber['displayName'] ?? '';
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedIndices.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
