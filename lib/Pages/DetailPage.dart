import 'package:flutter/material.dart';
import 'package:dish_list/Models/dish.dart';
import 'package:dish_list/Service/DishProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Models/Layer.dart';

class DishDetailsPage extends StatefulWidget {
  final Dish dish;

  DishDetailsPage({required this.dish});

  @override
  _DishDetailsPageState createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  late Dish _updatedDish;
  File? _imageFile;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    // Create a copy of the original dish
    _updatedDish = widget.dish.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dish Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display original dish image
              // Display the image
              FractionallySizedBox(
                widthFactor: 1.0,
                child: _buildImageWidget(),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.image),
                label: Text('Change Picture'),
              ),
              SizedBox(height: 16),
              Text(
                'Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.dish.name,
                onChanged: (value) {
                  // Update the copied dish with the new name
                  _updatedDish = _updatedDish.copyWith(name: value);
                },
              ),
              SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.dish.description,
                onChanged: (value) {
                  // Update the copied dish with the new description
                  _updatedDish = _updatedDish.copyWith(description: value);
                },
              ),
              SizedBox(height: 16),
              Text(
                'Price:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.dish.price.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Update the copied dish with the new price
                  _updatedDish = _updatedDish.copyWith(
                      price: double.tryParse(value) ?? 0.0);
                },
              ),
              SizedBox(height: 16),
              Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: widget.dish.ingredients.join(', '),
                onChanged: (value) {
                  // Update the copied dish with the new ingredients
                  _updatedDish = _updatedDish.copyWith(
                      ingredients: value
                          .split(',')
                          .map((ingredient) => ingredient.trim())
                          .toList());
                },
              ),
              SizedBox(height: 16),
              _buildLayerFields(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isImageUploading ? null : () async {
                  final dishProvider = context.read<DishProvider>();

                  // Upload image if it's changed
                  String imageUrl = widget.dish.imageUrl;
                  if (_imageFile != null) {
                    setState(() {
                      _isImageUploading = true;
                    });
                    imageUrl = await uploadImage(_imageFile!);
                    setState(() {
                      _isImageUploading = false;
                    });
                  }

                  // Merge changes into the original dish
                  _updatedDish = _updatedDish.copyWith(
                    id: widget.dish.id,
                    imageUrl: imageUrl,
                  );
                  await dishProvider.updateDish(_updatedDish);
                  dishProvider.notifyListeners();
                  Navigator.pop(context);
                },
                child: _isImageUploading ? CircularProgressIndicator() : Text('Save Changes'),
              ),
            ],
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
        ...widget.dish.layers.asMap().entries.map((entry) {
          int layerIndex = entry.key;
          Layer layer = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Layer: ${layer.layerName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(), // Add space to separate icons
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        // Add new option to the layer
                        widget.dish.layers[layerIndex].options.add(Option(optionName: '', price: 0.0));
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        // Remove the entire layer
                        widget.dish.layers.removeAt(layerIndex);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              ...layer.options.asMap().entries.map((optionEntry) {
                int optionIndex = optionEntry.key;
                Option option = optionEntry.value;

                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: option.optionName,
                        onChanged: (value) {
                          setState(() {
                            // Update the option name in the copied dish
                            widget.dish.layers[layerIndex].options[optionIndex].optionName = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: option.price.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            // Update the option price in the copied dish
                            widget.dish.layers[layerIndex].options[optionIndex].price = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          // Remove the option from the layer
                          widget.dish.layers[layerIndex].options.removeAt(optionIndex);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 8),
            ],
          );
        }).toList(),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            String? layerName = await showDialog(
              context: context,
              builder: (context) {
                TextEditingController layerNameController = TextEditingController();
                return AlertDialog(
                  title: Text('Add Layer'),
                  content: TextFormField(
                    controller: layerNameController,
                    decoration: InputDecoration(labelText: 'Layer Name'),
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
                        Navigator.pop(context, layerNameController.text.trim());
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );

            if (layerName != null) {
              setState(() {
                // Add a new layer with the specified name and empty options
                widget.dish.layers.add(Layer(layerName: layerName, options: []));
              });
            }
          },
          child: Text('Add Layer'),
        ),
      ],
    );
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
  Widget _buildImageWidget() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8), // Adjust as needed
        child: Image.file(
          _imageFile!,
          fit: BoxFit.fitHeight, // Scale the image down if it's larger than the container
          height: 400, // Adjust height as needed
        ),
      );
    } else if (widget.dish.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Adjust as needed
        child: Image.network(
          widget.dish.imageUrl,
          fit: BoxFit.fitHeight,
          height: 200, // Adjust height as needed
        ),
      );
    } else {
      return Container(); // Placeholder for no image
    }
  }
  // Upload image to Firebase Storage
  Future<String> uploadImage(File image) async {
    String imageUrl = '';
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child('dish_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.whenComplete(() async {
        imageUrl = await storageReference.getDownloadURL();
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
    return imageUrl;
  }
}
