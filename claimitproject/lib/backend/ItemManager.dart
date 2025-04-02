import 'dart:convert';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:http/http.dart' as http;
import 'EmailSender.dart';

class ItemManager extends ItemPoster {
  final String username;
  final String email;
  final String adminCode;

  ItemManager({
    this.username = '', // Provide a default value if needed
    this.email = '', // Provide a default value if needed
    this.adminCode = '', // Provide a default value if needed
  });

  factory ItemManager.fromJson(Map<String, dynamic> json) {
    return ItemManager(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      adminCode: json['admincode'] ?? '',
    );
  }

  Future<void> saveMarkAsReceived(
      Item newItem, String name, String email) async {
    throw UnsupportedError('error');
  }

  Future<Map<String, String>?> getLostItemOwner(Item item) async {
    throw UnsupportedError('error');
  }

  Future<Map<String, String>?> getReceivePerson(Item item) async {
    throw UnsupportedError('error');
  }

  Future<Map<String, int>> getItemCounts() async {
    final String apiUrl = 'http://172.20.10.3:8000/api/item_counts/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'lost_count': data['lost_count'],
          'found_count': data['found_count'],
          'received_count': data['received_count']
        };
      } else {
        throw Exception('Failed to load item counts');
      }
    } catch (e) {
      print('Error fetching item counts: $e');
      return {'lost_count': 0, 'found_count': 0, 'received_count': 0};
    }
  }

  Future<List<Item>> compareImages(Item lostItem, List<Item> foundItems) async {
    List<Item> similarItems = [];

    for (var foundItem in foundItems) {
      // Check if the image path for both images is not null and not empty
      if (lostItem.nobg_image_path != null &&
          lostItem.nobg_image_path!.isNotEmpty &&
          foundItem.nobg_image_path != null &&
          foundItem.nobg_image_path!.isNotEmpty) {
        double similarityScore = await getSimilarity(
            'http://172.20.10.3:8000/api/get_image_file/?image_path=${lostItem.nobg_image_path!}', // Get image URL for lost item
            'http://172.20.10.3:8000/api/get_image_file/?image_path=${foundItem.nobg_image_path!}'); // Get image URL for found item

        if (similarityScore > 0.70) {
          similarItems.add(foundItem);
        }
      }
    }

    return similarItems; // Return the filtered items
  }

  Future<double> getSimilarity(
      String lostItemImageUrl, String foundItemImageUrl) async {
    final String fastApiUrl = 'http://172.20.10.3:8001/image_similarity/';
    try {
      // Fetch the images from the provided URLs
      var lostImageResponse = await http.get(Uri.parse(lostItemImageUrl));
      var foundImageResponse = await http.get(Uri.parse(foundItemImageUrl));

      if (lostImageResponse.statusCode == 200 &&
          foundImageResponse.statusCode == 200) {
        // Prepare the request for similarity comparison
        var request = http.MultipartRequest("POST", Uri.parse(fastApiUrl));
        request.files.add(http.MultipartFile.fromBytes(
            "file1", lostImageResponse.bodyBytes,
            filename: "lost.png"));
        request.files.add(http.MultipartFile.fromBytes(
            "file2", foundImageResponse.bodyBytes,
            filename: "found.png"));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);

        return jsonData[
            "similarity_score"]; // Assuming the response structure has similarity_score
      }
    } catch (e) {
      print("Error getting similarity: $e");
    }
    return 0.0; // Return low similarity if error occurs
  }

  @override
  Future<void> findSimilarityAndNotify(Item newItem) async {
    // Fetch lost items with the same category and location
    final String apiUrl =
        'http://172.20.10.3:8000/api/lost-items/?category=${newItem.category}&location=${newItem.location}';
    List<Item> similarItems = [];
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Item> lostItems =
            data.map((jsonItem) => Item.fromJson(jsonItem)).toList();

        // Compare images with existing lost items
        for (var lostItem in lostItems) {
          if (newItem.nobg_image_path != null &&
              newItem.nobg_image_path!.isNotEmpty &&
              lostItem.nobg_image_path != null &&
              lostItem.nobg_image_path!.isNotEmpty) {
            double similarityScore = await getSimilarity(
                'http://172.20.10.3:8000/api/get_image_file/?image_path=${newItem.nobg_image_path!}',
                'http://172.20.10.3:8000/api/get_image_file/?image_path=${lostItem.nobg_image_path!}');

            if (similarityScore > 0.70) {
              similarItems.add(lostItem); // Add to similar items list
            }
          }
        }

        // If similar items are found, send an email notification
        if (similarItems.isNotEmpty) {
          // Assuming that you have the email and username of the user
          String recipientEmail =
              'user@example.com'; // Replace with actual email
          String subject = 'Similar Lost Item Found!';
          String body = 'We found items similar to yours:\n\n';
          for (var item in similarItems) {
            body += 'Name: ${item.name}, Location: ${item.location}\n';
          }
          EmailSender emailSender = EmailSender(
              username: 'gkasita.sst@gmail.com',
              password: 'nrjo eoym wwit ljym');
          await emailSender.sendEmail(
              recipientEmail, subject, body, newItem.nobg_image_path!);
        }
      } else {
        print('Failed to fetch lost items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lost items: $e');
    }
  }
}
