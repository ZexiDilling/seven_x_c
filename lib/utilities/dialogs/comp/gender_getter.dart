
import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';

Future<String> showGetGender(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Gender",
    content: "What formate are your competing in?",
    optionsBuilder: () => {
      "Male": "Male",
      "Femal": "Female",
      "None": "None"
    },
  ).then(
    (value) => value ?? "None",
  );
}
