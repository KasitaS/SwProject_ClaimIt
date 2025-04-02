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
          itemsFetched = true;
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
        title: const Text('Received Items',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
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
                                  'Owner: ${item.extraData?['owner_name'] ?? 'Unknown'}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                  'Email: ${item.extraData?['owner_email'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                          leading: Icon(Icons.check_circle,
                              color: Colors.green, size: 32),
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
