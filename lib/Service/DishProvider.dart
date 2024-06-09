import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dish_list/Models/dish.dart';

class DishProvider extends ChangeNotifier {
  List<Dish> _dishes = [];

  List<Dish> get dishes => _dishes;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to fetch dishes associated with the current fournisseur
  Future<void> fetchDishes() async {
    print("heeeere");
    try {
      final String fournisseurId = _auth.currentUser!.uid;

      // Retrieve the fournisseur document
      DocumentSnapshot fournisseurSnapshot = await _firestore
          .collection('Fournisseurs')
          .doc(fournisseurId)
          .get();

      // Check if the fournisseur document exists
      if (!fournisseurSnapshot.exists) {
        throw Exception('Fournisseur with ID $fournisseurId does not exist');
      }

      // Extract dish IDs from the fournisseur's document
      List<String> dishIds = List<String>.from(
          fournisseurSnapshot.get('dishIds'));

      // Fetch dishes based on the extracted dish IDs
      List<Dish> dishes = [];
      for (String dishId in dishIds) {
        DocumentSnapshot dishSnapshot = await _firestore
            .collection('Dishes')
            .doc(dishId)
            .get();
        print(dishSnapshot.data());
        if (dishSnapshot.exists) {
          print("this is in providor");
          Dish dish = Dish.fromJson(
              dishSnapshot.data() as Map<String, dynamic>);
          dish = dish.copyWith(id: dishId,idfournisseur: fournisseurId);
          print("loiiiis");
          dishes.add(dish);
        }
      }

      _dishes = dishes;
    } catch (e) {
      print('Error fetching dishes: $e');
      throw Exception('Error fetching dishes: $e');
    }
  }

  // Method to update a dish
  Future<void> updateDish(Dish dish) async {
    try {

      await _firestore.collection('Dishes').doc(dish.id).update(dish.toMap());
      // Optionally, you can update the local list of dishes after updating the dish in Firestore
      notifyListeners();
    } catch (e) {
      print('Error updating dish: $e');
      throw Exception('Error updating dish: $e');
    }
  }

  Future<void> deleteDish(Dish dish) async {
    try {
      print("dish" +"   "+ dish.id.toString());
      // Delete the dish image from Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('/dish_images/${dish.id}.jpg');
      await storageRef.delete();

      // Delete the dish from the database
      await _firestore.collection('Dishes').doc(dish.id).delete();

      // Remove the dish ID from the fournisseur's dish list
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String fournisseurId = currentUser.uid;
        await _firestore.collection('Fournisseurs').doc(fournisseurId).update({
          'dishIds': FieldValue.arrayRemove([dish.id]),
        });
      }
      notifyListeners();
      // Optionally, you can show a success message or navigate to another screen
    } catch (e) {
      print('Error deleting dish: $e');
      throw Exception('Error deleting dish: $e');
    }
// Other methods...
  }
}
