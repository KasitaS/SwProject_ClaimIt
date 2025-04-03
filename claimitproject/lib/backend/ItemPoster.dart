import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/CallAPI.dart';

abstract class ItemPoster {
  Future<void> post(Item newItem) async {
    await CallAPI.postItem(newItem);
  }

  Future<void> findSimilarityAndNotify(Item newItem) async {
    await CallAPI.findSimilarityAndNotify(newItem);
  }
}
