import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class User extends ItemPoster {
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

  Future<void> findSimilarityAndNotify(Item newItem) {
    throw UnimplementedError(
        'findSimilarityAndNotify() has not been implemented.');
  }
}
