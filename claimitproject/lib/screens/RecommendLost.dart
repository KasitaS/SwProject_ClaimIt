import 'dart:convert';
import 'package:flutter/material.dart';
import '../backend/Item.dart';
import '../ui_helper/ItemTile.dart';
import '../backend/CallAPI.dart'; // Import CallAPI

class RecommendLostPage extends StatefulWidget {
  final Item item;

  RecommendLostPage({required this.item});

  @override
  _RecommendLostPageState createState() => _RecommendLostPageState();
}

class _RecommendLostPageState extends State<RecommendLostPage> {
  List<Item> filteredItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecommendedItems();
  }

  Future<void> fetchRecommendedItems() async {
    try {
      List<Item> foundItems = await CallAPI.fetchRecommendedItems(widget.item);

      await compareImages(foundItems);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> compareImages(List<Item> foundItems) async {
    List<Item> similarItems = [];

    for (var foundItem in foundItems) {
      if (widget.item.nobg_image_path != null &&
          widget.item.nobg_image_path!.isNotEmpty &&
          foundItem.nobg_image_path != null &&
          foundItem.nobg_image_path!.isNotEmpty) {
        double similarityScore = await CallAPI.getImageSimilarity(
          'http://172.20.10.5:8000/api/get_image_file/?image_path=${Uri.encodeComponent(widget.item.nobg_image_path!)}',
          'http://172.20.10.5:8000/api/get_image_file/?image_path=${Uri.encodeComponent(foundItem.nobg_image_path!)}',
        );

        if (similarityScore > 0.70) {
          similarItems.add(foundItem);
        }
      }
    }

    setState(() {
      filteredItems = similarItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommended Items'), backgroundColor: Color.fromARGB(255, 240, 225, 207)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 194, 172, 146)),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 100,
                          height: 100,
                          child: widget.item.image_path != null
                              ? Image.network(
                                  'http://172.20.10.5:8000/api/get_image_file/?image_path=${Uri.encodeComponent(widget.item.image_path!)}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported,
                                        size: 50);
                                  },
                                )
                              : const Icon(Icons.image_not_supported, size: 50),
                        ),
                        title: Text(widget.item.name ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Color: ${widget.item.color ?? ''}'),
                            Text('Category: ${widget.item.category ?? ''}'),
                            Text('Location: ${widget.item.location ?? ''}'),
                            Text(
                                'Description: ${widget.item.description ?? ''}'),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8.0),
                      child: Text(
                        'Recommended Items',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    filteredItems.isEmpty
                        ? const Center(
                            child: Text('No matching items found',
                                style: TextStyle(fontSize: 18.0)))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                return ItemTile(item: filteredItems[index]);
                              },
                            ),
                          ),
                  ],
                ),
    );
  }
}
