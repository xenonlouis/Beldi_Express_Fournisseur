import 'package:dish_list/Service/AuthProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeEmailPage extends StatelessWidget {
  final TextEditingController _newEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your new email:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newEmailController,
              decoration: InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _changeEmail(context);
              },
              child: Text('Change Email'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeEmail(BuildContext context) {
    // Implement Firebase Authentication method to change email
    // Example:
    FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(_newEmailController.text);
    UserProfileProvider userProfileProvider = context.read<UserProfileProvider>();
    userProfileProvider.update();
    // Show success message or handle error
    // Then navigate back to profile page or previous screen
    Navigator.pop(context);
  }
}
