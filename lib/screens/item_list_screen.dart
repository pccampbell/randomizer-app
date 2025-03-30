import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/item_list.dart';
import 'add_item_screen.dart';
import 'package:randomizer_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

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
          final updatedList =
              provider.lists.firstWhere((l) => l.title == list.title);
          return ListView.builder(
            itemCount: updatedList.items.length,
            itemBuilder: (context, index) {
              final item = updatedList.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5.0), // Add padding around each card
                child: Card(
                  margin: EdgeInsets.zero,
                  color: item.isPicked ? Colors.grey[500] : Colors.grey[200],
                  elevation: 4, // Adds a shadow to the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Rounds the corners of the card
                  ),
                  child: ListTile(
                    leading: item.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.insert_photo),
                          )
                        : SizedBox(width: 100),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                    onTap: () {
                      _showViewItemDialog(
                          context, item); // Shows the item details in a dialog
                    },
                  ),
                ),
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
          // Ensure that the list is saved after returning from AddItemScreen
          Provider.of<ItemListProvider>(context, listen: false).saveLists();
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Space the buttons evenly
          children: [
            // Existing Shuffle and Pick button
            ElevatedButton(
              onPressed: () {
                final randomItem = list.randomPick();
                if (randomItem != null) {
                  Provider.of<ItemListProvider>(context, listen: false)
                      .markItemPicked(list, randomItem);
                  _playLottieAndShowPickedItem(context, randomItem);
                  Provider.of<ItemListProvider>(context, listen: false)
                      .saveLists();
                }
              },
              child: Text('Shuffle and Pick'),
            ),
            // New Filter & Pick button
            ElevatedButton(
              onPressed: () {
                _showTagFilterPopup(context, list); // Opens the tag filter popup
              },
              child: Text('Filter & Pick'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagFilterPopup(BuildContext originalContext, ItemList list) {
    final selectedTags = <String>{};
    final allTags = <String, int>{};

    // Collect tags from unpicked items in the list and count occurrences
    for (var item in list.items.where((item) => !item.isPicked)) {
      for (var tag in item.tags) {
        allTags[tag] = (allTags[tag] ?? 0) + 1;
      }
    }

    showDialog(
      context: originalContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Tags to Filter'),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0, // Space between tags
                  runSpacing: 4.0, // Space between rows of tags
                  children: allTags.keys.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTags.remove(tag);
                          } else {
                            selectedTags.add(tag);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          '$tag (${allTags[tag]})',
                          style: TextStyle(
                            color: isSelected ? Colors.blue[800] : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    Spacer(), // Adds space between Cancel and Pick from Filtered
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the tag filter dialog
                        _filterAndPick(originalContext, list, selectedTags);
                      },
                      child: Text('Pick from Filtered',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterAndPick(
      BuildContext originalContext, ItemList list, Set<String> selectedTags) {
    // Filter items that are not already picked and match selected tags
    final filteredItems = list.items.where((item) {
      return !item.isPicked &&
          item.tags.any((tag) => selectedTags.contains(tag));
    }).toList();

    if (filteredItems.isEmpty) {
      // Show a message if no items match the selected tags
      ScaffoldMessenger.of(originalContext).showSnackBar(
        SnackBar(
            content:
                Text('No items match the selected tags or all are picked')),
      );
      return;
    }

    // Pick a random item from the filtered list
    final randomItem = (filteredItems..shuffle()).first;

    // Mark the item as picked
    Provider.of<ItemListProvider>(originalContext, listen: false)
        .markItemPicked(list, randomItem);
    Provider.of<ItemListProvider>(originalContext, listen: false).saveLists();

    // Show the Lottie animation and picked item dialog using the stable context
    Future.delayed(Duration(milliseconds: 200), () {
      _playLottieAndShowPickedItem(originalContext, randomItem);
    });
  }

  void _showEditItemDialog(BuildContext context, Item item) {
    final TextEditingController nameController =
        TextEditingController(text: item.name);
    final TextEditingController urlController =
        TextEditingController(text: item.url);
    final TextEditingController imageUrlController =
        TextEditingController(text: item.imageUrl);
    final TextEditingController detailsController =
        TextEditingController(text: item.details);
    final TextEditingController newTagController = TextEditingController();

    List<String> tags = List.from(item.tags);
    bool isPicked = item.isPicked; // Track the picked status

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController newTagController = TextEditingController();
        List<String> tags =
            List.from(item.tags); // Clone the tags list for editing

        return AlertDialog(
          title: Text('Edit Item'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.insert_photo),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueGrey[400] ?? Colors.blueGrey,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 3.0),
                        ),
                      ),
                    ),
                    TextField(
                      controller: urlController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Item URL',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueGrey[400] ?? Colors.blueGrey,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 3.0),
                        ),
                      ),
                    ),
                    TextField(
                      controller: imageUrlController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueGrey[400] ?? Colors.blueGrey,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 3.0),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 8.0), // Adds a small gap above this field
                      child: TextField(
                        controller: detailsController,
                        maxLines: 5,
                        style: TextStyle(
                            fontSize: 14), // Smaller font for input text
                        decoration: InputDecoration(
                          labelText: 'Item Details',
                          labelStyle: TextStyle(
                              fontSize: 16), // Fixed size for label text
                          alignLabelWithHint: true, // Aligns label to the top
                          filled: true,
                          fillColor: Colors.grey[
                              200], // Light grey background for the text field
                          contentPadding: EdgeInsets.all(
                              8.0), // Uniform padding inside the box
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueGrey[400] ?? Colors.blueGrey,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 3.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Display tags as chips
                    Container(
                      width: double.infinity,
                      alignment:
                          Alignment.centerLeft, // Align chips to the left edge
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 2.0, // Horizontal space between chips
                        runSpacing: 1.0, // Vertical space between rows of chips
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(
                                  fontSize:
                                      13), // Smaller font for compact chip
                            ),
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 1.0), // Minimal padding around text
                            materialTapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // Reduce extra padding
                            backgroundColor: Colors.grey[300],
                            onDeleted: () {
                              setState(() {
                                tags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Tag input field with '+' button
                    TextField(
                      controller: newTagController,
                      decoration: InputDecoration(
                        labelText: 'Add a Tag',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (newTagController.text.isNotEmpty &&
                                !tags.contains(newTagController.text)) {
                              setState(() {
                                tags.add(
                                    newTagController.text); // Update tags list
                              });
                              newTagController.clear();
                            }
                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      child: SwitchListTile(
                        title: Text('Picked Status'),
                        value: isPicked,
                        onChanged: (value) {
                          setState(() {
                            isPicked = value;
                            if (isPicked) {
                              item.markAsPicked();
                            } else {
                              item.resetPickedStatus();
                            }
                          });
                        },
                        activeColor: Colors.blue, // Color for the active toggle
                        inactiveThumbColor: Colors.grey, // Color for the inactive toggle
                        inactiveTrackColor: Colors.grey[300], // Track color for inactive state
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            // Delete Button
            TextButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context, item);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            // Save Button
            TextButton(
              onPressed: () {
                // Update item with new values
                Provider.of<ItemListProvider>(context, listen: false)
                    .updateItem(
                  item,
                  nameController.text,
                  urlController.text,
                  imageUrlController.text,
                  detailsController.text,
                  tags,
                  // Update the details field
                );
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show the delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // Close dialog without deleting
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<ItemListProvider>(context, listen: false)
                    .deleteItem(item); // Delete the item
                Navigator.pop(context); // Close the confirmation dialog
                Navigator.pop(context); // Close the edit dialog
              },
              child: Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showViewItemDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              item.name,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.insert_photo),
                // height: 150.0, // Larger image in the info dialog
                // width: 2000.0,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              if (item.url.isNotEmpty) // Show button only if the item has a URL
                ElevatedButton(
                  onPressed: () {
                    _launchURL(item.url); // Open the URL
                  },
                  child: Text('Open URL'),
                ),
              SizedBox(height: 10),
              if (item.details.isNotEmpty) // Show details if available
                Text(
                  item.details,
                  style: TextStyle(fontSize: 16.0),
                ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  _showEditItemDialog(context, item); // Show the edit screen
                },
                child: Text('Edit'),
              ),
            ],
          ),
        );
      },
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
              leading: Icon(Icons.refresh),
              title: Text('Clear Picked Items'),
              onTap: () {
                // Reset picked statuses and notify listeners
                Provider.of<ItemListProvider>(context, listen: false)
                    .resetPickedStatus(list);

                Navigator.pop(context); // Close the menu after resetting
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
    final TextEditingController controller =
        TextEditingController(text: list.title);
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
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  // Update the list name
                  Provider.of<ItemListProvider>(context, listen: false)
                      .editListName(list, controller.text);

                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
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
          title: const Text('Delete List'),
          content: const Text('Are you sure you want to delete this list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                // Delete the list
                Provider.of<ItemListProvider>(context, listen: false).deleteList(
                    list); // Use the deleteList method // Notify the UI to refresh

                Navigator.pop(context);
                Navigator.pop(context); // Return to the previous screen
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[200],
              title: Center(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0, // You can adjust the font size as needed
                    color: Colors.black, // Set the title text color if needed
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(item.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // SizedBox(height: 5),
                  SizedBox(
                    height: 220.0, // Set the maximum height of the image
                    width: double
                        .infinity, // Let the image take the available width
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      // fit: BoxFit.cover, // Make sure the image covers the box
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Ensure the URL starts with "http://" or "https://"
                      String formattedUrl = item.url.startsWith('http')
                          ? item.url
                          : 'https://${item.url}';
                      _launchURL(formattedUrl);
                    },
                    child: Text(
                      'Open Item Link',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align buttons at the center
                  children: [
                    // Skip Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          item.resetPickedStatus();
                          final newItem = list.randomPick();
                          if (newItem != null) {
                            Provider.of<ItemListProvider>(context,
                                    listen: false)
                                .markItemPicked(list, newItem);
                            Navigator.pop(context);
                            _showPickedItemDialog(context, newItem);
                          }
                        });
                      },
                      child: Text('Skip'),
                    ),
                    SizedBox(width: 80), // Space between the buttons
                    // Close Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text('Close', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

// Function to play the Lottie animation before showing the picked item
  void _playLottieAndShowPickedItem(BuildContext context, Item item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Prevents closing until Lottie completes
      barrierColor: Colors.white, // Makes the entire screen white
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Lottie.asset(
            'assets/celebration.json',
            repeat: false, // Play only once
            onLoaded: (composition) {
              // Delay for the animation's duration
              Future.delayed(composition.duration, () {
                Navigator.pop(context); // Close the Lottie animation dialog
                _showPickedItemDialog(context, item);
                // _highlightPickedItemInList(
                //     context, item); // Highlight picked item on the list screen
              });
            },
          ),
        );
      },
    );
  }

  // Play two Lottie animations in sequence
  // void _playLottieAndShowPickedItem(BuildContext context, Item item) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Center(
  //         child: Lottie.asset(
  //           'assets/atom-loader.json', // First Lottie animation
  //           repeat: false, // Play only once
  //           onLoaded: (composition) {
  //             // Delay for the first animation's duration
  //             Future.delayed(composition.duration, () {
  //               Navigator.pop(context); // Close the first Lottie dialog

  //               // Show second Lottie animation
  //               showDialog(
  //                 context: context,
  //                 builder: (context) {
  //                   return Center(
  //                     child: Lottie.asset(
  //                       'assets/celebration.json', // Second Lottie animation
  //                       repeat: false, // Play only once
  //                       onLoaded: (composition) {
  //                         // Delay for the second animation's duration
  //                         Future.delayed(composition.duration, () {
  //                           Navigator.pop(
  //                               context); // Close the second Lottie dialog
  //                           _showPickedItemDialog(
  //                               context, item); // Show the picked item dialog
  //                         });
  //                       },
  //                     ),
  //                   );
  //                 },
  //               );
  //             });
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error launching URL: $e');
      // You can handle errors here (e.g., show a dialog or fallback option)
    }
  }
}
