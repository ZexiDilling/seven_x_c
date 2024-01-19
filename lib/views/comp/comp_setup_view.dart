import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/comp_const.dart';
import 'package:seven_x_c/constants/other_const.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/utilities/dialogs/auth/error_dialog.dart';
import 'package:seven_x_c/utilities/dialogs/generics/info_popup.dart';

class CompCreationView extends StatefulWidget {
  const CompCreationView({super.key});

  @override
  State<CompCreationView> createState() => _CompCreationViewState();
}

class _CompCreationViewState extends State<CompCreationView> {
  late final FirebaseCloudStorage _compService;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController();

  // Selected values for dropdowns
  String selectedRule = 'Classic';
  String selectedStyle = 'totalBoulder';
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

  bool includeFinals = false;
  bool includeSemiFinals = false;
  bool includeZones = false;
  bool genderBased = false;

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
      body: SingleChildScrollView(
        child: Padding(
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
                    icon: const Icon(IconManager.info),
                    onPressed: () {
                      showInformationPopup(context, "Set to 0, for unlimited");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              buildDatePickerRow(
                context: context,
                selectedDate: selectedStartDate,
                onDateSelected: (pickedDate) {
                  setState(() {
                    selectedStartDate = pickedDate;
                  });
                },
                hintText: 'Start Date',
              ),
              buildDatePickerRow(
                context: context,
                selectedDate: selectedEndDate,
                onDateSelected: (pickedDate) {
                  setState(() {
                    selectedEndDate = pickedDate;
                  });
                },
                hintText: 'End Date',
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
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: includeZones,
                    onChanged: (value) {
                      setState(() {
                        includeZones = value!;
                      });
                    },
                  ),
                  const Text('Zones'),
                  Checkbox(
                    value: genderBased,
                    onChanged: (value) {
                      setState(() {
                        genderBased = value!;
                      });
                    },
                  ),
                  const Text('Gender Based?'),
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
                    icon: const Icon(IconManager.info),
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
                    icon: const Icon(IconManager.info),
                    onPressed: () {
                      showInformationPopup(context,
                          "1000 points per boulder, split amount ppl that tops");
                    },
                  ),
                ],
              ),

              ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.length < 5) {
                      showErrorDialog(context, "Needs a longer name");
                    } else {
                      _compService.createNewComp(
                        compName: _nameController.text,
                        compStyle: selectedStyle,
                        compRules: selectedRule,
                        startedComp: false,
                        activeComp: true,
                        signUpActiveComp: false,
                        startDateComp: Timestamp.fromDate(selectedStartDate),
                        endDateComp: Timestamp.fromDate(selectedEndDate),
                        maxParticipants:
                            int.parse(_maxParticipantsController.text),
                        includeZones: includeZones,
                        includeFinals: includeFinals,
                        includeSemiFinals: includeSemiFinals,
                        genderBased: genderBased,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Create Comp")),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildDatePickerRow({
  required BuildContext context,
  required DateTime? selectedDate,
  required Function(DateTime) onDateSelected,
  required String hintText,
}) {
  return Row(
    children: [
      Expanded(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedDate != null
                ? "${selectedDate.toLocal()}".split(' ')[0]
                : '',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            labelText: hintText,
            suffixIcon: const Icon(IconManager.calender),
          ),
        ),
      ),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: () {
          showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 5 * 365)),
          ).then((pickedDate) {
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          });
        },
        child: const Text('Select Date'),
      ),
    ],
  );
}
