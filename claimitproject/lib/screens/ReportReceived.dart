import 'dart:convert';

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/Search/CategoryFilterStrategy.dart';
import 'package:claimitproject/backend/Search/ColorFilterStrategy.dart';
import 'package:claimitproject/backend/Search/CompositeSearchStrategy.dart';
import 'package:claimitproject/backend/Search/LocationFilterStrategy.dart';
import 'package:claimitproject/backend/Search/SearchStrategy.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportReceived extends StatefulWidget {
  const ReportReceived({super.key});

  @override
  State<ReportReceived> createState() => _ReportReceivedState();
}

class _ReportReceivedState extends State<ReportReceived> {
  String? selectedCategory;
  String? selectedColor;
  String? selectedLocation;
  late List<Item> filteredItems = [];
  late List<Item> displayedItems = [];
  bool showFilters = false;
  final TextEditingController searchController = TextEditingController();

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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      searchItems();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                      showFilters ? Icons.filter_list_off : Icons.filter_list),
                  onPressed: () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  },
                ),
              ],
            ),
          ),
          if (showFilters) ...[
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
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: ElevatedButton(
                onPressed: filterItems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Filter Items'),
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: displayedItems.isNotEmpty
                  ? displayedItems.length
                  : filteredItems.length,
              itemBuilder: (context, index) {
                Item item = displayedItems.isNotEmpty
                    ? displayedItems[index]
                    : filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Category: ${item.category}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      showReceiveDialog(item);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Receive"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterItems() async {
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
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Found);
    List<Item> filtered = await compositeStrategy.filterItems();
    setState(() {
      filteredItems = filtered;
    });
  }

  void searchItems() async {
    String searchText = searchController.text.trim().toLowerCase();

    Uri url = Uri.parse(
        'http://192.168.1.128:8000/api/get_all_found_items?name=$searchText');

    String? token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token', // Add the token to the headers
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      print("Response: ${response.body}");
      List<dynamic> itemsData = jsonDecode(response.body);
      setState(() {
        displayedItems = itemsData.map((item) {
          print("Item JSON: $item"); // ✅ Print each item before conversion
          return Item.fromJson(item);
        }).toList();
      });
    } else {
      setState(() {
        displayedItems = [];
      });
    }
  }

  void showReceiveDialog(Item item) {
    TextEditingController ownerNameController = TextEditingController();
    TextEditingController ownerEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Item Received"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Item: ${item.name}"),
              TextField(
                controller: ownerNameController,
                decoration: InputDecoration(labelText: "Owner Name"),
              ),
              TextField(
                controller: ownerEmailController,
                decoration: InputDecoration(labelText: "Owner Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                updateItemReceived(
                    item, ownerNameController.text, ownerEmailController.text);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void updateItemReceived(
      Item item, String ownerName, String ownerEmail) async {
    if (item.id == null) {
      print(
          "Error: Item ID is null, cannot update. Item details: ${item.toJson()}");
      return;
    }

    Uri url = Uri.parse(
        'http://192.168.1.128:8000/api/update_item_received/${item.id}/');

    String? token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'owner_name': ownerName,
      'owner_email': ownerEmail,
      'item_type': 'Received',
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        displayedItems.remove(item);
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item marked as received!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update item')));
    }
  }
}
