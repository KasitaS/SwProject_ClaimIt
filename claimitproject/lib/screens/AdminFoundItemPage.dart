import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/Search/CategoryFilterStrategy.dart';
import 'package:claimitproject/backend/Search/ColorFilterStrategy.dart';
import 'package:claimitproject/backend/Search/CompositeSearchStrategy.dart';
import 'package:claimitproject/backend/Search/LocationFilterStrategy.dart';
import 'package:claimitproject/backend/Search/SearchStrategy.dart';
import 'package:claimitproject/screens/DetailedItemView.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:flutter/material.dart';

class FoundAdminItemPage extends StatefulWidget {
  const FoundAdminItemPage({super.key});

  @override
  State<FoundAdminItemPage> createState() => _FoundAdminItemPageState();
}

class _FoundAdminItemPageState extends State<FoundAdminItemPage> {

  String? selectedCategory;
  String? selectedColor;
  String? selectedLocation;
  late List<Item> filteredItems = []; // Initialize with an empty list

  final List<String> categories = [
    'none',
    'IT Gadget',
    'Stationary',
    'Personal Belonging',
    'Bag',
    'Others'
  ];
  final List<String> colors = [
    'none',
    'Red',
    'Green',
    'Blue',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Gray',
    'Other'
  ];
  final List<String> locations = [
    'none',
    'HM Building',
    'ECC Building',
    'Engineering Faculty',
    'Architect Faculty',
    'Science Faculty',
    'Business Faculty',
    'Art Faculty',
    'Others'
  ];

@override
void initState() {
  super.initState();
  filterItems();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              hint: const Text('Category'),
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: const Text('Color'),
              value: selectedColor,
              items: colors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: const Text('Location'),
              value: selectedLocation,
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // Implement filter logic here
                filterItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Filter Items'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedItemView(
                          item: filteredItems[index],
                        ),
                      ),
                    );
                  },
                  child: ItemTile(item: filteredItems[index]),
                );
              },
            ),
          ), 
        ],
      ),
    );
  }

  void filterItems() async {
    // Create your search strategies based on selected criteria
    List<SearchStrategy> strategies = [];

    if (selectedCategory != 'none' &&
        selectedCategory != null &&
        selectedCategory!.isNotEmpty) {
      strategies.add(CategoryFilterStrategy(selectedCategory!, 'Found'));
    }

    if (selectedColor != 'none' &&
        selectedColor != null &&
        selectedColor!.isNotEmpty) {
      strategies.add(ColorFilterStrategy(selectedColor!, 'Found'));
    }

    if (selectedLocation != 'none' &&
        selectedLocation != null &&
        selectedLocation!.isNotEmpty) {
      strategies.add(LocationFilterStrategy(selectedLocation!, 'Found'));
    }

    // Use composite strategy to combine all selected strategies
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Found);

    // Filter items
    List<Item> filtered = await compositeStrategy.filterItems();

    setState(() {
      filteredItems = filtered;
    });
  }
}