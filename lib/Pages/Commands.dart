import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/Command.dart';
import '../Models/dishDTO.dart';
import '../Pages/dishdtodetail.dart';

class FournisseurCommandsPage extends StatefulWidget {
  final String fournisseurId;

  FournisseurCommandsPage({required this.fournisseurId});

  @override
  _FournisseurCommandsPageState createState() => _FournisseurCommandsPageState();
}

class _FournisseurCommandsPageState extends State<FournisseurCommandsPage> {
  Stream<List<Command>> _commandsStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    _commandsStream = _fetchCommands(widget.fournisseurId);
  }

  Stream<List<Command>> _fetchCommands(String fournisseurId) {
    return FirebaseFirestore.instance
        .collection('Commandes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Command.fromJson(doc.data(), doc.id))
          .where((command) =>
      command.fournisseurIDs.contains(fournisseurId) &&
          command.livreurId!= "")
          .toList();
    });
  }

  Stream<List<DishDTO>> _fetchDishes(String fournisseurId, Command command) {
    List<DishDTO>? fournisseurDishesList = command.fournisseurDishes[fournisseurId];
    return Stream.value(fournisseurDishesList?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fournisseur Commands'),
      ),
      body: StreamBuilder<List<Command>>(
        stream: _commandsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Command>? commands = snapshot.data;
            if (commands == null || commands.isEmpty) {
              return Center(child: Text('No commands available'));
            } else {
              return ListView.builder(
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  Command command = commands[index];
                  return StreamBuilder<List<DishDTO>>(
                    stream: _fetchDishes(widget.fournisseurId, command),
                    builder: (context, dishSnapshot) {
                      if (dishSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (dishSnapshot.hasError) {
                        return Text('Error: ${dishSnapshot.error}');
                      } else {
                        List<DishDTO>? dishes = dishSnapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(20),
                              color: Colors.grey[200],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Command ID: ${command.id}',
                                    style: TextStyle(
                                      fontSize: 14, // Adjusted font size to make it smaller
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5), // Added spacing between the two lines
                                  Text(
                                    'Livreur ID: ${command.livreurId}',
                                    style: TextStyle(
                                      fontSize: 12, // Adjusted font size to make it smaller
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            if (dishes!= null)
                              Column(
                                children: dishes.map((dish) => ListTile(
                                  title: Text(dish.name),
                                  subtitle: Text('Price: \$${dish.price.toString()}'),
                                  trailing: DropdownButton<String>(
                                    value: command.statusDishes[dish.id]?? 'processing',
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        command.updateDishStatus(command.id, dish.id.toString(), newValue.toString());
                                      });
                                    },
                                    items: <String>['processing', 'Currently being made', 'Ready to be picked up']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DishDtoDetailsPage(dish: dish)),
                                    );
                                  },
                                )).toList(),
                              ),
                          ],
                        );
                      }
                    },
                  );

                },
              );
            }
          }
        },
      ),
    );
  }
}
