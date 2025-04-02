import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/screens/RecommendLost.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart'; // Import the FoundItemsPage
import 'package:claimitproject/screens/LoginForm.dart'; // Import LoginForm
import 'package:claimitproject/screens/NewHomePage.dart'; // Import NewHomePage
import 'package:claimitproject/screens/MyLostItemList.dart'; // Import My Lost Item List
import '../ui_helper/ItemTileD.dart';

class MyItemList extends StatefulWidget {
  final User user;

  const MyItemList({Key? key, required this.user}) : super(key: key);

  @override
  State<MyItemList> createState() => _MyItemListState();
}

class _MyItemListState extends State<MyItemList> {
  List<Item> itemList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLostItems();
  }

  Future<void> fetchLostItems() async {
    String? token = await getToken();

    if (token == null) {
      setState(() {
        errorMessage = 'Session expired. Please log in again.';
        isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse(
          'http://172.20.10.3:8000/api/user-lost-items/${widget.user.username}/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('API response: $data');

        List<Item> loadedItems =
            data.map((item) => Item.fromJson(item)).toList();

        for (var item in loadedItems) {
          print('Item loaded:');
          print('Name: ${item.name}');
          print('Category: ${item.category}');
          print('Color: ${item.color}');
          print('Location: ${item.location}');
          print('Description: ${item.description}');
          print('Image Path: ${item.image_path}');
          print('No Background Image Path: ${item.nobg_image_path}');
        }

        setState(() {
          itemList = loadedItems;
          isLoading = false;
        });
        print('Items loaded successfully, count: ${itemList.length}');
      } else if (response.statusCode == 401) {
        await removeToken();
        setState(() {
          errorMessage = 'Session expired. Please log in again';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load items: ${response.statusCode} ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(Item item, int index) async {
    String? token = await getToken();

    if (token == null) {
      setState(() {
        errorMessage = 'Session expired. Please log in again.';
      });
      return;
    }

    try {
      final url = Uri.parse('http://172.20.10.3:8000/api/delete_item/');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': item.name,
          'category': item.category,
          'color': item.color,
          'location': item.location,
          'description': item.description,
          'item_type': item.itemType,
        }),
      );

      if (response.statusCode == 204) {
        // Successfully deleted from the server, now remove from UI
        setState(() {
          itemList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Item not found.';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to delete item: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
        title: const Text('My Lost Items'),
        elevation: 0,
        // Remove the leading property to eliminate the back button
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewHomePage(user: widget.user),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoundUserItemPage(user: widget.user),
                  ),
                );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : itemList.isEmpty
                  ? const Center(
                      child: Text(
                        'No items to display',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        itemCount: itemList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecommendLostPage(item: itemList[index]),
                                ),
                              );
                            },
                            child: ItemTileD(
                              item: itemList[index],
                              deleteFunction: (context) =>
                                  deleteItem(itemList[index], index),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _logout() {
    // Log out logic, e.g., clearing token
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }
}
