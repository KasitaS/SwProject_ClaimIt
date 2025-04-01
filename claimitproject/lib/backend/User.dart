import 'dart:convert';

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:claimitproject/backend/EmailSender.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

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

/*
  @override
  Future<void> post(Item newItem) async {
    final url = Uri.parse('http://192.168.1.113:8000/api/items/');
    final token = await getToken(); // Retrieve the token

    if (token == null) {
      print('No authentication token found. Please log in again.');
      return; // Exit early if there's no token
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
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
*/
  @override
  Future<void> post(Item newItem) async {
    final url = Uri.parse('http://172.20.10.3:8000/api/items/');
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
      if (newItem.image_path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_path', newItem.image_path!,
            contentType: MediaType('image', 'jpeg'), // Adjust as necessary
          ),
        );
      }

      if (newItem.nobg_image_path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'nobg_image_path', newItem.nobg_image_path!,
            contentType: MediaType('image', 'png'), // Adjust as necessary
          ),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Item uploaded successfully');
        // Handle successful upload
      } else {
        print('Failed to upload item: ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<List<Item>> matchAndNotify(Item matchItem) async {
    final colorSimilarityUrl =
        Uri.parse('http://172.20.10.3:8001/color_similarity/');
    final imageSimilarityUrl =
        Uri.parse('http://172.20.10.3:8001/image_similarity/');
    final getFoundItemUri = Uri.parse(
        'http://172.20.10.3:8000/api/found-items/?category=${matchItem.category}');

    List<Item> matchedItems = [];

    try {
      // Fetch found items
      final response = await http.get(getFoundItemUri);
      if (response.statusCode != 200) {
        print('Failed to retrieve found items: ${response.statusCode}');
        return [];
      }

      List<Item> foundItems = (json.decode(response.body) as List)
          .map((item) => Item.fromJson(item))
          .toList();

      if (matchItem.nobg_image_path == null ||
          !File(matchItem.nobg_image_path!).existsSync()) {
        print('Skipping match item due to missing nobg_image_path.');
        return matchedItems;
      }

      // Read match item image file once
      var matchFile = await http.MultipartFile.fromPath(
          'file1', matchItem.nobg_image_path!);
      var matchFile2 = await http.MultipartFile.fromPath(
          'file1', matchItem.nobg_image_path!);

      for (var foundItem in foundItems) {
        if (foundItem.nobg_image_path == null ||
            !File(foundItem.nobg_image_path!).existsSync()) {
          print(
              'Skipping found item ${foundItem.name} due to missing nobg_image_path.');
          continue;
        }

        // Read found item image file
        var foundFile = await http.MultipartFile.fromPath(
            'file2', foundItem.nobg_image_path!);

        // Check color similarity

        var colorRequest = http.MultipartRequest("POST", colorSimilarityUrl)
          ..files.addAll([matchFile, foundFile]);
        var colorResponse = await colorRequest.send();

        if (colorResponse.statusCode != 200) {
          print(
              'Color similarity check failed for ${foundItem.name}: ${colorResponse.statusCode}');
          continue;
        }

        final colorData =
            json.decode(await colorResponse.stream.bytesToString());
        print(colorData['similarity']);
        if (colorData['similarity'] <= 0.50) {
          print(
              'Color similarity too low for ${foundItem.name}: ${colorData['similarity']}');
          continue;
        }

        var foundFile2 = await http.MultipartFile.fromPath(
            'file2', foundItem.nobg_image_path!);
        // Check image similarity
        var imageRequest = http.MultipartRequest("POST", imageSimilarityUrl)
          ..files.addAll([matchFile2, foundFile2]);
        var imageResponse = await imageRequest.send();

        if (imageResponse.statusCode != 200) {
          print(
              'Image similarity check failed for ${foundItem.name}: ${imageResponse.statusCode}');
          continue;
        }

        final imageData =
            json.decode(await imageResponse.stream.bytesToString());
        if (imageData['similarity_score'] >= 0.50) {
          print('Match found: ${foundItem.name}');
          matchedItems.add(foundItem);
        } else {
          print('It less than');
        }
      }
      return matchedItems;
    } catch (e) {
      print('Error in matchAndNotify: $e');
      return [];
    }
  }

  Future<void> sendMatchingItemEmail(String recipientEmail, Item foundItem,
      Item lostItem, String fsimilarity, String foundItemImagePath) async {
    try {
      final emailSender = EmailSender(
          username: 'gkasita.sst@gmail.com', password: 'nrjo eoym wwit ljym');

      String subject = 'Matching Item Found! Is this yours?';
      String body = 'Dear User,\n\n'
          'We have lost a matching item for your found item:\n\n'
          'Lost Item: ${lostItem.name}\n'
          'Found Item: ${foundItem.name}\n'
          'There is a high similarity Score: {$fsimilarity} between these items\n\n'
          'We have also attached the image. Please kindly check it\n\n'
          'Please contact us for further details.\n\n'
          'Regards,\n'
          'Lost and Found Team';

      await emailSender.sendEmail(
          recipientEmail, subject, body, foundItemImagePath);
    } catch (e) {
      print('Error sending matching item email: $e');
    }
  }

  Future<void> matchAndNotifyAndSendEmails(
      Item matchItem, String recipientEmail) async {
    List<Item> matchedItems = await matchAndNotify(matchItem);

    if (matchedItems.isNotEmpty) {
      for (var lostItem in matchedItems) {
        await sendMatchingItemEmail(
          recipientEmail,
          matchItem,
          lostItem,
          "High", // Example similarity score, replace with actual score if needed
          matchItem.nobg_image_path!,
        );
      }
    } else {
      print("No matching items found.");
    }
  }
}
