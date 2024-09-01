import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/item_list.dart';
import 'package:randomizer_app/main.dart';

class AddItemScreen extends StatefulWidget {
  final ItemList list;

  AddItemScreen({required this.list});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'Item URL'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                final newItem = Item(
                  name: _nameController.text,
                  url: _urlController.text,
                  imageUrl: _imageUrlController.text,
                );

                // Add the new item to the list and save the updated list
                Provider.of<ItemListProvider>(context, listen: false)
                    .addItemToList(widget.list, newItem);

                // Save the updated list to Hive
                Provider.of<ItemListProvider>(context, listen: false)
                    .saveLists();

                Navigator.pop(context);
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}