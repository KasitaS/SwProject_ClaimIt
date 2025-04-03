import 'package:flutter/material.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/ui_helper/ItemTile.dart';
import 'package:claimitproject/backend/CallAPI.dart';

class ReportReceived extends StatefulWidget {
  const ReportReceived({super.key});

  @override
  State<ReportReceived> createState() => _ReportReceivedState();
}

class _ReportReceivedState extends State<ReportReceived> {
  late List<Item> displayedItems = [];
  final TextEditingController searchController = TextEditingController();
  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    ),
                    onChanged: (value) {
                      searchItems();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedItems.length,
              itemBuilder: (context, index) {
                Item item = displayedItems[index];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.image_path != null
                          ? Image.network(
                              'http://172.20.10.5:8000/api/get_image_file/?image_path=${item.image_path!}',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey),
                            )
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    title: Text(
                      item.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Category: ${item.category}"),
                        Text("Location: ${item.location ?? 'Unknown'}"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showReceiveDialog(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Receive",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchItems() async {
    String searchText = searchController.text.trim().toLowerCase();
    try {
      List<Item> items = await CallAPI.fetch_FoundItems(searchText);
      setState(() {
        displayedItems = items;
      });
    } catch (e) {
      setState(() {
        displayedItems = [];
      });
    }
  }

  void showReceiveDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Item Received"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${item.name}"),
              Text("Category: ${item.category}"),
              Text("Location: ${item.location ?? 'Unknown'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                updateItemReceived(item);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void updateItemReceived(Item item) async {
    try {
      await CallAPI.updateItemReceived(item.id);
      setState(() {
        displayedItems.remove(item);
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item marked as received!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update item')));
    }
  }
}
