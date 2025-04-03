import 'dart:convert';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/ui_helper/ItemTileP.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/MyLostItemList.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart'; // Import the FoundItemsPage
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewHomePage extends StatefulWidget {
  final User user;

  const NewHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  List<Item> lostItems = [];
  final Uri getLostItemUri =
      Uri.parse('http://172.20.10.5:8000/api/lost-items/');
  bool itemsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchLostItems();
  }

  Future<void> fetchLostItems() async {
    try {
      final response = await http.get(getLostItemUri);
      if (response.statusCode == 200) {
        setState(() {
          lostItems = (json.decode(response.body) as List)
              .map((item) => Item.fromJson(item))
              .toList();
          itemsFetched = true;
        });

        // Print all loaded items for debugging
        for (var item in lostItems) {
          print("Loaded Item: ");
          print("Name: ${item.name}");
          print("Image Path: ${item.image_path}");
          print("Color: ${item.color}");
          print("Category: ${item.category}");
          print("Location: ${item.location}");
          print("Description: ${item.description}");
          print("--------------------"); // Separator for clarity
        }
      } else {
        print('Failed to retrieve lost items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lost items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ClaimIt'),
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
                    builder: (context) => MyItemList(user: widget.user),
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
      body: Container(
        color: Color.fromARGB(255, 183, 163, 139),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              // Centering the logo and greeting text
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/main_logo.png', // Load the logo from assets
                    width: 100, // Set desired width for the logo
                    height: 100, // Set desired height for the logo
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Hi, ${widget.user.username}\nWelcome to ClaimIt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Align(
                              alignment: Alignment.centerLeft, // Left alignment
                              child: Text(
                                'Have you seen this?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: itemsFetched
                                ? (lostItems.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No lost items reported.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: lostItems.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () => _showLostItemOwner(
                                                context, lostItems[index]),
                                            child: ItemTileP(
                                                item: lostItems[index]),
                                          );
                                        },
                                      ))
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  UploadForm(itemPoster: widget.user),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Slide from right
                const end = Offset.zero; // Slide to the center
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 57, 41, 21),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

  Future<void> _showLostItemOwner(BuildContext context, Item item) async {
    try {
      ItemManager itemManager = ItemManager();
      Map<String, String>? owner = await itemManager.getLostItemOwner(item);

      if (owner != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Lost Item Owner'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: ${owner['username'] ?? 'Unknown'}'),
                  Text('Email: ${owner['email'] ?? 'Unknown'}'),
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
      }
    } catch (e) {
      print('Error showing lost item owner dialog: $e');
    }
  }
}
