import '../backend/Item.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

abstract class ItemPoster {
  Future<void> post(Item newItem) async {
    final url = Uri.parse('http://172.20.10.5:8000/api/items/');
    final token = await getToken(); // Retrieve the token

    if (token == null) {
      print('No authentication token found. Please log in again.');
      return; // Exit early if there's no token
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = "Bearer $token";

      // Ensure all required fields are added
      request.fields['name'] = newItem.name; // Add the name
      request.fields['category'] = newItem.category; // Add the category
      request.fields['color'] = newItem.color; // Add the color
      request.fields['location'] = newItem.location; // Add the location
      request.fields['item_type'] = newItem.itemType; // Add the item type
      request.fields['description'] = newItem.description;

      // Check if there's an image and add it to the request
      if (newItem.image_path != null && newItem.image_path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_path',
            newItem.image_path!,
            contentType: MediaType('image', 'jpeg'), // Adjust as necessary
          ),
        );
      }

      if (newItem.nobg_image_path != null &&
          newItem.nobg_image_path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'nobg_image_path',
            newItem.nobg_image_path!,
            contentType: MediaType('image', 'png'), // Adjust as necessary
          ),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Item uploaded successfully');
        await findSimilarityAndNotify(newItem);
        // Handle successful upload
      } else {
        print(
            'Failed to upload item: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> findSimilarityAndNotify(Item newItem);
}
