import 'package:shared_preferences/shared_preferences.dart';


Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);  // Save the token with key 'jwt_token'
}


Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');  // Retrieve the token with key 'jwt_token'
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');  // Remove the token stored with key 'jwt_token'
}


