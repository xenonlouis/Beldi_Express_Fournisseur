import 'Layer.dart';

class Dish {
  late String? id;
  late String? idfournisseur;
  late String name;
  late String description;
  late double price;
  late List<String> ingredients;
  late String imageUrl;
  late List<Layer> layers;
  late double rating = 0.0; // Added rating attribute

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.ingredients,
    required this.imageUrl,
    required this.layers,
    required this.rating , // Initialize rating
    this.idfournisseur,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'layers': layers.map((layer) => layer.toMap()).toList(),
      'rating': rating,
      'idfournisseur': idfournisseur,
    };
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      ingredients: List<String>.from(json['ingredients']),
      imageUrl: json['imageUrl'],
      layers: (json['layers'] as List<dynamic>).map((layerJson) => Layer.fromJson(layerJson)).toList(),
      rating: json['rating'].toDouble() ?? 0.0, // Parse rating from JSON
      idfournisseur: json['idfournisseur'],
    );
  }

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? ingredients,
    String? imageUrl,
    List<Layer>? layers,
    double? rating,
    String? idfournisseur,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      layers: layers ?? this.layers,
      rating: rating ?? this.rating,
      idfournisseur: idfournisseur ?? this.idfournisseur,
    );
  }
}
