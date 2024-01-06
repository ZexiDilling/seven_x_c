import 'package:flutter/material.dart';
import 'package:seven_x_c/services/auth/auth_service.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final TextEditingController _displayNameController = TextEditingController();
  String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;
  late final FirebaseCloudStorage _userService;

  bool _isSetter = false;
  bool _isAdmin = false;
  bool _isAnonymous = false;
  String _gradingSystem = 'Coloured';

  @override
  void initState() {
    super.initState();
    // Initialize the form fields with current user information
    _userService = FirebaseCloudStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Nick-name'),
              ),
              const SizedBox(height: 16.0),
              Text(userEmail),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Add logic to change password
                },
                child: const Text('Change Password'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _isSetter,
                    onChanged: (value) {
                      setState(() {
                        _isSetter = value ?? false;
                      });
                    },
                  ),
                  const Text('Setter'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isAdmin,
                    onChanged: (value) {
                      setState(() {
                        _isAdmin = value ?? false;
                      });
                    },
                  ),
                  const Text('Admin'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                  ),
                  const Text('Anonymous'),
                  IconButton(
                    onPressed: () {
                      _showAnonymousInfo(context);
                    },
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Grading: '),
                  DropdownButton<String>(
                    value: _gradingSystem,
                    onChanged: (String? newValue) {
                      setState(() {
                        _gradingSystem = newValue ?? 'Coloured';
                      });
                    },
                    items: <String>['Coloured', 'French', 'V-Grade']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    onPressed: () {
                      _showGradingSystemInfo(context);
                    },
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _createOrUpdateUserProfile();
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createOrUpdateUserProfile() async {
    try {
      // Check if the user exists
      final currentProfileStream = _userService.getUser(userID: userId.toString());
      final currentProfile = await currentProfileStream.first;
      if (currentProfile.isNotEmpty) {
        // User exists, update the user profile information
        await _userService.updateUser(
          currentProfile: currentProfile.first,
          displayName: _displayNameController.text,
          isSetter: _isSetter,
          isAdmin: _isAdmin,
          isAnonymous: _isAnonymous,
          gradingSystem: _gradingSystem,
        );
      } else {
        // User does not exist, create a new user
        await _userService.createNewUser(
          
          boulderPoints: 0.0,
          setterPoints: 0.0,
          isSetter: _isSetter,
          isAdmin: _isAdmin,
          isAnonymous: _isAnonymous,
          email: userEmail,
          displayName: _displayNameController.text,
          gradingSystem: _gradingSystem,
          userID: userId
        );
      }
    } catch (e) {
      // Handle the error, e.g., display an error message
      // ignore: avoid_print
      print('Failed to update/create user profile: $e');
    }
  }

  void _showAnonymousInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Anonymous Mode'),
          content: const Text('Will not show your Nick-name on any lists.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showGradingSystemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Grading System'),
          content: const Text('This is the grade you will see on the boulder.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
