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
  final Map<String, dynamic>? extraData;
  final String? owner;

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
    this.extraData,
    this.owner,
  });

  // Convert JSON to Dart object
  factory Item.fromJson(Map<String, dynamic> json) {
    String baseUrl = "http://172.20.10.5:8000/";

    return Item(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      image_path:
          json['image_path'] != null && json['image_path'].startsWith('/')
              ? '$baseUrl${json['image_path']}'
              : json['image_path'] ?? '',
      itemType: json['item_type'] ?? '',
      nobg_image_path: json['nobg_image_path'] != null &&
              json['nobg_image_path'].startsWith('/')
          ? '$baseUrl${json['nobg_image_path']}'
          : json['nobg_image_path'] ?? '',
      extraData: {
        'claimer_name': json['claimer_name'] ?? 'Unknown',
        'claimer_email': json['claimer_email'] ?? 'Unknown',
      },
      owner: json['owner'] is Map<String, dynamic>
          ? json['owner']['email'] ?? 'Unknown'
          : json['owner'] ?? 'Unknown',
    );
  }

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
      'nobg_image_path': nobg_image_path,
      'owner': owner,
    };
  }
}
