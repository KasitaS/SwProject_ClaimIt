import 'dart:convert';
import 'package:claimitproject/backend/Item.dart';
some import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallAPI {
  static const String _mainUrl = 'http://172.20.10.5:8000/api';
  static const String fastApiUrl = 'http://172.20.10.5:8001';
  static const String image_sim_ApiUrl =
      'http://172.20.10.5:8001/image_similarity/';

  bool _isLoading = false;

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$_mainUrl/login/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access'];
        final String refresh = data['refresh'];
        final String username = data['username'];

        if (token.isNotEmpty && username.isNotEmpty) {
          await saveToken(token, refresh);
          return {"success": true, "user": User(username: username)};
        } else {
          return {
            "success": false,
            "message": "Login successful, but missing essential data."
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ??
              "Login failed. Please check your credentials."
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}."
      };
    }
  }

  static Future<Map<String, dynamic>> signUp(
      String username, String email, String password) async {
    var url = Uri.parse('$_mainUrl/register/');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "message": "Signup successful"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)["error"] ?? "Signup failed"
      };
    }
  }

  static Future<Map<String, dynamic>> verifyAdminCode(String adminCode) async {
    final url = Uri.parse('$_mainUrl/verify_admin_code/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"admincode": adminCode}),
      );

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {"success": false, "message": "Incorrect Verification Code"};
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> fetchReceivedItems() async {
    final Uri url = Uri.parse('$_mainUrl/received_items/');

    try {
      final token = await getToken(); // Fetch token from auth service
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<Item> items = (json.decode(response.body) as List)
            .map((item) => Item.fromJson(item))
            .toList();
        return {"success": true, "items": items};
      } else {
        return {
          "success": false,
          "message": "Failed to retrieve received items."
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}"
      };
    }
  }

  static Future<Map<String, dynamic>> fetchFoundItems(
      String searchQuery) async {
    final Uri url =
        Uri.parse('$_mainUrl/get_all_found_items?name=${searchQuery.trim()}');

    try {
      final token = await getToken(); // Fetch token from auth service
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<Item> items = (json.decode(response.body) as List)
            .map((item) => Item.fromJson(item))
            .toList();
        return {"success": true, "items": items};
      } else {
        return {"success": false, "message": "Failed to retrieve found items."};
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}"
      };
    }
  }

  static Future<List<Item>> getFoundItems(String searchText) async {
    Uri url = Uri.parse('$_mainUrl/get_all_found_items?name=$searchText');

    String? token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token', // Add the token to the headers
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> itemsData = jsonDecode(response.body);
      return itemsData.map((item) => Item.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  static Future<List<Item>> getUserLostItems(String username) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Session expired. Please log in again.');
    }

    try {
      final url = Uri.parse('$_mainUrl/user-lost-items/$username/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Item.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        await removeToken();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<void> deleteItem(Item item) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Session expired. Please log in again.');
    }

    try {
      final url = Uri.parse('$_mainUrl/delete_item/');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': item.name,
          'category': item.category,
          'color': item.color,
          'location': item.location,
          'description': item.description,
          'item_type': item.itemType,
        }),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<List<Item>> fetchLostItems() async {
    try {
      final response = await http.get(Uri.parse('$_mainUrl/lost-items/'));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((item) => Item.fromJson(item))
            .toList();
      } else {
        print('Failed to retrieve lost items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching lost items: $e');
      return [];
    }
  }

  static Future<List<Item>> fetchRecommendedItems(Item item) async {
    final requestUri = Uri.parse(
        '$_mainUrl/found-items/?category=${item.category}&location=${item.location}');

    try {
      final response = await http.get(requestUri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => Item.fromJson(jsonItem)).toList();
      } else {
        throw Exception('Failed to fetch recommended items');
      }
    } catch (e) {
      throw Exception('Error fetching recommended items: $e');
    }
  }

  static Future<double> getImageSimilarity(
      String lostItemImageUrl, String foundItemImageUrl) async {
    try {
      var lostImageResponse = await http.get(Uri.parse(lostItemImageUrl));
      var foundImageResponse = await http.get(Uri.parse(foundItemImageUrl));

      if (lostImageResponse.statusCode == 200 &&
          foundImageResponse.statusCode == 200) {
        var request =
            http.MultipartRequest("POST", Uri.parse(image_sim_ApiUrl));
        request.files.add(http.MultipartFile.fromBytes(
            "file1", lostImageResponse.bodyBytes,
            filename: "lost.png"));
        request.files.add(http.MultipartFile.fromBytes(
            "file2", foundImageResponse.bodyBytes,
            filename: "found.png"));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);

        return jsonData["similarity_score"][0];
      } else {
        throw Exception('Error fetching image data for similarity');
      }
    } catch (e) {
      throw Exception('Error calculating image similarity: $e');
    }
  }

  static Future<void> updateItemReceived(int? itemId, String claimerName, String claimerEmail) async {
  Uri url = Uri.parse('$_mainUrl/update_item_received/$itemId/');
  String? token = await getToken();
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json'
  };
  
  
  final body = jsonEncode({
    'item_type': 'Received',
    'claimer_name': claimerName,
    'claimer_email': claimerEmail
  });

  final response = await http.put(url, headers: headers, body: body);
  if (response.statusCode != 200) {
    throw Exception('Failed to update item');
  }
}


  static Future<List<Item>> fetch_FoundItems(String searchText) async {
    Uri url = Uri.parse('$_mainUrl/get_all_found_items?name=$searchText');
    String? token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> itemsData = jsonDecode(response.body);
      return itemsData.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<Map<String, int>> getItemCounts() async {
    final String apiUrl = '$_mainUrl/item_counts/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'lost_count': data['lost_count'],
          'found_count': data['found_count'],
          'received_count': data['received_count']
        };
      } else {
        throw Exception('Failed to load item counts');
      }
    } catch (e) {
      print('Error fetching item counts: $e');
      return {'lost_count': 0, 'found_count': 0, 'received_count': 0};
    }
  }

  static Future<double> getSimilarity(
      String lostItemImageUrl, String foundItemImageUrl) async {
    try {
      var lostImageResponse = await http.get(Uri.parse(lostItemImageUrl));
      var foundImageResponse = await http.get(Uri.parse(foundItemImageUrl));

      if (lostImageResponse.statusCode == 200 &&
          foundImageResponse.statusCode == 200) {
        var request = http.MultipartRequest(
            "POST", Uri.parse('http://172.20.10.5:8001/image_similarity/'));
        request.files.add(http.MultipartFile.fromBytes(
            "file1", lostImageResponse.bodyBytes,
            filename: "lost.png"));
        request.files.add(http.MultipartFile.fromBytes(
            "file2", foundImageResponse.bodyBytes,
            filename: "found.png"));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);

        return jsonData["similarity_score"][0];
      }
    } catch (e) {
      print("Error getting similarity: $e");
    }
    return 0.0;
  }

  static Future<List<Item>> fetchLostItemsByCategoryAndLocation(
      String category, String location) async {
    final response = await http.get(
        Uri.parse('$_mainUrl/lost-items/?category=$category&location=$location'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => Item.fromJson(jsonItem)).toList();
    }
    throw Exception('Failed to fetch lost items by category and location');
  }

  static Future<String?> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$_mainUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['access'], refreshToken);
      return data['access'];
    } else {
      await _removeToken();
      return null;
    }
  }

  static Future<void> _saveToken(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('refresh_token');
  }
}
