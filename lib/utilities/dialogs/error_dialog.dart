import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: "Error Error Error!!! ARG!!! So much Error is happening",
    content: text,
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}
