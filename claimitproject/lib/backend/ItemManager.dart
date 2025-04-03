import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemPoster.dart';
import 'package:claimitproject/backend/CallAPI.dart';
import 'EmailSender.dart';

class ItemManager extends ItemPoster {
  final String username;
  final String email;
  final String adminCode;

  ItemManager({this.username = '', this.email = '', this.adminCode = ''});

  factory ItemManager.fromJson(Map<String, dynamic> json) {
    return ItemManager(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      adminCode: json['admincode'] ?? '',
    );
  }

  Future<Map<String, int>> getItemCounts() async {
    return await CallAPI.getItemCounts();
  }

  Future<List<Item>> compareImages(Item lostItem, List<Item> foundItems) async {
    List<Item> similarItems = [];
    for (var foundItem in foundItems) {
      if (lostItem.nobg_image_path != null &&
          lostItem.nobg_image_path!.isNotEmpty &&
          foundItem.nobg_image_path != null &&
          foundItem.nobg_image_path!.isNotEmpty) {
        double similarityScore = await CallAPI.getSimilarity(
            'http://172.20.10.5:8000/api/get_image_file/?image_path=${lostItem.nobg_image_path!}',
            'http://172.20.10.5:8000/api/get_image_file/?image_path=${foundItem.nobg_image_path!}');

        if (similarityScore > 0.70) {
          similarItems.add(foundItem);
        }
      }
    }
    return similarItems;
  }

  @override
  Future<void> findSimilarityAndNotify(Item newItem) async {
    List<Item> similarItems = await CallAPI.findSimilarItems(newItem);

    if (similarItems.isNotEmpty) {
      String recipientEmail = 'user@example.com'; 
      String subject = 'Similar Lost Item Found!';
      String body = 'We found items similar to yours:\n\n';

      for (var item in similarItems) {
        body += 'Name: ${item.name}, Location: ${item.location}\n';
      }

      EmailSender emailSender = EmailSender(
          username: 'gkasita.sst@gmail.com', password: 'nrjo eoym wwit ljym');

      await emailSender.sendEmail(
          recipientEmail, subject, body, newItem.nobg_image_path!);
    }
  }

  static Future<List<Item>> fetchLostItems() async {
    return await CallAPI.fetchLostItems();
  }
}
