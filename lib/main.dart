import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/item_list.dart';
import 'models/item.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and specify a directory for storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Registering adapters for custom objects
  Hive.registerAdapter(ItemListAdapter());
  Hive.registerAdapter(ItemAdapter());

  // Open Hive box
  await Hive.openBox('itemBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemListProvider(),
      child: MaterialApp(
        title: 'Item Randomizer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
          appBarTheme: AppBarTheme(
            backgroundColor:
                Colors.blueGrey, // Apply the primary color to the app bar
            foregroundColor: Colors.white, // Text/icon color in the app bar
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors
                  .blueGrey, // Apply the primary color to elevated buttons
              foregroundColor: Colors.white, // Text color on the buttons
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              backgroundColor:
                  Colors.blueGrey, // Apply the primary color to text buttons
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors
                  .blueGrey, // Apply the primary color to outlined buttons
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class ItemListProvider with ChangeNotifier {
  List<ItemList> _lists = [];
  final Box box = Hive.box('itemBox');

  List<ItemList> get lists => _lists;

  ItemListProvider() {
    loadLists();
  }

  void addList(ItemList list) {
    _lists.add(list);
    saveLists();
    notifyListeners();
  }

  void addItemToList(ItemList list, Item item) {
    list.items.add(item);
    saveLists();
    notifyListeners();
  }

  void updateItem(
      Item item, String newName, String newUrl, String newImageUrl,
      String newDetails) {
    item.name = newName;
    item.url = newUrl;
    item.imageUrl = newImageUrl;
    item.details = newDetails;
    saveLists(); // Save the updated state to Hive or other storage
    notifyListeners(); // Notify listeners to update the UI
  }

  void deleteItem(Item item) {
    for (var list in _lists) {
      if (list.items.contains(item)) {
        list.items.remove(item); // Remove item from the list
        saveLists(); // Save the updated list to Hive
        notifyListeners(); // Notify listeners to update UI
        break;
      }
    }
  }

  void markItemPicked(ItemList list, Item item) {
    final index = list.items.indexOf(item);
    if (index != -1) {
      list.items[index].isPicked = true;
      saveLists();
      notifyListeners();
    }
  }

  void resetPickedStatus(ItemList list) {
    list.resetAllItems(); // Call the method to reset picked status of all items
    saveLists(); // Save the updated state to Hive or other storage
    notifyListeners(); // Notify listeners to update the UI
  }

  void deleteList(ItemList list) {
    _lists.remove(list);
    saveLists();
    notifyListeners();
  }

  void editListName(ItemList list, String newName) {
    list.title = newName;
    saveLists();
    notifyListeners();
  }

  Future<void> loadLists() async {
    final loadedLists = box.get('lists', defaultValue: <ItemList>[]);
    _lists = List<ItemList>.from(loadedLists);
  }

  void saveLists() {
    box.put('lists', _lists);
  }
}
