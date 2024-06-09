import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Service/AuthProvider.dart';

class ProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    sleep(Duration(milliseconds: 20));
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, _) {
          sleep(Duration(milliseconds: 50));
          final userProfile =  userProfileProvider.userProfile;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Name'),
                    subtitle: Text(userProfile.name),
                  ),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text(userProfile.email),
                  ),
                  ListTile(
                    title: Text('Phone Number'),
                    subtitle: Text(userProfile.phoneNumber),
                  ),
                  ListTile(
                    title: Text('Address'),
                    subtitle: Text(userProfile.address),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _modifyProfile(context);
                    },
                    child: Text('Modify Profile'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _signOut(context);
                    },
                    child: Text('Sign Out'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _modifyProfile(BuildContext context) {
    // Navigate to the screen where users can modify their profile
    Navigator.pushNamed(context, '/modify-profile');
      }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate back to the sign-in screen
      Navigator.pushReplacementNamed(context, '/sign-in');
    } catch (e) {
      print('Error signing out: $e');
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out. Please try again.')),
      );
    }
  }
}
