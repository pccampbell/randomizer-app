import 'item.dart';

class ItemList {
  String title;
  final List<Item> items;

  ItemList({required this.title, List<Item>? items})
      : items = items ?? [];  // Initialize with an empty mutable list if no list is provided

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
