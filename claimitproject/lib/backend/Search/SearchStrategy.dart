import '../Item.dart';

abstract class SearchStrategy {
  Future<List<Item>> filterItems();
  Future<List<Item>> filterItemsFromList(List<Item> items);
}
