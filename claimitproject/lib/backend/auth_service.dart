import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claimitproject/backend/CallAPI.dart';

Future<void> saveToken(String token, String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
  await prefs.setString('refresh_token', refreshToken);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  if (token == null) return null;

  bool isExpired = await isTokenExpired(token);
  if (isExpired) {
    token = await CallAPI.refreshAccessToken();
  }

  return token;
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
  await prefs.remove('refresh_token');
}

Future<bool> isTokenExpired(String token) async {
  try {
    final payload = json.decode(
        utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))));
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    return expiry.isBefore(DateTime.now());
  } catch (e) {
    return true;
  }
}
