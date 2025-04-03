import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> saveToken(String token, String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token); // Save the access token
  await prefs.setString(
      'refresh_token', refreshToken); // Save the refresh token
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  if (token == null) {
    return null;
  }

  bool isExpired = await isTokenExpired(token);
  if (isExpired) {
    token = await refreshAccessToken();
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

Future<String?> refreshAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refresh_token');

  if (refreshToken == null) {
    return null;
  }

  final response = await http.post(
    Uri.parse('http://172.20.10.5:8000/api/token/refresh/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'refresh': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    await saveToken(data['access'], refreshToken);
    return data['access'];
  } else {
    await removeToken();
    return null;
  }
}
