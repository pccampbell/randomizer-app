import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/item_list.dart';
import 'models/item.dart';  
import 'screens/home_screen.dart';


void main() {
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
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class ItemListProvider with ChangeNotifier {
  List<ItemList> _lists = [];

  List<ItemList> get lists => _lists;

  void addList(ItemList list) {
    _lists.add(list);
    notifyListeners();
  }

  void addItemToList(ItemList list, Item item) {
    list.addItem(item);
    notifyListeners();
  }

  void markItemPicked(ItemList list, Item item) {
    list.markItemPicked(item);
    notifyListeners();
  }
}
