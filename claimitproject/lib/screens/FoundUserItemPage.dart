import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:flutter/material.dart';

import '../backend/Search/CategoryFilterStrategy.dart';
import '../backend/Search/ColorFilterStrategy.dart';
import '../backend/Search/CompositeSearchStrategy.dart';
import '../backend/Search/LocationFilterStrategy.dart';
import '../backend/Search/SearchStrategy.dart';

class FoundUserItemPage extends StatefulWidget {
  const FoundUserItemPage({super.key});

  @override
  State<FoundUserItemPage> createState() => _FoundUserItemPageState();
}

class _FoundUserItemPageState extends State<FoundUserItemPage> {
  String? selectedCategory;
  String? selectedColor;
  String? selectedLocation;
  late List<Item> filteredItems = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                return ItemTile(
                  item: filteredItems[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void filterItems() async {
  setState(() {
    filteredItems = [];
  });

  List<SearchStrategy> strategies = [];

  if (selectedCategory != 'none' && selectedCategory != null) {
    strategies.add(CategoryFilterStrategy(selectedCategory!, 'Found'));
  }

  if (selectedColor != 'none' && selectedColor != null) {
    strategies.add(ColorFilterStrategy(selectedColor!, 'Found'));
  }

  if (selectedLocation != 'none' && selectedLocation != null) {
    strategies.add(LocationFilterStrategy(selectedLocation!, 'Found'));
  }

  if (strategies.isEmpty) {
    setState(() {
      filteredItems = [];
    });
    return;
  }

  CompositeSearchStrategy compositeStrategy =
      CompositeSearchStrategy(strategies, itemType: ItemType.Found);

  try {
    List<Item> filtered = await compositeStrategy.filterItems();

    if (mounted) {
      setState(() {
        filteredItems = filtered;
      });
     // await Future.delayed(Duration(milliseconds: 100));
    }
  } catch (e) {
    print("Error filtering items: $e");
  }
}

  
}
