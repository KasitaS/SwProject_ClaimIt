class Item {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String location;
  final String description;
  final String? image_path;
  final String itemType;
  final String? nobg_image_path;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.location,
    required this.description,
    this.image_path,
    required this.itemType,
    this.nobg_image_path,
  });

  // Convert JSON to Dart object
  factory Item.fromJson(Map<String, dynamic> json) {
    String baseUrl =
        "http://172.20.10.3:8000/"; // Change to your actual API URL if different

    return Item(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      image_path: json['image_path'] != null &&
              json['image_path'].startsWith('/')
          ? '$baseUrl${json['image_path']}' // Add base URL for relative paths
          : json['image_path'] ?? '',
      itemType: json['item_type'] ?? '',
      nobg_image_path: json['nobg_image_path'] != null &&
              json['nobg_image_path'].startsWith('/')
          ? '$baseUrl${json['nobg_image_path']}' // Add base URL for relative paths
          : json['nobg_image_path'] ?? '',
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'location': location,
      'description': description,
      'image_path': image_path,
      'item_type': itemType,
      'nobg_image_path': nobg_image_path
    };
  }
}
