import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class APIService {
  // Private constructor to prevent external instantiation
  APIService._();

  // Singleton instance variable
  static final APIService _instance = APIService._();

  // Getter to access the singleton instance
  static APIService get instance => _instance;
  /*
  Future<String> getSimilarityScore(
      String image1Path, String image2Path) async {
    var uri = Uri.parse("http://192.168.193.248:8000/get_similarity_score");
    var request = http.MultipartRequest("POST", uri);

    var image1File = await http.MultipartFile.fromPath('image1', image1Path);
    var image2File = await http.MultipartFile.fromPath('image2', image2Path);

    request.files.add(image1File);
    request.files.add(image2File);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return responseBody;
  } */
  
  Future<String> getDetected(String image1Path) async {
    var uri = Uri.parse("http://192.168.193.248:8000/get_detected");
    var request = http.MultipartRequest("POST", uri);

    var image1File = await http.MultipartFile.fromPath('image', image1Path);

    request.files.add(image1File);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print("Response:");
    print(responseBody);

    return responseBody;
  }
}
