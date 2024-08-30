import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './item_list_screen.dart';
import './new_list_screen.dart';
import 'package:randomizer_app/main.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ensure that the provider has access to the Hive data
    final itemListProvider = Provider.of<ItemListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        title: Text(
          'Your Lists',
          style: const TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: itemListProvider.loadLists(),  // Load lists from Hive
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading lists'));  // Handle errors
          } else {
            return ListView.builder(
              itemCount: itemListProvider.lists.length,
              itemBuilder: (context, index) {
                final list = itemListProvider.lists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    color: Colors.grey[200],
                    elevation: 4,  // Adds a shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),  // Rounds the corners
                    ),
                    child: ListTile(
                      title: Text(
                        list.title,
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemListScreen(list: list),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewListScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}