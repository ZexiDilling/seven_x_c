
import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/auth/generic_dialog.dart';

Future<bool> showInformationPopup(BuildContext context, String placeHolderText) {
  return showGenericDialog(
    context: context,
    title: "Information",
    content: placeHolderText,
    optionsBuilder: () => {
      "Ok": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
