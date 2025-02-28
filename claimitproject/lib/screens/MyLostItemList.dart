import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:claimitproject/screens/RecommendLost.dart';
import '../ui_helper/ItemTileD.dart';

class MyItemList extends StatefulWidget {
  final String username;

  const MyItemList({super.key, required this.username});

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
          'http://10.0.2.2:8000/api/user-lost-items/${widget.username}/');
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
      }
      
      
      else {
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

  void deleteItem(Item item, int index) {
    setState(() {
      itemList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('My Lost Items'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
}
