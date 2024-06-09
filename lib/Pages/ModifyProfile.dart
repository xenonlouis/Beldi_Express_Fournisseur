import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Service/AuthProvider.dart';

class ModifyProfilePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Fetch the user profile from the provider
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;

    // Set initial values for the text controllers
    _nameController.text = userProfile.name;
    _phoneNumberController.text = userProfile.phoneNumber;
    _addressController.text = userProfile.address;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _updateProfile(context);
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _changeEmail(context);
                },
                child: Text('Change Email'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _changePassword(context);
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfile(BuildContext context) {
    // Get the updated values from the text controllers
    final newName = _nameController.text;
    final newPhoneNumber = _phoneNumberController.text;
    final newAddress = _addressController.text;

    // Call a method to update the user's profile
    UserProfileProvider userProfileProvider = context.read<UserProfileProvider>();
    userProfileProvider.updateUserProfile(userProfileProvider.userProfile.id, newName,userProfileProvider.userProfile.email, newPhoneNumber,newAddress);
    // After updating the profile, navigate back to the profile page
    userProfileProvider.update();
    Navigator.pop(context);
  }

  void _changeEmail(BuildContext context) {
    // Navigate to the screen where users can change their email
    Navigator.pushNamed(context, '/change-email');
  }

  void _changePassword(BuildContext context) {
    // Navigate to the screen where users can change their password
    Navigator.pushNamed(context, '/change-password');
  }
}
