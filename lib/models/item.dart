import 'package:hive/hive.dart';

part 'item.g.dart'; // This part directive is necessary for Hive code generation

@HiveType(typeId: 0)
class Item {
  @HiveField(0)
  String name;

  @HiveField(1)
  String url;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  bool isPicked;

  Item({
    required this.name,
    this.url = '',
    this.imageUrl = '',
    this.isPicked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'isPicked': isPicked,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isPicked: json['isPicked'] ?? false,
    );
  }

  // This method will mark the item as picked
  void markAsPicked() {
    isPicked = true;
  }

  // This method will reset the picked status
  void resetPickedStatus() {
    isPicked = false;
  }
}
