import 'dart:convert';
import '../Item.dart';
import 'SearchStrategy.dart';
import 'package:http/http.dart' as http;
import '../auth_service.dart';  // Make sure to import your auth-service.dart

class ColorFilterStrategy implements SearchStrategy {
  final String color;
  final String itemType; // This should still be here
  final List<Item>? itemsToFilter;

  ColorFilterStrategy(this.color, this.itemType, {this.itemsToFilter});

  @override
  Future<List<Item>> filterItems() async {
    // Construct the URL with query parameters
      String endpoint = itemType == 'Lost' ? 'lost-items' : 'found-items';
      Uri url = Uri.parse('http://172.20.10.5:8000/api/$endpoint/?color=$color&item_type=$itemType');

    // Retrieve the token
    String? token = await getToken();

    // Set up headers for the request
    final headers = {
      'Authorization': 'Bearer $token',  // Add the token to the headers
      'Content-Type': 'application/json', // Specify content type
    };

    // Make the HTTP GET request with headers
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> data = json.decode(response.body);
      List<Item> filteredItems = data.map((jsonItem) => Item.fromJson(jsonItem)).toList();
      return filteredItems;
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    return items.where((item) => item.color == color && item.itemType == itemType).toList();
  }
}
