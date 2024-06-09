import 'Layer.dart';

class DishDTO {

  String? id;
  String name;
  double price;
  List<Layer> layers;
  int quantity;

  DishDTO({
    this.id,
    required this.name,
    required this.price,
    required this.layers,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'layers': layers.map((layer) => layer.toMap()).toList(),
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'layers': layers.map((layer) => layer.toMap()).toList(),
      'quantity': quantity,
    };
  }

  factory DishDTO.fromJson(Map<String, dynamic> json) {
    return DishDTO(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      layers: (json['layers'] as List<dynamic>).map((layerJson) => Layer.fromJson(layerJson)).toList(),
      quantity: json['quantity'].toInt(),
    );
  }

  DishDTO copyWith({
    String? id,
    String? name,
    double? price,
    List<Layer>? layers,
    int? quantity,
  }) {
    return DishDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      layers: layers ?? this.layers,
      quantity: quantity ?? this.quantity,
    );
  }

}
