import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../backend/Item.dart';
import '../ui_helper/ItemTile.dart';

class RecommendLostPage extends StatefulWidget {
  final Item item;

  RecommendLostPage({required this.item});

  @override
  _RecommendLostPageState createState() => _RecommendLostPageState();
}

class _RecommendLostPageState extends State<RecommendLostPage> {
  final String apiUrl =
      'http://172.20.10.3:8000/api/found-items/'; // Django API endpoint
  final String fastApiUrl =
      'http://172.20.10.3:8001/image_similarity/'; // FastAPI endpoint
  List<Item> filteredItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecommendedItems();
  }

  Future<void> fetchRecommendedItems() async {
    final Uri requestUri = Uri.parse(
        '$apiUrl?category=${widget.item.category}&location=${widget.item.location}');

    try {
      final response = await http.get(requestUri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Item> foundItems =
            data.map((jsonItem) => Item.fromJson(jsonItem)).toList();

        // Compare images and filter based on similarity
        await compareImages(foundItems);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch items';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> compareImages(List<Item> foundItems) async {
    List<Item> similarItems = [];

    for (var foundItem in foundItems) {
      // Check if nobg_image_path is not null and not empty
      if (foundItem.nobg_image_path != null &&
          foundItem.nobg_image_path!.isNotEmpty) {
        double similarityScore = await getSimilarity(widget.item.image_path!,
            foundItem.nobg_image_path!); // Use ! to assert non-null

        if (similarityScore > 0.75) {
          similarItems.add(foundItem);
        }
      }
    }

    setState(() {
      filteredItems = similarItems; // Update the filtered items
    });
  }

  Future<double> getSimilarity(
      String lostItemImage, String foundItemImage) async {
    try {
      var lostImageResponse = await http.get(Uri.parse(lostItemImage));
      var foundImageResponse = await http.get(Uri.parse(foundItemImage));

      if (lostImageResponse.statusCode == 200 &&
          foundImageResponse.statusCode == 200) {
        var request = http.MultipartRequest("POST", Uri.parse(fastApiUrl));
        request.files.add(http.MultipartFile.fromBytes(
            "file1", lostImageResponse.bodyBytes,
            filename: "lost.png"));
        request.files.add(http.MultipartFile.fromBytes(
            "file2", foundImageResponse.bodyBytes,
            filename: "found.png"));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);

        return jsonData["similarity_score"][0]; // Extract similarity score
      }
    } catch (e) {
      print("Error getting similarity: $e");
    }
    return 0.0; // Return low similarity if error occurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommended Items')),
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
                          child: widget.item.image_path != null &&
                                  File(widget.item.image_path!).existsSync()
                              ? Image.file(File(widget.item.image_path!),
                                  width: 100, height: 100, fit: BoxFit.cover)
                              : Placeholder(),
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
