import 'package:claimitproject/backend/ItemManager.dart';
import 'package:flutter/material.dart';
import '../backend/Item.dart'; // Import your Item class
import '../ui_helper/ItemTile.dart'; // Import your ItemTile widget

class ReceiveItemPage extends StatefulWidget {
  const ReceiveItemPage({Key? key}) : super(key: key);

  @override
  State<ReceiveItemPage> createState() => _ReceiveItemPageState();
}

class _ReceiveItemPageState extends State<ReceiveItemPage> {
  late Future<List<Item>> receivedItems;

  @override
  void initState() {
    super.initState();
    receivedItems = _getReceivedItems();
  }

  Future<List<Item>> _getReceivedItems() async {
    throw UnsupportedError('message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Items'),
      ),
      body: FutureBuilder<List<Item>>(
        future: receivedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No received items available.'),
            );
          } else {
            // Display the received items using a ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      _showReceivePersonDialog(context, snapshot.data![index]),
                  child: ItemTile(item: snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _showReceivePersonDialog(BuildContext context, Item item) async {
    try {
      ItemManager itemManager = ItemManager();
      Map<String, String>? receivePerson =
          await itemManager.getReceivePerson(item);

      if (receivePerson != null) {
        String receivePersonName = receivePerson['name'] ?? 'Unknown';
        String receivePersonEmail = receivePerson['email'] ?? 'Unknown';
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Received by'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Name: $receivePersonName'),
                  Text('Email: $receivePersonEmail'),
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
      } else {
        // Handle case when receive person is not found
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Receive person not found.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error showing receive person dialog: $e');
    }
  }
}
