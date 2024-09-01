import 'package:hive/hive.dart';
import 'item.dart';

part 'item_list.g.dart';  // This part directive is necessary for Hive code generation

@HiveType(typeId: 1)  // Ensure the typeId is unique across all your Hive types
class ItemList {
  @HiveField(0)
  String title;

  @HiveField(1)
  final List<Item> items;

  ItemList({required this.title, List<Item>? items})
      : items = items ?? [];  // Initialize with an empty mutable list if no list is provided

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Implement fromJson to load data back
  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      title: json['title'],
      items: (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }

  // Method to add an item to the list
  void addItem(Item item) {
    items.add(item);
  }

  // Method to mark an item as picked
  void markItemPicked(Item item) {
    final index = items.indexOf(item);
    if (index != -1) {
      items[index].markAsPicked();
    }
  }

  // Method to reset the picked status of all items
  void resetAllItems() {
    for (var item in items) {
      item.resetPickedStatus();
    }
  }

  // Method to pick a random unpicked item
  Item? randomPick() {
    final unpickedItems = items.where((item) => !item.isPicked).toList();
    if (unpickedItems.isNotEmpty) {
      final randomItem = (unpickedItems..shuffle()).first;
      markItemPicked(randomItem);
      return randomItem;
    }
    return null;
  }
}
