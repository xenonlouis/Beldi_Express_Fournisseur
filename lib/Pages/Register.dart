import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dish_list/Service/F_Service.dart';
import 'package:dish_list/Models/Fournisseur.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final fournisseurService = Provider.of<FournisseurService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adressse'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorText = null; // Clear previous error message
                });
                try {
                  Fournisseur? fournisseur = await fournisseurService.registerWithEmailAndPassword(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _nameController.text.trim(),
                    _phoneNumberController.text.trim(),
                    _addressController.text.trim(),
                  );
                  if (fournisseur != null) {
                    // Registration successful, navigate to the next screen or show a success message
                    Navigator.of(context).pushReplacementNamed('/sign-in'); // Example navigation
                  } else {
                    // Handle unexpected null response (unlikely without an exception)
                    setState(() {
                      _errorText = 'Unknown error occurred, please try again.';
                    });
                  }
                } on FirebaseAuthException catch (e) {

                  // Handle specific Firebase authentication errors
                  setState(() {
                    if (e.code == 'weak-password') {
                      _errorText = 'Password should be at least 6 characters';
                    } else if (e.code == 'email-already-in-use') {
                      _errorText = 'The email address is already in use by another account.';
                    } else {
                      _errorText = e.message ?? 'An error occurred. Please try again later.';
                    }
                  });
                } catch (e) {
                  // Handle other generic errors
                  setState(() {
                    _errorText = 'An error occurred. Please try again.';
                  });
                }
              },

              child: Text('Register'),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorText!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
