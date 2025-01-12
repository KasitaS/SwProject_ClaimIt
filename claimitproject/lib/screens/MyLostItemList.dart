import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/auth_service.dart';
import 'package:claimitproject/screens/RecommendLost.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ui_helper/ItemTileD.dart';// Import your Item class

class MyItemList extends StatefulWidget {
  final String username; // Receive the username from the previous page

  const MyItemList({super.key, required this.username});

  @override
  State<MyItemList> createState() => _MyItemListState();
}

class _MyItemListState extends State<MyItemList> {
  List<Item> itemList = [];
  bool isLoading = true; // Track loading state
  String? errorMessage; // Track any errors

  @override
  void initState() {
    super.initState();
    fetchLostItems(); // Call the function to fetch lost items on load
  }

  Future<void> fetchLostItems() async {
  String? token = await getToken();

  if (token == null) {
    setState(() {
      errorMessage = 'No authentication token found. Please log in again.';
      isLoading = false;
    });
    print('No authentication token found');
    return;
  }

  try {
    final url = Uri.parse('http://172.20.10.5:8000/api/lost-items/${widget.username}/');
    print('Attempting to fetch items with token: Bearer $token'); // Debugging print

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        itemList = data.map((item) => Item.fromJson(item)).toList();
        isLoading = false;
      });
      print('Items loaded successfully'); // Debugging print
    } else if (response.statusCode == 401) {
      // Handle unauthorized response and display an error message
      setState(() {
        errorMessage = 'Unauthorized: Token may be invalid or expired. Please log in again.';
        isLoading = false;
      });
      print('Unauthorized error: ${response.statusCode} ${response.body}');
      
      // Uncomment if refresh token functionality is implemented
      // bool isRefreshed = await _refreshToken();
      // if (isRefreshed) {
      //   await fetchLostItems();  // Retry after refreshing the token
      // }
    } else {
      // Handle other response codes
      setState(() {
        errorMessage = 'Failed to load items: ${response.statusCode} ${response.body}';
        isLoading = false;
      });
      print('Error fetching items: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error: ${e.toString()}';
      isLoading = false;
    });
    print('Exception during fetch: ${e.toString()}');
  }
}

  /*
  // for refreshToken part
  Future<bool> _refreshToken() async {
  String? refreshToken = await getToken();  // Use refresh token if stored separately

  if (refreshToken == null) {
    print('No refresh token found');
    return false;
  }

  try {
    final url = Uri.parse('http://10.0.2.2:8000/api/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newToken = data['access'];
      await saveToken(newToken);  // Save the new token
      return true;
    } else {
      print('Failed to refresh token: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error refreshing token: ${e.toString()}');
    return false;
  }
} */


  void deleteItem(Item item, int index) {
    setState(() {
      itemList.removeAt(index);
    });
    // Optionally, add logic to delete item from the backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('My Lost Items'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : errorMessage != null
              ? Center(child: Text(errorMessage!)) // Display error message
              : itemList.isEmpty
                  ? const Center(
                      child: Text(
                        'No items to display',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  : ListView.builder(
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to another page when the item is tapped 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecommendLostPage(
                                  item: itemList[index],
                                ),
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
    );
  }
}
