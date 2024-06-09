import 'package:cloud_firestore/cloud_firestore.dart';

import 'dishDTO.dart';

class Command {
  String id;
  String address;
  String clientId;
  String livreurId;
  String region;
  String status; // Status can be 'Processing', 'Currently being made', 'Ready to be picked up', etc.
  Map<String,
      List<
          DishDTO>> fournisseurDishes; // Key: Fournisseur ID, Value: List of DishDTOs for that Fournisseur
  Map<String, String> statusDishes; // Key: Dish ID, Value: Status
  List<String> fournisseurIDs;

  Command({
    required this.id,
    required this.address,
    required this.clientId,
    required this.livreurId,
    required this.region,
    required this.status,
    required this.fournisseurDishes,
    required this.statusDishes,
    required this.fournisseurIDs,
  });

  factory Command.fromJson(Map<String, dynamic> json,String docid) {
    Map<String, dynamic> fournisseurDishesJson = json['fournisseurDishes'];
    Map<String, List<DishDTO>> fournisseurDishes = {};

    fournisseurDishesJson.forEach((key, value) {
      List<dynamic> dishesJson = value;
      List<DishDTO> dishes = dishesJson.map((dishJson) =>
          DishDTO.fromJson(dishJson)).toList();
      fournisseurDishes[key] = dishes;
    });

    return Command(
      id: docid,
      address: json['address'],
      clientId: json['clientId'],
      livreurId: json['livreurId'],
      region: json['region'],
      status: json['status'],
      fournisseurDishes: fournisseurDishes,
      statusDishes: Map<String, String>.from(json['statusDishes']),
      fournisseurIDs: List<String>.from(json['fournisseurIDs']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'clientId': clientId,
      'livreurId': livreurId,
      'region': region,
      'status': status,
      'fournisseurDishes': fournisseurDishes.map((key, value) =>
          MapEntry(key, value.map((dish) => dish.toJson()).toList())),
      'statusDishes': statusDishes,
      'fournisseurIDs': fournisseurIDs,
    };
  }

  // Add a dish for a fournisseur
  void addDishForFournisseur(String fournisseurId, DishDTO dish) {
    if (fournisseurDishes.containsKey(fournisseurId)) {
      fournisseurDishes[fournisseurId]!.add(dish);
    } else {
      fournisseurDishes[fournisseurId] = [dish];
    }
  }

  // Remove a dish for a fournisseur
  void removeDishForFournisseur(String fournisseurId, DishDTO dish) {
    if (fournisseurDishes.containsKey(fournisseurId)) {
      fournisseurDishes[fournisseurId]!.remove(dish);
    }
  }

  // Update status for a dish
  Future<void> updateDishStatus(String commandid ,String dishId, String newValue) async {
    // Reference to the collection where dishes are stored

    final commandDocRef = FirebaseFirestore.instance.collection('Commandes').doc(commandid);

    try {
      // Update the statusDishes map with the new value for the given dishId
      await commandDocRef.update({
        'statusDishes.$dishId': newValue,
      });
      print("Dish status updated successfully.");
    } catch (e) {
      print("Failed to update dish status: $e");
    }
  }


}
