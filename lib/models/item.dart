import 'package:hive/hive.dart';

part 'item.g.dart';  // This part directive is necessary for Hive code generation

@HiveType(typeId: 0)
class Item {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  bool isPicked;

  Item({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.isPicked = false,
  });

  // This method will mark the item as picked
  void markAsPicked() {
    isPicked = true;
  }

  // This method will reset the picked status
  void resetPickedStatus() {
    isPicked = false;
  }
}
