import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/dish.dart';
import '../Service/DishProvider.dart';
import 'DetailPage.dart';

class ListDishesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Dishes'),
      ),
      body: Consumer<DishProvider>(
        builder: (context, dishProvider, _) {
          return FutureBuilder<void>(
            future: dishProvider.fetchDishes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final dishes = dishProvider.dishes;
                return ListView.builder(
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    return ListTile(
                      title: Text(dish.name),
                      subtitle: Text('${dish.price}'),
                      leading: Image.network(dish.imageUrl),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, dishProvider, dish);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DishDetailsPage(dish: dish),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DishProvider dishProvider, Dish dish) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Dish'),
          content: Text('Are you sure you want to delete ${dish.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                dishProvider.deleteDish(dish); // Call the method to delete the dish
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
