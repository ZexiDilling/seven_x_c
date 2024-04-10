import 'package:flutter/material.dart';
import 'package:seven_x_c/constants/country.dart';


class CreateLocationView extends StatefulWidget {
  const CreateLocationView({super.key});

  @override
  State<CreateLocationView> createState() => _CreateLocationViewState();
}

class _CreateLocationViewState extends State<CreateLocationView> {
  // Initialize variables for checkboxes
  bool bouldering = false;
  bool tradClimbing = false;
  bool sportClimbing = false;
  bool isGym = false;
  String? selectedLocation;

  // Initialize variables for text fields and dropdown
  TextEditingController infoController = TextEditingController();
  TextEditingController accessController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addyController = TextEditingController();
  TextEditingController homePageController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController xCordController = TextEditingController();
  TextEditingController yCordController = TextEditingController();
  String selectedCountry = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CheckboxListTile(
                    title: const Text('Bouldering'),
                    value: bouldering,
                    onChanged: (value) {
                      setState(() {
                        bouldering = value!;
                      });
                    },
                  ),
                ],
              ),
              // Checkboxes
              Row(
                children: [
                  CheckboxListTile(
                    title: const Text('Sports Climbing'),
                    value: sportClimbing,
                    onChanged: (value) {
                      setState(() {
                        sportClimbing = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Trad Climbing'),
                    value: tradClimbing,
                    onChanged: (value) {
                      setState(() {
                        tradClimbing = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  RadioListTile(
                    title: const Text('Gym'),
                    value: 'Gym',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                        isGym = true;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Nature'),
                    value: 'Nature',
                    groupValue: selectedLocation,
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                        isGym = false;
                      });
                    },
                  ),
                ],
              ),

              // Text field for name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                  controller: infoController,
                  decoration: const InputDecoration(labelText: "Info?")),
              TextField(
                  controller: homePageController,
                  decoration: const InputDecoration(labelText: "HomePage?")),
              TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: "Contact?")),
              // Dropdown for country
              DropdownButtonFormField(
                value: selectedCountry.isNotEmpty ? selectedCountry : null,
                items: countryCodes.keys.map((countryName) {
                  return DropdownMenuItem(
                    value: countryName,
                    child: Text(countryName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value.toString();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Country',
                ),
              ),

              // Text field for gym address (conditional)
              if (isGym)
                TextField(
                  controller: addyController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                ),
              if (!isGym)
                TextField(
                  controller: accessController,
                  decoration: const InputDecoration(
                    labelText: 'Access',
                  ),
                ),
              if (!isGym)
                TextField(
                  controller: accessController,
                  decoration: const InputDecoration(
                    labelText: 'Access',
                  ),
                ),
              Row(
                children: [
                  TextFormField(
                    controller: xCordController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'X-coordinate',
                    ),
                  ),
                  TextFormField(
                    controller: yCordController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Y-coordinate',
                    ),
                  ),
                ],
              ),
              OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () {}, child: const Text("Save")),
                  TextButton(onPressed: () {}, child: const Text("Cancel"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
