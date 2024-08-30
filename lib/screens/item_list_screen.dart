import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/item_list.dart';
import 'add_item_screen.dart';
import 'package:randomizer_app/main.dart';

class ItemListScreen extends StatelessWidget {
  final ItemList list;

  ItemListScreen({required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showMenu(context);
            },
          ),
        ],
      ),
      body: Consumer<ItemListProvider>(
        builder: (context, provider, child) {
          // Find the updated list in the provider
          final updatedList = provider.lists.firstWhere((l) => l.title == list.title);
          return ListView.builder(
            itemCount: updatedList.items.length,
            itemBuilder: (context, index) {
              final item = updatedList.items[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(item.name),
                subtitle: Text(item.url),
                tileColor: item.isPicked ? Colors.grey[300] : Colors.white,
                onTap: () {
                  // Handle URL opening if needed
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(list: list)),
          );
          // Trigger UI update after returning from AddItemScreen
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final randomItem = list.randomPick();
            if (randomItem != null) {
              Provider.of<ItemListProvider>(context, listen: false)
                  .markItemPicked(list, randomItem);
              _showPickedItemDialog(context, randomItem);
            }
          },
          child: Text('Shuffle and Pick'),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit List Name'),
              onTap: () {
                Navigator.pop(context);
                _showEditListNameDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete List'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteList(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditListNameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: list.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit List Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new list name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Provider.of<ItemListProvider>(context, listen: false)
                      .lists
                      .firstWhere((l) => l.title == list.title)
                      .title = controller.text;
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete List'),
          content: Text('Are you sure you want to delete this list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ItemListProvider>(context, listen: false)
                    .lists
                    .removeWhere((l) => l.title == list.title);
                Navigator.pop(context);
                Navigator.pop(context); // Return to the previous screen
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showPickedItemDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Randomly Picked Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              SizedBox(height: 10),
              Text(item.name),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _launchURL(item.url);
                },
                child: Text(item.url),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    // Handle URL launching
  }
}
