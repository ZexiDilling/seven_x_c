import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';

void showComp(BuildContext context,
    {required CloudProfile? currentProfile,
    required FirebaseCloudStorage? compService,
    required bool compView,
    required Function(bool) setCompView,
    required Function(String) setCompName}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder<Object>(
        stream: compService!.getComp(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var compData = snapshot.data as Iterable<CloudComp>;

            String title = compData.any((comp) => comp.activeComp)
                ? 'Active Comps:'
                : 'No active comps';
            List<String> activeComps = [];

            // Iterate over individual CloudComp objects
            for (CloudComp comp in compData) {
              if (comp.activeComp) {
                activeComps.add(comp.compName);
              }
            }

            return AlertDialog(
              content: Text(title),
              actions: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: ListView.builder(
                          itemCount: activeComps.length,
                          itemBuilder: (BuildContext context, int index) {
                            final currentComp = compData.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                setCompView(!compView);
                                setCompName(activeComps[index]);
                                Navigator.of(context).pop();

                                // if (currentComp.climbersComp!
                                //     .containsKey(currentProfile!.userID)) {
                                // } else {
                                //   if (currentComp.climbersComp!.length <
                                //       (currentComp.maxParticipants as int)) {
                                //     showErrorDialog(context, "Comp signup");
                                //   } else {
                                //     showErrorDialog(
                                //         context, "Comp signup is full");
                                //   }
                                // }

                                // Handle item click here
                                print('Item clicked: ${activeComps[index]}');
                              },
                              child: Text(activeComps[index]),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle "Sign Up" button click
                              Navigator.of(context).pop();
                              // Add your custom logic here
                            },
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: currentProfile!.isSetter,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle "Create Comp" button click
                                Navigator.of(context).pop();
                                // Add your custom logic here
                              },
                              child: const Text('Create Comp'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Handle "Change Comp" button click
                                Navigator.of(context).pop();
                                // Add your custom logic here
                              },
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            // Handle error case if there's an issue with the stream
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          } else {
            // Display a loading indicator while waiting for stream data
            return const AlertDialog(
              title: Text('Loading'),
              content: CircularProgressIndicator(),
            );
          }
        },
      );
    },
  );
}
