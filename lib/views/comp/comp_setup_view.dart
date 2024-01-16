import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/boulder_const.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/utilities/dialogs/generics/info_popup.dart';

class CompCreationView extends StatefulWidget {
  const CompCreationView({Key? key}) : super(key: key);

  @override
  State<CompCreationView> createState() => _CompCreationViewState();
}

class _CompCreationViewState extends State<CompCreationView> {
  late final FirebaseCloudStorage _compService;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();



  // Selected values for dropdowns
  String selectedRule = 'Classic';
  String selectedStyle = 'Total Boulder Comp';

  bool includeFinals = false;
  bool includeSemiFinals = false;
  bool includeZones = false;

  @override
  void initState() {
    _compService = FirebaseCloudStorage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competition Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Comp Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Participants'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    showInformationPopup(context, "Set to 0, for unlimited");
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start Date and End Date Text Fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    decoration: const InputDecoration(labelText: 'End Date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                const Text('Finals'),
                const SizedBox(width: 16),
                Checkbox(
                  value: includeSemiFinals,
                  onChanged: (value) {
                    setState(() {
                      includeSemiFinals = value!;
                    });
                  },
                ),
                const Text('Semi-Finals'),
                const SizedBox(width: 16),
                Checkbox(
                  value: includeZones,
                  onChanged: (value) {
                    setState(() {
                      includeZones = value!;
                    });
                  },
                ),
                const Text('Zones'),
              ],
            ),

            const SizedBox(height: 16),
            // Dropdowns for Rules and Styles
            Row(
              children: [
                // Rules Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedRule,
                    onChanged: (newValue) {
                      setState(() {
                        selectedRule = newValue!;
                      });
                    },
                    items: compRulesOptions.map((rule) {
                      return DropdownMenuItem<String>(
                        value: rule,
                        child: Text(rule),
                      );
                    }).toList(),
                    hint: const Text('Select Rule'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    showInformationPopup(
                        context, "X-amount of boulder for X-amount of time");
                  },
                ),
                const SizedBox(width: 16),

                // Styles Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedStyle,
                    onChanged: (newValue) {
                      setState(() {
                        selectedStyle = newValue!;
                      });
                    },
                    items: compStylesOptions.map((style) {
                      return DropdownMenuItem<String>(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    hint: const Text('Select Style'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help),
                  onPressed: () {
                    showInformationPopup(context,
                        "1000 points per boulder, split amount ppl that tops");
                  },
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  _compService.createNewComp(
                    compName: _nameController.text,
                    compStyle: selectedStyle,
                    compRules: selectedRule,
                    startedComp: false,
                    activeComp: true,
                    signUpActiveComp: false,
                    startDateComp: Timestamp.fromDate(DateTime.parse(_startDateController.text)),
                    endDateComp: Timestamp.fromDate(DateTime.parse(_endDateController.text)),
                    maxParticipants: int.parse(_maxParticipantsController.text),
                    includeZones: includeZones,
                    includeFinals: includeFinals,
                    includeSemiFinals: includeSemiFinals,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Create Comp")),
                
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CompCreationView(),
  ));
}
