import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dish_list/Models/Fournisseur.dart';
import 'package:flutter/cupertino.dart';

import '../Models/dish.dart';

class FournisseurService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<Fournisseur?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        return await _getFournisseurData(user.uid);
      }
    } catch (e) {
      throw(e);
      print("Error signing in: $e");
    }
    return null;
  }

  // Register with email and password
  Future<Fournisseur?> registerWithEmailAndPassword(String email, String password, String name, String phoneNumber,String address) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        // Create a new document in the Fournisseur collection with the user's ID
        await _firestore.collection('Fournisseurs').doc(user.uid).set({
          'email': email,
          'name': name,
          'phoneNumber': phoneNumber,
          'dishIds': [],
          'address': address
        });
        // Fetch the fournisseur data
        return await _getFournisseurData(user.uid);
      }
    } catch (e) {
      throw(e);
      print("Error registering: $e");
    }
    return null;
  }

  // Get fournisseur data from Firestore
  Future<Fournisseur?> _getFournisseurData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('Fournisseurs').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Fournisseur(
          id: uid,
          email: data['email'],
          name: data['name'],
          phoneNumber: data['phoneNumber'],
          dishIds: List<String>.from(data['dishIds']),
          address: data['address'],
        );
      }
    } catch (e) {
      print("Error fetching fournisseur data: $e");
    }
    return null;
  }


  Future<String> addDish(Dish dish) async {
    try {
      DocumentReference docRef = await _firestore.collection('Dishes').add(dish.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding dish: $e');
    }
  }

  Future<void> updateDish(Dish dish) async {
    try {
      print("dish: "+ dish.id.toString());
      await _firestore.collection('Dishes').doc(dish.id).update(dish.toMap());
    } catch (e) {
      throw Exception('Error updating dish: $e');
    }
  }

  Future<void> addDishToList(String dishId) async {
    try {
      // Get the current user's ID (you might need to replace this with your actual user ID retrieval method)
      // Get the current user ID from Firebase Authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String fournisseurId = currentUser.uid;
        // Now you can use fournisseurId to reference the current user's document in Firestore

        await _firestore.collection('Fournisseurs').doc(fournisseurId).update({
          'dishIds': FieldValue.arrayUnion([dishId]),
        });
      } else {
        // Handle the case where the current user is not authenticated
        print('User is not authenticated');
      }

    } catch (e) {
      throw Exception('Error adding dish to list: $e');
    }
  }


  @override
  void notifyListeners() {
    // Call notifyListeners provided by ChangeNotifier
    super.notifyListeners();
  }
}
