import 'dart:convert';
import 'package:claimitproject/backend/Item.dart';
import 'package:http/http.dart' as http;
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/backend/auth_service.dart';

class CallAPI {
  static const String _mainUrl = 'http://172.20.10.5:8000/api';


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
      return {"success": false, "message": "An error occurred: ${e.toString()}"};
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
        return {"success": false, "message": "Failed to retrieve received items."};
      }
    } catch (e) {
      return {"success": false, "message": "An error occurred: ${e.toString()}"};
    }
  }

  


  

}
