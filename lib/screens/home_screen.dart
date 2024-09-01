import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './item_list_screen.dart';
import './new_list_screen.dart';
import '../models/item_list.dart';
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                // _exportData(context);
                print('Exporting data');
              } else if (value == 'import') {
                print('Importing data');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'export',
                  child: Text('Export Data'),
                ),
                PopupMenuItem<String>(
                  value: 'import',
                  child: Text('Import Data'),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: itemListProvider.loadLists(), // Load lists from Hive
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading lists')); // Handle errors
          } else {
            return ListView.builder(
              itemCount: itemListProvider.lists.length,
              itemBuilder: (context, index) {
                final list = itemListProvider.lists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    color: Colors.grey[200],
                    elevation: 4, // Adds a shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounds the corners
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

  // Export data to a file
  Future<void> _exportData(BuildContext context) async {
    try {
      final box = await Hive.openBox('itemBox');
      final data = box.values
          .map((itemList) => (itemList as ItemList).toJson())
          .toList();
      final jsonData = jsonEncode(data);

      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/randomizer_data.json';
      final file = File(path);
      await file.writeAsString(jsonData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  // Import data from a file
  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();
        final List<dynamic> data = jsonDecode(jsonData);

        final box = await Hive.openBox('itemLists');
        await box.clear();

        for (var itemListJson in data) {
          final itemList = ItemList.fromJson(itemListJson);
          await box.add(itemList);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import data: $e')),
      );
    }
  }

}
