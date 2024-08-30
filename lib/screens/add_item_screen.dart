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
                if (_nameController.text.isNotEmpty &&
                    _urlController.text.isNotEmpty &&
                    _imageUrlController.text.isNotEmpty) {
                  final newItem = Item(
                    name: _nameController.text,
                    url: _urlController.text,
                    imageUrl: _imageUrlController.text,
                  );

                  Provider.of<ItemListProvider>(context, listen: false)
                      .addItemToList(widget.list, newItem);

                  Navigator.pop(context);
                } else {
                  _showValidationError();
                }
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Validation Error'),
        content: Text('Please fill in all fields before adding the item.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
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
