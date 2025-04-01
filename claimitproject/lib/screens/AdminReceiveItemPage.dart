import 'dart:convert';
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
  final Uri getReceivedItemUri =
      Uri.parse('http://172.20.10.3:8000/api/received_items/');
  bool itemsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchReceivedItems(); // Fetch items when the widget is initialized
  }

  Future<void> fetchReceivedItems() async {
    try {
      final response = await http.get(getReceivedItemUri);
      if (response.statusCode == 200) {
        setState(() {
          receivedItems = (json.decode(response.body) as List)
              .map((item) => Item.fromJson(item))
              .toList();
          itemsFetched = true; // Set the fetched status to true
        });
      } else {
        print('Failed to retrieve received items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching received items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items'),
      ),
      body: itemsFetched // Check if items have been fetched
          ? (receivedItems.isEmpty
              ? Center(
                  child: Text(
                    'No received items available.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: receivedItems.length,
                  itemBuilder: (context, index) {
                    return ItemTile(
                        item: receivedItems[index]); // Display each item
                  },
                ))
          : Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator while fetching
    );
  }
}
