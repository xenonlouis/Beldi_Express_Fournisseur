import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Fournisseur.dart';

class UserProfileProvider with ChangeNotifier {
  late Fournisseur _userProfile;
  late FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Fournisseur get userProfile => _userProfile;

  UserProfileProvider() {
    _fetchUserProfile();
  }

  void update() {_fetchUserProfile();}

  Future<void> _fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection('Fournisseurs').doc(currentUser.uid).get();
        final userData = snapshot.data() as Map<String, dynamic>;
        _userProfile = Fournisseur(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: userData['name'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          dishIds: List<String>.from(userData['dishIds'] ?? []),
          address: userData['address'] ?? '',

        );
        sleep(Duration(milliseconds: 25));
        notifyListeners();
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }
  }

  Future<void> updateUserProfile(String userId, String newName, String newEmail, String newPhoneNumber,String newAddress) async {
    try {
      // Get a reference to the user profile document in Firestore
      final userDocRef = FirebaseFirestore.instance.collection('Fournisseurs').doc(userId);

      // Update the fields in the document
      await userDocRef.update({
        'name': newName,
        'email': newEmail,
        'phoneNumber': newPhoneNumber,
        'address': newAddress
      });
      notifyListeners();

      print('User profile updated in the database');
    } catch (e) {
      print('Error updating user profile in the database: $e');
      throw e; // Optionally rethrow the error to handle it elsewhere
    }
  }

}
