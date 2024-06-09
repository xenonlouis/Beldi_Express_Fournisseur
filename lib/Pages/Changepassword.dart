import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Old Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter old password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'New Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter new password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                border: OutlineInputBorder(),
                errorText: _passwordsMatch ? null : 'Passwords do not match',
              ),
              onChanged: (_) {
                setState(() {
                  _passwordsMatch = _newPasswordController.text == _confirmPasswordController.text;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _passwordsMatch ? () => _changePassword(context) : null,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) async {
    // Implement Firebase Authentication method to change password
    try {
      // Check if passwords match before updating
      if (_passwordsMatch) {
        // Simulate a recent login by reauthenticating with the old password
        // Example:
         await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
         EmailAuthProvider.credential(
            email: FirebaseAuth.instance.currentUser!.email.toString(),
             password: _oldPasswordController.text,
          ),
         );

        // Once reauthentication is successful, update the password
        await FirebaseAuth.instance.currentUser?.updatePassword(_newPasswordController.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );

        // Navigate back to profile page or previous screen
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Handle error
      String errorMessage ;
      // Check if the error is due to invalid credentials (wrong old password)
      if (e is FirebaseAuthException && e.code == 'wrong-password') {
        errorMessage = 'Invalid old password. Please try again.';
      }

      print('Error changing password: $e');
       errorMessage = 'Failed to change password.';



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
