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
  String details;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  bool isPicked;

    Item({
    required this.name,
    this.url = '',
    this.imageUrl = '',
    this.details = '',
    this.tags = const <String>[], 
    this.isPicked = false,
  });

  // Update toJson and fromJson methods to include tags
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'details': details,
      'tags': tags,
      'isPicked': isPicked,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      details: json['details'] ?? '',
      tags: List<String>.from(json['tags'] ?? []), // Parse tags as List<String>
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
