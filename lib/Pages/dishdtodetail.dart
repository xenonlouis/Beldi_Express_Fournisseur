import 'package:flutter/material.dart';
import 'package:dish_list/Models/dishDTO.dart';
import '../Models/Layer.dart';

class DishDtoDetailsPage extends StatelessWidget {
  final DishDTO dish;

  DishDtoDetailsPage({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dish Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildTitleText('ID: ${dish.id}'),
            _buildTitleText('Name: ${dish.name}'),
            _buildTitleText('Price: \$${dish.price.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            _buildTitleText('Layers:'),
            _buildLayersList(dish.layers),
            SizedBox(height: 20),
            _buildTitleText('Quantity: ${dish.quantity}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLayersList(List<Layer> layers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: layers.map((layer) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${layer.layerName}:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: layer.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        option.optionName,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}
