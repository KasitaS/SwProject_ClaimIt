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
import 'package:claimitproject/screens/AdminHomePage.dart';
import 'package:claimitproject/screens/LostItemPage.dart';
import 'package:claimitproject/screens/AdminReceiveItemPage.dart';
import 'package:claimitproject/backend/User.dart';

class FoundAdminItemPage extends StatefulWidget {
  final User? user;

  const FoundAdminItemPage({Key? key, this.user}) : super(key: key);

  @override
  State<FoundAdminItemPage> createState() => _FoundAdminItemPageState();
}

class _FoundAdminItemPageState extends State<FoundAdminItemPage> {
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

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

  void _navigateToLostItems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LostItemPage()),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminHome()),
    );
  }

  void _navigateToReceiveList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminReceiveItemPage()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown.shade700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard',
              () => _navigateToDashboard(context)),
          _buildDrawerItem(
              Icons.list, 'Found Items', () => Navigator.pop(context)),
          _buildDrawerItem(
              Icons.search, 'Lost Items', () => _navigateToLostItems(context)),
          _buildDrawerItem(Icons.check_circle, 'Received Items',
              () => _navigateToReceiveList(context)),
          Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    User currentUser = widget.user ??
        User(id: '0', username: 'Guest', email: 'guest@example.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      drawer: _buildDrawer(),
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
                    padding: const EdgeInsets.only(left: 8),
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
                    _buildDropdown('Category', selectedCategory, categories,
                        (value) => setState(() => selectedCategory = value)),
                    _buildDropdown('Color', selectedColor, colors,
                        (value) => setState(() => selectedColor = value)),
                    _buildDropdown('Location', selectedLocation, locations,
                        (value) => setState(() => selectedLocation = value)),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: ElevatedButton(
                        onPressed: filterItems,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
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

  Widget _buildDropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        hint: Text(hint),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
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
      displayedItems.clear();
    });
  }

  void searchItems() async {
    Uri url = Uri.parse(
        'http://172.20.10.3:8000/api/get_all_found_items?name=${searchController.text.trim()}');
    String? token = await getToken();
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      setState(() {
        displayedItems = (jsonDecode(response.body) as List)
            .map((item) => Item.fromJson(item))
            .toList();
      });
    } else {
      setState(() {
        displayedItems = [];
      });
    }
  }
}
