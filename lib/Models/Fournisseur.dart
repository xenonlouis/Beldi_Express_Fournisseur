// fournisseur.dart
class Fournisseur {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final List<String> dishIds; // List of dish IDs
  final String address;


  Fournisseur({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.dishIds,
    required this.address,


  });

}
