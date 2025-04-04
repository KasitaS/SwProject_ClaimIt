import '../backend/Item.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

abstract class ItemPoster {
  Future<void> post(Item newItem) async {
    final url = Uri.parse('http://172.20.10.5:8000/api/items/');
    final token = await getToken(); 

    if (token == null) {
      print('No authentication token found. Please log in again.');
      return; 
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = "Bearer $token";

      request.fields['name'] = newItem.name; 
      request.fields['category'] = newItem.category; 
      request.fields['color'] = newItem.color; 
      request.fields['location'] = newItem.location; 
      request.fields['item_type'] = newItem.itemType; 
      request.fields['description'] = newItem.description;

      if (newItem.image_path != null && newItem.image_path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_path',
            newItem.image_path!,
            contentType: MediaType('image', 'jpeg'), 
          ),
        );
      }

      if (newItem.nobg_image_path != null &&
          newItem.nobg_image_path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'nobg_image_path',
            newItem.nobg_image_path!,
            contentType: MediaType('image', 'png'), 
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Item uploaded successfully');
        final responseData = json.decode(response.body);
        await findSimilarityAndNotify(
          newItem,
          responseData['nobg_image_filename'],
        );
      } else {
        print(
            'Failed to upload item: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> findSimilarityAndNotify(Item newItem, String? nobg_image_path);
}