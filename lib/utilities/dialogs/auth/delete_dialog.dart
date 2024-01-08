import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';


Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete",
    content: "Are you sure you wants to delete this one?",
    optionsBuilder: () => {
      "Cancel": false,
      "Yes": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
