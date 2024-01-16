import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/services/cloude/comp/cloud_comp.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

bool showAllBouldersFilter = false;

Drawer compDrawer(
  BuildContext context,
  setState,
  CloudComp currentComp,
  FirebaseCloudStorage compService,
) {
  String selectedRule = currentComp.compRules;
String selectedStyle = currentComp.compStyle;
bool includeFinals = currentComp.includeFinals;
bool includeSemiFinals = currentComp.includeSemiFinals;
  bool signUp = currentComp.signUpActiveComp;
  int maxPP = currentComp.maxParticipants!;
  TextEditingController maxController =
      TextEditingController(text: currentComp.maxParticipants?.toString());
  return Drawer(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: 5000,
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: AppBar(
                title: const Text('Comp Settings'),
              ),
            ),
            ListTile(
              title: TextField(
                controller: TextEditingController(text: currentComp.compName),
                decoration: const InputDecoration(labelText: 'Comp Name'),
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  const Text('Show All Boulders'),
                  Checkbox(
                    value: showAllBouldersFilter,
                    onChanged: (value) {
                      setState(() {
                        showAllBouldersFilter = !showAllBouldersFilter;
                      });
                    },
                  ),
                ],
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
                decoration:
                    const InputDecoration(labelText: 'Max Participants'),
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
              title: DropdownButton<String>(
                value: selectedRule,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRule = newValue!;
                  });
                },
                items: compRulesOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            ListTile(
              title: DropdownButton<String>(
                value: selectedStyle,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStyle = newValue!;
                  });
                },
                items: compStylesOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: includeFinals,
                  onChanged: (value) {
                    setState(() {
                      includeFinals = value!;
                    });
                  },
                ),
                const Text('Finals?'),
                Checkbox(
                  value: includeSemiFinals,
                  onChanged: (value) {
                    setState(() {
                      includeSemiFinals = value!;
                    });
                  },
                ),
                const Text('Semi Finals?'),
              ],
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  compService.updatComp(
                      compID: currentComp.compID,
                      signUpActiveComp: signUp,
                      maxParticipants: maxPP);
                },
                child: const Text('Apply Changes'),
              ),
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    compService.updatComp(
                        compID: currentComp.compID, startedComp: true);
                  },
                  child: const Text('Start Comp'),
                ),
                ElevatedButton(
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
              ],
            )
          ],
        ),
      ),
    ),
  );
}
