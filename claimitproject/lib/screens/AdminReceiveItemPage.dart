import 'dart:convert';
import 'package:claimitproject/backend/CallAPI.dart';
import 'package:claimitproject/screens/AdminHomePage.dart';
import 'package:claimitproject/screens/FoundAdminItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/LostItemPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../backend/auth_service.dart';
import '../backend/Item.dart';
import '../ui_helper/ItemTile.dart';

class AdminReceiveItemPage extends StatefulWidget {
  const AdminReceiveItemPage({Key? key}) : super(key: key);

  @override
  State<AdminReceiveItemPage> createState() => _AdminReceiveItemPageState();
}

class _AdminReceiveItemPageState extends State<AdminReceiveItemPage> {
  List<Item> receivedItems = [];
  bool itemsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchReceivedItems();
  }

  Future<void> fetchReceivedItems() async {
    var result = await CallAPI.fetchReceivedItems();

    if (result["success"]) {
      setState(() {
        receivedItems = result["items"];
        itemsFetched = true;
      });
    } else {
      setState(() {
        itemsFetched = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
        centerTitle: true,
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
                  MaterialPageRoute(builder: (context) => const FoundAdminItemPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue,),
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
                  MaterialPageRoute(builder: (context) => const AdminReceiveItemPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue,),
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
      body: itemsFetched
          ? (receivedItems.isEmpty
              ? Center(
                  child: Text(
                    'No received items available.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: receivedItems.length,
                    itemBuilder: (context, index) {
                      Item item = receivedItems[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            item.name,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${item.category}',
                                  style: TextStyle(color: Colors.black87)),
                              SizedBox(height: 4),
                              Text(
                                  'Claimer: ${item.extraData?['claimer_name'] ?? 'Unknown'}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                  'Email: ${item.extraData?['claimer_email'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          leading: item.image_path != null
                              ? Image.network(
                                  'http://172.20.10.5:8000/api/get_image_file/?image_path=${item.image_path!}',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_not_supported,
                                          size: 50, color: Colors.grey),
                                )
                              : Icon(Icons.image, size: 50, color: Colors.grey),
                          tileColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
