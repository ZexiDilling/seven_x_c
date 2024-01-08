import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Resetting of the Password",
    content:
        "You really forgot your password? and then you ask me for it? really? is this what the world have come too, asking the robot to do the robot things...",
    optionsBuilder: () => {
      "OK": null
    });
}
