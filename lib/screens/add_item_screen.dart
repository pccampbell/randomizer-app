import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../models/item_list.dart';
import 'package:randomizer_app/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


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
  final _detailsController = TextEditingController();
  final _newTagController = TextEditingController();

  List<String> _tags = [];

  Future<String?> _fetchImageUrl(String query) async {
    final String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? ''; 
    final String searchEngineId = dotenv.env['SEARCH_ENGINE_ID'] ?? '';
    final String url =
        'https://www.googleapis.com/customsearch/v1?q=${Uri.encodeComponent(query)}&cx=$searchEngineId&searchType=image&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return items.first['link'] as String?;
        }
      }
    } catch (e) {
      print('Error fetching image URL: $e');
    }
    return null; // Return null if no image is found or an error occurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Default color for underline
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Item URL',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Item Details',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                maxLines: null, // Allow multiline input
              ),
              SizedBox(height: 16.0),
              // Tag input and display
              TextField(
                controller: _newTagController,
                decoration: InputDecoration(
                  labelText: 'Add a Tag',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (_newTagController.text.isNotEmpty &&
                          !_tags.contains(_newTagController.text)) {
                        setState(() {
                          _tags.add(_newTagController.text);
                        });
                        _newTagController.clear();
                      }
                    },
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 6.0,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String? imageUrl = _imageUrlController.text.trim();
                    if (imageUrl.isEmpty) {
                      imageUrl = await _fetchImageUrl(_nameController.text.trim());
                    }

                    final newItem = Item(
                      name: _nameController.text,
                      url: _urlController.text,
                      imageUrl: imageUrl ?? '', // Use fetched URL or empty string
                      details: _detailsController.text,
                      tags: _tags,
                    );

                    Provider.of<ItemListProvider>(context, listen: false)
                        .addItemToList(widget.list, newItem);

                    Provider.of<ItemListProvider>(context, listen: false)
                        .saveLists();

                    Navigator.pop(context);
                  },
                  child: Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    _detailsController.dispose();
    _newTagController.dispose();
    super.dispose();
  }
}
