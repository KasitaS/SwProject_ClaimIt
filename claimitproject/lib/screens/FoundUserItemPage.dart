import 'dart:convert';
import 'package:claimitproject/backend/CallAPI.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/Search/CategoryFilterStrategy.dart';
import 'package:claimitproject/backend/Search/ColorFilterStrategy.dart';
import 'package:claimitproject/backend/Search/CompositeSearchStrategy.dart';
import 'package:claimitproject/backend/Search/LocationFilterStrategy.dart';
import 'package:claimitproject/backend/Search/SearchStrategy.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/MyLostItemList.dart';
import 'package:claimitproject/backend/User.dart';

class FoundUserItemPage extends StatefulWidget {
  final User? user;

  const FoundUserItemPage({Key? key, this.user}) : super(key: key);

  @override
  State<FoundUserItemPage> createState() => _FoundUserItemPageState();
}

class _FoundUserItemPageState extends State<FoundUserItemPage> {
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
    User currentUser = widget.user ??
        User(id: '0', username: 'Guest', email: 'guest@example.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 57, 41, 21),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ClaimIt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.blue,
              ),
              title: Text('Home Page'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.folder,
                color: Colors.blue,
              ),
              title: Text('My Lost Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyItemList(user: currentUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: Colors.blue,
              ),
              title: Text('Found Items'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.blue,
              ),
              title: Text('Log Out'),
              onTap: () {
                _logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                if (!showFilters)
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
                      if (showFilters) {
                        displayedItems.clear();
                      }
                    });
                  },
                ),
                if (showFilters)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Search by Filter",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showFilters ? 250 : 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedItems.isNotEmpty
                  ? displayedItems.length
                  : filteredItems.length,
              itemBuilder: (context, index) {
                return ItemTile(
                  item: displayedItems.isNotEmpty
                      ? displayedItems[index]
                      : filteredItems[index],
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
      print(selectedCategory);
    }
    if (selectedColor != 'none' && selectedColor != null) {
      strategies.add(ColorFilterStrategy(selectedColor!, 'Found'));
      print(selectedColor);
    }
    if (selectedLocation != 'none' && selectedLocation != null) {
      strategies.add(LocationFilterStrategy(selectedLocation!, 'Found'));
      print(selectedLocation);
    }
    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Found);
    List<Item> filtered = await compositeStrategy.filterItems();
    setState(() {
      filteredItems = filtered;
      displayedItems = [];
    });
  }

  void searchItems() async {
    if (!mounted) return;
    String searchText = searchController.text.trim().toLowerCase();

    List<Item> items = await CallAPI.getFoundItems(searchText);

    setState(() {
      displayedItems = items;
    });
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }
}
