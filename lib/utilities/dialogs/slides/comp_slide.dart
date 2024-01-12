import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/colours_thems.dart';
import 'package:seven_x_c/services/cloude/cloud_storage_constants.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

Drawer compDrawer(
  BuildContext context,
  CloudComp currentComp,
  FirebaseCloudStorage compService,
) {
  bool signUp = currentComp.signUpActiveComp;
  int maxPP = currentComp.maxParticipants!;
  TextEditingController maxController =
      TextEditingController(text: currentComp.maxParticipants?.toString());
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(color: compAppBarColour),
          child: Text(
            'Comp Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          title: TextField(
            controller: TextEditingController(text: currentComp.compName),
            decoration: const InputDecoration(labelText: 'Comp Name'),
            onChanged: (value) {
              // Handle the changes in the comp name
              // You may want to update currentComp.name
            },
          ),
        ),
        ListTile(
          title: Row(
            children: [
              const Text('Sign Up Active'),
              Checkbox(
                value: signUp,
                onChanged: (value) {
                  signUp = !signUp;
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Max Participants'),
            onChanged: (value) {

              try {
                maxPP = int.parse(value);
              } catch (e) {
                
                maxPP = currentComp.maxParticipants!;
              }
            },
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () {
              compService.updatComp(
                  compID: currentComp.compID, signUpActiveComp: signUp);
            },
            child: const Text('Apply Changes'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () {
              compService.updatComp(
                  compID: currentComp.compID, startedComp: true);
            },
            child: const Text('Start Comp'),
          ),
        ),
        ListTile(
          title: ElevatedButton(
            onPressed: () {
              compService.updatComp(
                  compID: currentComp.compID,
                  startedComp: false,
                  signUpActiveComp: false,
                  activeComp: false,
                  endDateComp: Timestamp.now());
            },
            child: const Text('End Comp'),
          ),
        ),
        // Add more settings or actions as needed
      ],
    ),
  );
}
