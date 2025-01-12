import 'dart:convert';

import 'package:claimitproject/backend/EmailSender.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:http/http.dart' as http;

class ItemManager implements ItemPoster {
  final String username;
  final String email;
  final String adminCode;

  ItemManager({
    this.username = '', // Provide a default value if needed
    this.email = '',    // Provide a default value if needed
    this.adminCode = '', // Provide a default value if needed
  });

  factory ItemManager.fromJson(Map<String, dynamic> json) {
    return ItemManager(
      username: json['username'] ?? '',  
      email: json['email'] ?? '',        
      adminCode: json['admincode'] ?? '', 
    );
  }

  @override
  Future<void> post(Item newItem) async {
    // TODO: implement post
    //throw UnimplementedError();

    final url = Uri.parse('http://172.20.10.5:8000/api/items/');
    final token = await getToken(); // Retrieve the token

    if (token == null) {
      print('No authentication token found. Please log in again.');
      return; // Exit early if there's no token
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
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

  /*Future<void> matchAndNotify(Item newItem) async {
    try {
      DbHelper dbHelper = DbHelper();

      List<Item> LostItems =
          await dbHelper.getItemsByCategory(newItem.category!, 'Lost');

      for (Item lostItem in LostItems) {
        String similarityString = await APIService.instance.getSimilarityScore(
          newItem.imagePath!,
          lostItem.imagePath!,
        );
        print(similarityString);

        String formattedSimilarityString =
            similarityString.replaceAll(RegExp(r'[^\d.]+'), '');

        double similarity = double.tryParse(formattedSimilarityString) ?? 0;
        print(similarity);

        if (similarity >= 0.7) {
          print('Found a similar item: ${lostItem.name}');
          int? itemId = await dbHelper.getItemIdByAttributes(lostItem);
          String? email = await dbHelper.getEmailByItemIdFromLostTable(itemId!);

          String fsimilarity = '${(similarity * 100).toStringAsFixed(2)}%';

          await sendMatchingItemEmail(
              email!, newItem, lostItem, fsimilarity, lostItem.imagePath!);
        }
      }
    } catch (e) {
      print('Error while matching and notifying: $e');
    }
  } */

  Future<void> sendMatchingItemEmail(String recipientEmail, Item lostItem,
      Item foundItem, String fsimilarity, String foundItemImagePath) async {
    try {
      final emailSender = EmailSender(
          username: 'gkasita.sst@gmail.com', password: 'ihxy kbao jwvv yefo');

      String subject = 'Matching Item Found! Is this yours?';
      String body = 'Dear User,\n\n'
          'We have found a matching item for your lost item:\n\n'
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






}


