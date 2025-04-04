import 'package:claimitproject/screens/AdminHomePage.dart';
import 'package:claimitproject/screens/AdminReceiveItemPage.dart';
import 'package:claimitproject/screens/FoundAdminItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:flutter/material.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/backend/Search/CategoryFilterStrategy.dart';
import 'package:claimitproject/backend/Search/ColorFilterStrategy.dart';
import 'package:claimitproject/backend/Search/CompositeSearchStrategy.dart';
import 'package:claimitproject/backend/Search/LocationFilterStrategy.dart';
import 'package:claimitproject/backend/Search/SearchStrategy.dart';

class LostItemPage extends StatefulWidget {
  const LostItemPage({super.key});

  @override
  State<LostItemPage> createState() => _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {
  String? selectedCategory;
  String? selectedColor;
  String? selectedLocation;
  List<Item> filteredItems = [];

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
  void initState() {
    super.initState();
    loadLostItems();
  }

  void loadLostItems() async {
    try {
      List<Item> lostItems = await ItemManager.fetchLostItems();
      setState(() {
        filteredItems = lostItems;
      });
    } catch (e) {
      print("Error fetching lost items: $e");
    }
  }

  void clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedColor = null;
      selectedLocation = null;
      loadLostItems();
    });
  }

  void filterItems() async {
    List<SearchStrategy> strategies = [];

    if (selectedCategory != 'none' && selectedCategory != null) {
      strategies.add(CategoryFilterStrategy(selectedCategory!, 'Lost'));
    }
    if (selectedColor != 'none' && selectedColor != null) {
      strategies.add(ColorFilterStrategy(selectedColor!, 'Lost'));
    }
    if (selectedLocation != 'none' && selectedLocation != null) {
      strategies.add(LocationFilterStrategy(selectedLocation!, 'Lost'));
    }
    if (strategies.isEmpty) {
      loadLostItems();
      return;
    }

    CompositeSearchStrategy compositeStrategy =
        CompositeSearchStrategy(strategies, itemType: ItemType.Lost);
    List<Item> filtered = await compositeStrategy.filterItems();

    setState(() {
      filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 40, color: Colors.white),
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
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text('Found Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FoundAdminItemPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.search,
                color: Colors.blue,
              ),
              title: const Text('Lost Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LostItemPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: const Text('Received Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminReceiveItemPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.blue,
              ),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginForm()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder()),
                            value: selectedCategory,
                            items: categories
                                .map((category) => DropdownMenuItem(
                                    value: category, child: Text(category)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedCategory = value),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                labelText: 'Color',
                                border: OutlineInputBorder()),
                            value: selectedColor,
                            items: colors
                                .map((color) => DropdownMenuItem(
                                    value: color, child: Text(color)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedColor = value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: 'Location', border: OutlineInputBorder()),
                      value: selectedLocation,
                      items: locations
                          .map((location) => DropdownMenuItem(
                              value: location, child: Text(location)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedLocation = value),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: filterItems,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade300),
                            child: Text('Filter'),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: clearFilters,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade300),
                            child: Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text("No items found",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        Item currentItem = filteredItems[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentItem.name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text("Category: ${currentItem.category}"),
                                Text("Color: ${currentItem.color}"),
                                Text("Location: ${currentItem.location}"),
                                Text(
                                    "Posted by: ${currentItem.owner ?? 'Unknown'}",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
