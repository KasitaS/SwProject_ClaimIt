import 'dart:io';
import 'package:flutter/material.dart';
import '../backend/Item.dart';
import '../backend/Search/CategoryFilterStrategy.dart';
import '../backend/Search/ColorFilterStrategy.dart';
import '../backend/Search/CompositeSearchStrategy.dart';
import '../backend/Search/LocationFilterStrategy.dart';
import '../backend/Search/SearchStrategy.dart';
import '../ui_helper/ItemTile.dart';

class RecommendLostPage extends StatefulWidget {
  final Item item;

  RecommendLostPage({required this.item});

  @override
  _RecommendLostPageState createState() => _RecommendLostPageState();
}

class _RecommendLostPageState extends State<RecommendLostPage> {
  late Item _displayedItem;
  List<Item> filteredItems = [];
  bool isLoading = true; // Track loading state
  String? errorMessage; // Track any errors

  @override
  void initState() {
    super.initState();
    _displayedItem = widget.item;
    filterItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Items'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : errorMessage != null
              ? Center(child: Text(errorMessage!)) // Display error message
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 100,
                          height: 100,
                          child: _displayedItem.imagePath != null &&
                                  File(_displayedItem.imagePath!).existsSync()
                              ? Image.file(
                                  File(_displayedItem.imagePath!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Placeholder(),
                        ),
                        title: Text(
                          _displayedItem.name ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Color: ${_displayedItem.color ?? ''}'),
                            Text('Category: ${_displayedItem.category ?? ''}'),
                            Text('Location: ${_displayedItem.location ?? ''}'),
                            Text('Description: ${_displayedItem.description ?? ''}'),
                          ],
                        ),
                      ),
                    ),
                    // Text message before filtered items
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Text(
                        'Here are found items that might match with your lost items',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Display filtered items or a message if empty
                    filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No items to display',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return ItemTile(item: filteredItems[index]);
                              },
                            ),
                          ),
                  ],
                ),
    );
  }

  void filterItems() async {
    List<SearchStrategy> strategies = [];

    if (_displayedItem.category != null && _displayedItem.category!.isNotEmpty) {
      strategies.add(CategoryFilterStrategy(_displayedItem.category!, 'Found'));
    }

    if (_displayedItem.color != null && _displayedItem.color!.isNotEmpty) {
      strategies.add(ColorFilterStrategy(_displayedItem.color!, 'Found'));
    }

    if (_displayedItem.location != null && _displayedItem.location!.isNotEmpty) {
      strategies.add(LocationFilterStrategy(_displayedItem.location!, 'Found'));
    }

    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Found);

    try {
      List<Item> filtered = await compositeStrategy.filterItems();
      setState(() {
        filteredItems = filtered;
        isLoading = false; // Set loading to false after fetching
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching items: ${e.toString()}'; // Handle errors
        isLoading = false; // Set loading to false on error
      });
    }
  }
}
