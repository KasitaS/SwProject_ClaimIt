import 'dart:convert';
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
  final User? user; // Make user optional (nullable)

  const FoundUserItemPage({Key? key, this.user})
      : super(key: key); // Use optional parameter

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
    // Use a default user if none is provided
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
                    Icons.person, // Choose an icon from Material Icons
                    color: Colors.white,
                    size: 32, // Adjust size as needed
                  ),
                  SizedBox(width: 10), // Space between icon and text
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
                Icons.home, // Home icon
                color: Colors.blue, // Set the icon color to blue
              ),
              title: Text('Home Page'),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to the Home Page if needed
              },
            ),
            ListTile(
              leading: Icon(
                Icons.folder, // Choose an appropriate icon for 'My Lost Items'
                color: Colors.blue, // Set the icon color
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
                Icons.list, // List icon for Found Items
                color: Colors.blue,
              ),
              title: Text('Found Items'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout, // Logout icon
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
                // Show search bar only if filters are not being shown
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
                      showFilters = !showFilters; // Toggle filter view
                      if (showFilters) {
                        displayedItems
                            .clear(); // Clear displayed items when filtering
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
            height:
                showFilters ? 250 : 0, // Adjust height based on filter state
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
      displayedItems = []; // Clear displayed items when filtering
    });
  }

  void searchItems() async {
    if (!mounted) return;
    String searchText = searchController.text.trim().toLowerCase();

    Uri url = Uri.parse(
        'http://172.20.10.3:8000/api/get_all_found_items?name=$searchText');

    String? token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token', // Add the token to the headers
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> itemsData = jsonDecode(response.body);
      setState(() {
        displayedItems = itemsData.map((item) => Item.fromJson(item)).toList();
      });
    } else {
      setState(() {
        displayedItems = [];
      });
    }
  }

  void _logout() {
    // Implement logout functionality here, such as clearing tokens
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }
}
