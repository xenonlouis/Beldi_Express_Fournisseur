class Layer {
  final String layerName;
  final List<Option> options;

  Layer({
    required this.layerName,
    required this.options,
  });


  Map<String, dynamic> toMap() {
    return {
      'layerName': layerName,
      'options': options.map((option) => option.toMap()).toList(), // Convert each option to a map
    };
  }
  factory Layer.fromMap(Map<String, dynamic> map) {
    return Layer(
      // Initialize properties from map
      layerName: map['layerName'],
      options: (map['options'] as List<Map<String, dynamic>>).map((optionMap) => Option.fromMap(optionMap)).toList(),
    );
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      layerName: json['layerName'],
      options: (json['options'] as List<dynamic>).map((optionJson) => Option.fromJson(optionJson)).toList(),
      // Convert each option JSON to an Option object
    );
  }
}

class Option {
  late  String optionName;
  late  double price;

  Option({
    required this.optionName,
    required this.price,
  });
  Option copyWith({
    String? optionName,
    double? price,
  }) {
    return Option(
      optionName: optionName ?? this.optionName,
      price: price ?? this.price,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'optionName': optionName,
      'price': price,
    };
  }
  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      optionName: map['optionName'],
      price: map['price'],
    );
  }
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionName: json['optionName'],
      price: json['price'].toDouble(),
    );
  }
}
