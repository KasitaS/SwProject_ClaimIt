import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/backend/auth_service.dart';

class CallAPI {
  static const String _loginUrl = 'http://10.0.2.2:8000/api';
  static const String _signupUrl = 'http://10.0.2.2:8000/api';


  bool _isLoading = false;


  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_loginUrl/login/');

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
          return {"success": false, "message": "Login successful, but missing essential data."};
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['detail'] ?? "Login failed. Please check your credentials."
        };
      }
    } catch (e) {
      return {"success": false, "message": "An error occurred: ${e.toString()}."};
    }
  }

  static Future<Map<String, dynamic>> signUp(
      String username, String email, String password) async {
    var url = Uri.parse('$_signupUrl/register/');
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
 
}

