import 'dart:convert';
import '../Item.dart';
import 'SearchStrategy.dart';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class CategoryFilterStrategy implements SearchStrategy {
  final String category;
  final String itemType;
  final List<Item>? itemsToFilter;

  CategoryFilterStrategy(this.category, this.itemType, {this.itemsToFilter});

  @override
  Future<List<Item>> filterItems() async {
    String endpoint = itemType == 'Lost' ? 'lost-items_filter' : 'found-items';
    Uri url = Uri.parse(
        'http://172.20.10.5:8000/api/$endpoint/?category=$category&item_type=$itemType');

    String? token = await getToken();

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Item> filteredItems =
          data.map((jsonItem) => Item.fromJson(jsonItem)).toList();

      if (filteredItems.isEmpty) {
        print("No items to display.");
      }
      return filteredItems;
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    return items
        .where((item) => item.category == category && item.itemType == itemType)
        .toList();
  }
}
