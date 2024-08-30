import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_list.dart';
import 'package:randomizer_app/main.dart';

class NewListScreen extends StatefulWidget {
  @override
  _NewListScreenState createState() => _NewListScreenState();
}

class _NewListScreenState extends State<NewListScreen> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'List Title'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create a new ItemList with the entered title
                final newList = ItemList(title: _titleController.text);
                // Add the new list to the provider (and save it to Hive)
                Provider.of<ItemListProvider>(context, listen: false).addList(newList);
                // Navigate back to the previous screen
                Navigator.pop(context);
              },
              child: Text('Create List'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();  // Dispose of the controller when done
    super.dispose();
  }
}