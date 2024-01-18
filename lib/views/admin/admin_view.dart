import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seven_x_c/services/cloude/firebase_cloud_storage.dart';
import 'package:seven_x_c/services/cloude/profile/cloud_profile.dart';

class AdminPanelView extends StatefulWidget {
  const AdminPanelView({super.key});

  @override
  State<AdminPanelView> createState() => _AdminPanelViewState();
}

class _AdminPanelViewState extends State<AdminPanelView> {
  late final FirebaseCloudStorage _userService;

  @override
  void initState() {
    _userService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  String _emailQuery = '';
  String _displayNameQuery = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final StreamController<Iterable<CloudProfile>> _searchController =
      StreamController<Iterable<CloudProfile>>();
  Stream<Iterable<CloudProfile>> get searchResults => _searchController.stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Enter user display name'),
                onChanged: (displayName) {
                  setState(() {
                    _displayNameQuery = displayName;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', hintText: 'Enter user email'),
                onChanged: (email) {
                  setState(() {
                    _emailQuery = email;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchUser(_userService, _emailQuery, _displayNameQuery);
                },
                child: const Text('Search'),
              ),
              const SizedBox(height: 16),
              // Display search results here
              StreamBuilder<Iterable<CloudProfile>>(
                stream: searchResults,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildSearchResults(snapshot.data!);
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Text('Loading...');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(Iterable<CloudProfile> searchResults) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var user = searchResults.elementAt(index);
        return _buildUserOverviewBox(user);
      },
    );
  }

  Widget _buildUserOverviewBox(CloudProfile user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Name: ${user.displayName}'),
            Text('Email: ${user.email}'),
            CheckboxListTile(
              title: const Text('Is Admin'),
              value: user
                  .isAdmin, // Replace with the actual field from your CloudProfile model
              onChanged: (bool? value) {
                // Handle the change and update the user's isAdmin status
                _userService.updateUser(currentProfile: user, isAdmin: value);
              },
            ),
            CheckboxListTile(
              title: const Text('Is Setter'),
              value: user
                  .isSetter, // Replace with the actual field from your CloudProfile model
              onChanged: (bool? value) {
                // Handle the change and update the user's isSetter status
                _userService.updateUser(currentProfile: user, isSetter: value);
              },
            ),
            // Add other user details based on your CloudProfile model
          ],
        ),
      ),
    );
  }

  void _searchUser(
      FirebaseCloudStorage userService, String email, String displayName) {
    Stream<Iterable<CloudProfile>> searchStream;

    if (email.isEmpty) {
      searchStream = userService.getUserFromDisplayName(displayName);
    } else {
      searchStream = userService.getUserFromEmail(email);
    }

    searchStream.listen(
      (searchResults) {
        _searchController.add(searchResults);
      },
      onError: (error) {},
      onDone: () {
      },
    );
  }


}
