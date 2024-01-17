import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/routes.dart';
import 'package:seven_x_c/helpters/functions.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/comp/gender_getter.dart';

void showComp(
  BuildContext context, {
  required CloudProfile? currentProfile,
  required FirebaseCloudStorage? compService,
  required bool compView,
  required Function(bool) setCompView,
  required Function(CloudComp) setComp,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder<Object>(
        stream: compService!.getActiveComps(),
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
                              onTap: () async {
                                if (currentComp.climbersComp!
                                    .containsKey(currentProfile.userID)) {
                                  setCompView(!compView);
                                  setComp(currentComp);
                                  Navigator.of(context).pop();
                                } else {
                                  if (currentComp.climbersComp!.length <
                                      (currentComp.maxParticipants as int)) {
                                    String gender =
                                        await showGetGender(context);
                                    compService.updatComp(
                                        compID: currentComp.compID,
                                        climbersComp: updateCompClimbers(
                                          currentComp: currentComp,
                                          currentProfile: currentProfile,
                                          gender: gender,
                                          existingData:
                                              currentComp.climbersComp,
                                        ));
                                    setCompView(!compView);
                                    setComp(currentComp);
                                    Navigator.of(context).pop();
                                  } else {
                                    showErrorDialog(
                                        context, "Comp signup is full");
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    activeComps[index],
                                    style: TextStyle(
                                        color: currentComp.startedComp
                                            ? Colors.black
                                            : currentComp.signUpActiveComp
                                                ? Colors.purple
                                                : Colors.red),
                                  ),
                                  if (currentProfile!.isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        setCompView(!compView);
                                        setComp(currentComp);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: currentProfile!.isSetter,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .popAndPushNamed(compCreatView);
                                  },
                                  child: const Text('Create Comp'),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle "Old Comps" button click
                              
                              Navigator.of(context).popAndPushNamed(compResultView);
                              // Add your custom logic here
                            },
                            child: const Text('Old Comps'),
                          ),
                        ],
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
