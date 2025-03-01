// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_info.dart';
import 'package:seven_x_c/services/cloude/boulder/cloud_boulder.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

Future<void> stripping(
    context,
    setState,
    Stream<Iterable<CloudBoulder>> filteredBouldersStream,
    FirebaseCloudStorage firebaseService,
    wallRegionMap) async {
  List<bool> sectionCheckboxes =
      List.generate(wallSections.length, (index) => false);
  List.generate(3, (index) => false);
  bool hiddenBoulders = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            title: const Text("Section Stripping"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Access the data from the StreamBuilder
                          Iterable<CloudBoulder>? boulders =
                              await filteredBouldersStream.first;

                          for (CloudBoulder boulder in boulders) {
                            if (boulder.hiddenGrade == false) {
                              await firebaseService.updateBoulder(
                                  boulderID: boulder.boulderID,
                                  hiddenGrade: true);
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text("Hide Grade"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Access the data from the StreamBuilder
                          Iterable<CloudBoulder>? boulders =
                              await filteredBouldersStream.first;

                          for (CloudBoulder boulder in boulders) {
                            if (boulder.hiddenGrade == true) {
                              await firebaseService.updateBoulder(
                                  boulderID: boulder.boulderID,
                                  hiddenGrade: false);
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text("Show Grade"),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      hiddenBoulders = !hiddenBoulders;
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (hiddenBoulders) {
                          // Change the color when hiddenBoulders is true
                          return Colors
                              .green; // Change this color to the one you prefer
                        }
                        return Colors
                            .red; // Default color when hiddenBoulders is false
                      }),
                    ),
                    child: const Text("Select Hidden Boulders"),
                  ),

                  // Section checkboxes
                  for (int counter = 0; counter < 3; counter++)
                    Row(
                      children: [
                        Checkbox(
                          value: sectionCheckboxes[counter],
                          onChanged: (value) {
                            setState(() {
                              sectionCheckboxes[counter] = value!;
                              // Set all walls in the section to the same status
                              for (WallRegion wall in wallRegions) {
                                if (wall.section == counter + 1) {
                                  wallRegionMap[wall.wallID]!.isSelected =
                                      value;
                                }
                              }
                            });
                          },
                        ),
                        Text('Section ${counter + 1}'),
                      ],
                    ),
                  const Divider(
                    color: Colors.black, // Set the color of the divider
                    height: 20, // Set the height of the divider
                    thickness: 2, // Set the thickness of the divider
                  ),
                  // Wall checkboxes
                  Column(
                    children: [
                      for (int i = 0; i < wallRegions.length; i += 2)
                        Row(
                          children: [
                            for (int j = i;
                                j < i + 2 && j < wallRegions.length;
                                j++)
                              Row(
                                children: [
                                  Checkbox(
                                    value: wallRegionMap[wallRegions[j].wallID]!
                                        .isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        wallRegionMap[wallRegions[j].wallID]!
                                            .isSelected = value!;
                                      });
                                    },
                                  ),
                                  Text(wallRegions[j].wallName),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deactivation'),
                            content: const Text(
                                'Are you sure you want to deactivate boulders in selected section?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Access the data from the StreamBuilder
                                  Stream<Iterable<CloudBoulder>>
                                      allBouldersStream =
                                      firebaseService.getAllBoulders(true);
                                  Iterable<CloudBoulder>? boulders =
                                      await allBouldersStream.first;
                                  for (CloudBoulder boulder in boulders) {
                                    if (wallRegionMap[
                                            (boulder.wall).toLowerCase()]!
                                        .isSelected) {
                                      // Deletes old boulders from the database
                                      if (!boulder.active) {
                                        await firebaseService.deleteBoulder(
                                            boulderID: boulder.boulderID);
                                      } else {
                                        await firebaseService.updateBoulder(
                                          boulderID: boulder.boulderID,
                                          active: false,
                                        );
                                      }
                                    }
                                  }
                                  for (WallRegion wall in wallRegions) {
                                    wallRegionMap[wall.wallID]!.isSelected =
                                        false;
                                  }
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Strip'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                                'Are you sure you want to deleted boulders in selected sections?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Iterable<CloudBoulder>? boulders;

                                  // Access the data from the StreamBuilder
                                  if (hiddenBoulders) {
                                    boulders = await firebaseService
                                        .getAllBoulders(true)
                                        .first;
                                  } else {
                                    boulders =
                                        await filteredBouldersStream.first;
                                  }
                                  // Ensure boulders is not null before proceeding
                                  for (CloudBoulder boulder in boulders) {
                                    if (wallRegionMap[
                                            boulder.wall.toLowerCase()]!
                                        .isSelected) {
                                      await firebaseService.deleteBoulder(
                                        boulderID: boulder.boulderID,
                                      );
                                    }
                                  }
                                
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Kill"),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
