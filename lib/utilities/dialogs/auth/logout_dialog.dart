import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Log Out",
    content: "Are you sure you wants to log out?",
    optionsBuilder: () => {
      "Cancel": false,
      "Log out": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
