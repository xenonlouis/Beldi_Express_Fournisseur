import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dish_list/Service/F_Service.dart'; // Assuming you have a service class handling Firebase operations
import 'package:provider/provider.dart';

import '../Models/Layer.dart';
import '../Models/dish.dart';
import 'homepage.dart';

class AddDishPage extends StatefulWidget {
  @override
  _AddDishPageState createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  File? _imageFile;
  bool _isUploading = false;

  List<Layer> _layers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  // Pick image
  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Reset image
  void resetImage() {
    setState(() {
      _imageFile = null;
    });
  }

  // Upload image to Firebase Storage
  Future<String> uploadFile(File image, String dishId) async {
    String fileName = '$dishId.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child('dish_images/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);

    // Use onComplete listener to handle the completion of the upload task
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Upload is ${snapshot.bytesTransferred}/${snapshot.totalBytes} (${(snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(0)}%)');
    }, onError: (e) {
      print('Upload failed with error: $e');
    });

    try {
      await uploadTask;
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      throw e; // Rethrow the error to be caught by the calling function
    }
  }

  // Add layer
  void addLayer(String layerName, List<Option> options) {
    setState(() {
      _layers.add(Layer(layerName: layerName, options: options));
    });
  }

  // Add option to a layer
  void addOption(int layerIndex, String optionName, double price) {
    setState(() {
      _layers[layerIndex].options.add(Option(optionName: optionName, price: price));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Dish'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Dish Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the dish name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(labelText: 'Ingredients (comma separated)'),
                ),
                SizedBox(height: 20),
                _buildLayerFields(),
                SizedBox(height: 20),
                // Display the image picker button or the chosen image
                if (_imageFile == null)
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Pick Image'),
                  ),
                if (_imageFile != null) ...[
                  Image.file(_imageFile!),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: resetImage,
                    child: Text('Choose Another Image'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isUploading ? null : () async {
                      if (_formKey.currentState!.validate() && _imageFile != null) {
                        setState(() { _isUploading = true; });
                        try {
                          String imageUrl = await uploadFile(_imageFile!, '');
                          await addDish(imageUrl);
                        } catch (e) {
                          print('Error on adding dish button: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add dish. Please try again.')),
                          );
                        } finally {
                          setState(() { _isUploading = false; });
                        }
                      }
                    },
                    child: _isUploading ? CircularProgressIndicator() : Text('Add Dish'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to build layer input fields
  Widget _buildLayerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _layers.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_layers[i].layerName, style: TextStyle(fontWeight: FontWeight.bold)),
              ..._layers[i].options.asMap().entries.map((entry) {
                int index = entry.key;
                Option option = entry.value;
                TextEditingController nameController = TextEditingController(text: option.optionName);
                TextEditingController priceController = TextEditingController(text: option.price.toString());
                FocusNode nameFocusNode = FocusNode();
                FocusNode priceFocusNode = FocusNode();
                nameFocusNode.addListener(() {
                  if (!nameFocusNode.hasFocus) {
                    setState(() {
                      _layers[i].options[index].optionName = nameController.text;
                    });
                  }
                });
                priceFocusNode.addListener(() {
                  if (!priceFocusNode.hasFocus) {
                    setState(() {
                      _layers[i].options[index].price = double.tryParse(priceController.text) ?? 0.0;
                    });
                  }
                });
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        focusNode: priceFocusNode,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _layers[i].options.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _addOptionDialog(i),
                child: Text('Add Option'),
              ),
            ],
          ),
        SizedBox(height: 20),
        Center( // Centering the "Add Layer" button
          child: ElevatedButton(
            onPressed: _addLayerDialog,
            child: Text('Add Layer'),
          ),
        ),
      ],
    );
  }

  // Dialog to add a new option for a layer
  void _addOptionDialog(int layerIndex) {
    TextEditingController optionNameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Option'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: optionNameController,
                  decoration: InputDecoration(labelText: 'Option Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the new option to the specified layer
                String optionName = optionNameController.text.trim();
                double price = double.parse(priceController.text.trim());
                addOption(layerIndex, optionName, price);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to add a new layer
  void _addLayerDialog() {
    TextEditingController layerNameController = TextEditingController();
    TextEditingController optionNameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Layer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: layerNameController,
                  decoration: InputDecoration(labelText: 'Layer Name'),
                ),
                TextField(
                  controller: optionNameController,
                  decoration: InputDecoration(labelText: 'Default Option Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add the new layer with its options
                String layerName = layerNameController.text.trim();
                String optionName = optionNameController.text.trim();
                double price = double.parse(priceController.text.trim());
                addLayer(layerName, [Option(optionName: optionName, price: price)]);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add dish
  Future<void> addDish(String imageUrl) async {
    var dish = Dish(
      id: '', // ID will be generated by the database
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      ingredients: _ingredientsController.text.split(',').map((e) => e.trim()).toList(),
      imageUrl: imageUrl,
      layers: _layers.map((layerMap) => Layer.fromMap(layerMap.toMap())).toList(),
      rating: 0.0,
    );
    try {
      // Add the dish to the database
      print("Adding dish before database");
      print(dish.layers);
      String dishId = await context.read<FournisseurService>().addDish(dish);
      await context.read<FournisseurService>().addDishToList(dishId);
      // Optionally navigate to another screen or show a success message
      Navigator.pop(context);
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      print('Error adding dish: $e');
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add dish. Please try again.')),
      );
    }
  }
}
