import 'dart:convert';

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User implements ItemPoster {
  final String id;
  final String username;
  final String email;

  User({
    this.id = '', 
    this.username = '',
    this.email = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Handle null values
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }

  @override
  Future<void> post(Item newItem) async {
    final url = Uri.parse('http://172.20.10.5:8000/api/items/');
    final token = await getToken(); // Retrieve the token

    if (token == null) {
      print('No authentication token found. Please log in again.');
      return; // Exit early if there's no token
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(newItem.toJson()),
      );

      if (response.statusCode == 201) {
        print('Item uploaded successfully');
      } else {
        print('Failed to upload item: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }
}
