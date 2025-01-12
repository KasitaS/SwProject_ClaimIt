import '../Item.dart';
import 'SearchStrategy.dart';

enum ItemType { Lost, Found }

class CompositeSearchStrategy implements SearchStrategy {
  final List<SearchStrategy> strategies;
  final ItemType itemType;

  CompositeSearchStrategy(this.strategies, {required this.itemType});

  @override
  Future<List<Item>> filterItems() async {
    // If no strategies are provided, return an empty list
    if (strategies.isEmpty) {
      return []; // Return an empty list if no strategies are applied
    }

    List<Item> items = [];

    int i = 0;
    for (var strategy in strategies) {
      if (i == 0) {
        // Get items using the first strategy
        items = await strategy.filterItems();
      } else {
        // Use the previous items and filter them through the next strategy
        items = await strategy.filterItemsFromList(items);
      }
      i++;
    }
    return items;
  }

  @override
  Future<List<Item>> filterItemsFromList(List<Item> items) async {
    for (var strategy in strategies) {
      List<Item> itemsFilteredByStrategy =
          await strategy.filterItemsFromList(items);
      items = itemsFilteredByStrategy;
    }
    return items;
  }
}
