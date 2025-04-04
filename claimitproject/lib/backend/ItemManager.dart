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

  Future<List<Item>> compareImages(Item lostItem, List<Item> foundItems, String? nobg_image) async {
    List<Item> similarItems = [];
    print(foundItems.length);
    for (var foundItem in foundItems) {
      print(foundItem.nobg_image_path);
      if (foundItem.nobg_image_path?.isNotEmpty == true) {
        double similarityScore = await CallAPI.getSimilarity(
            'http://172.20.10.5:8000/api/get_image_file/?image_path=${nobg_image!}',
            'http://172.20.10.5:8000/api/get_image_file/?image_path=${foundItem.nobg_image_path!}');

        print(similarityScore);

        if (similarityScore > 0.70) {
          similarItems.add(foundItem);
        }
      }
    }
    return similarItems;
  }

  @override
  Future<void> findSimilarityAndNotify(Item newItem, String? nobg_image) async {
    List<Item> lostItems = await CallAPI.fetchLostItemsByCategoryAndLocation(newItem.category, newItem.location);
    List<Item> similarItems = await compareImages(newItem, lostItems, nobg_image);

    print(similarItems.length);
    if (similarItems.isNotEmpty) {

      for (var s in similarItems) {
        String recipientEmail = s.owner ?? 'Unknown';
        String subject = 'Someone has recently found this?';
        String body = 'Is this yours? If so, please come pick up at Lost and Found:\n\n';
        body += 'Name: ${s.name}, Location: ${s.location}\n';

        EmailSender emailSender = EmailSender(username: 'gkasita.sst@gmail.com', password: 'nrjo eoym wwit ljym');
        await emailSender.sendEmail(recipientEmail, subject, body, newItem.nobg_image_path!);
      }
    }
  }

  static Future<List<Item>> fetchLostItems() async {
    return await CallAPI.fetchLostItems();
  }
}
