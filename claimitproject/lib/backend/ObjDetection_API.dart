import 'package:http/http.dart' as http;
import 'dart:typed_data';

class APIService {
  APIService._();

  // Singleton instance variable
  static final APIService _instance = APIService._();

  static APIService get instance => _instance;

  Future<Uint8List> remove_bg(String image1Path) async {
    var uri = Uri.parse("http://172.20.10.5:8001/remove_background/");
    var request = http.MultipartRequest("POST", uri);

    var image1File = await http.MultipartFile.fromPath('file', image1Path);

    request.files.add(image1File);
    var streamedResponse = await request.send();

    return await streamedResponse.stream.toBytes();
  }

  Future<String> getDetected(String image1Path) async {
    var uri = Uri.parse("http://172.20.10.5:8001/get_detected/");
    var request = http.MultipartRequest("POST", uri);

    var image1File = await http.MultipartFile.fromPath('file', image1Path);

    request.files.add(image1File);

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print("Response:");
    print(responseBody);

    return responseBody;
  }
}
