import 'package:flutter/material.dart';
import 'package:seven_x_c/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: "Sharing",
      content: "You can't share an empty note!",
      optionsBuilder: () => {"Ok": null});
}
