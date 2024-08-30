class Item {
  final String name;
  final String url;
  final String imageUrl;
  bool isPicked;

  Item({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.isPicked = false,
  });

  void markAsPicked() {
    isPicked = true;
  }

  void resetPickedStatus() {
    isPicked = false;
  }
}
