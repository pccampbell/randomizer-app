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
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure that the provider has access to the Hive data
    final itemListProvider = Provider.of<ItemListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        title: const Text(
          'Your Lists',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportData(context);
              } else if (value == 'import') {
                _importData(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Text('Export Data'),
                ),
                const PopupMenuItem<String>(
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
            return const Center(
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
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final path = '$selectedDirectory/randomizer_data.json';
        await Provider.of<ItemListProvider>(context, listen: false)
            .exportData(path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully to $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export cancelled by user')),
        );
      }
    } catch (e) {
      print("Export error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  // Import data from a file
  Future<void> _importData(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final path = result.files.single.path!;
      await Provider.of<ItemListProvider>(context, listen: false).importData(path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data imported successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import cancelled by user')),
      );
    }
  } catch (e) {
    print("Import error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to import data: $e')),
    );
  }
}
}
