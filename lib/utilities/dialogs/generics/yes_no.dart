
import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';

Future<bool> showConfirmationDialog(BuildContext context, String placeHolderText) {
  return showGenericDialog(
    context: context,
    title: "Confirmation",
    content: placeHolderText,
    optionsBuilder: () => {
      "Cancel": false,
      "Yes": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
