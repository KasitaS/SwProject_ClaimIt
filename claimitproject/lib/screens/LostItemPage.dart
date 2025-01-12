import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/backend/Search/CategoryFilterStrategy.dart';
import 'package:claimitproject/backend/Search/ColorFilterStrategy.dart';
import 'package:claimitproject/backend/Search/CompositeSearchStrategy.dart';
import 'package:claimitproject/backend/Search/LocationFilterStrategy.dart';
import 'package:claimitproject/backend/Search/SearchStrategy.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:flutter/material.dart';

class LostItemPage extends StatefulWidget {
  const LostItemPage({super.key});

  @override
  State<LostItemPage> createState() => _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {

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
    'Others'
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              hint: Text('Category'),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: Text('Color'),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              hint: Text('Location'),
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
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                // Implement filter logic here
                filterItems();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('Filter Items'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      _showLostItemOwner(context, filteredItems[index]),
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

    if (selectedColor != 'none' &&
        selectedColor != null &&
        selectedColor!.isNotEmpty) {
      strategies.add(ColorFilterStrategy(selectedColor!, 'Lost'));
    }

    if (selectedCategory != 'none' &&
        selectedCategory != null &&
        selectedCategory!.isNotEmpty) {
      strategies.add(CategoryFilterStrategy(selectedCategory!, 'Lost'));
    }

    if (selectedLocation != 'none' &&
        selectedLocation != null &&
        selectedLocation!.isNotEmpty) {
      strategies.add(LocationFilterStrategy(selectedLocation!, 'Lost'));
    }

    // Use composite strategy to combine all selected strategies
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Lost);

    // Filter items
    List<Item> filtered = await compositeStrategy.filterItems();

    setState(() {
      filteredItems = filtered;
    });
  }

  Future<void> _showLostItemOwner(BuildContext context, Item item) async {
    try {
      ItemManager itemManager = ItemManager();
      Map<String, String>? owner = await itemManager.getLostItemOwner(item);

      if (owner != null) {
        String ownerName = owner['username'] ?? 'Unknown';
        String ownerEmail = owner['email'] ?? 'Unknown';
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Lost Item Owner'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: $ownerName'),
                  Text('Email: $ownerEmail'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Owner information not found.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error showing lost item owner dialog: $e');
    }
  }
}