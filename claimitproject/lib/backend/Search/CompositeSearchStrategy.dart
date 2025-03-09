import '../Item.dart';
import 'SearchStrategy.dart';

enum ItemType { Lost, Found }

class CompositeSearchStrategy implements SearchStrategy {
  final List<SearchStrategy> strategies;
  final ItemType itemType;

  CompositeSearchStrategy(this.strategies, {required this.itemType});

  @override
  Future<List<Item>> filterItems() async {
    if (strategies.isEmpty) return [];

    List<Item> items = await strategies[0].filterItems();
    if (items.isEmpty) return [];

    for (var i = 1; i < strategies.length; i++) {
      items = await strategies[i].filterItemsFromList(items);
      if (items.isEmpty) return []; // Stop early
    }
    return items;
  }

  @override
  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    for (var strategy in strategies) {
      items = await strategy.filterItemsFromList(items);
      if (items.isEmpty) return [];
    }
    return items;
  }
}
