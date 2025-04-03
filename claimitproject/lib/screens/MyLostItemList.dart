import 'package:flutter/material.dart';
import 'package:claimitproject/backend/CallAPI.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/screens/RecommendLost.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/NewHomePage.dart';
import '../ui_helper/ItemTileD.dart';

class MyItemList extends StatefulWidget {
  final User user;

  const MyItemList({Key? key, required this.user}) : super(key: key);

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
    setState(() => isLoading = true);

    try {
      List<Item> items = await CallAPI.getUserLostItems(widget.user.username);
      setState(() {
        itemList = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(Item item, int index) async {
    try {
      await CallAPI.deleteItem(item);
      setState(() {
        itemList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
        title: const Text('My Lost Items'),
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : itemList.isEmpty
                  ? const Center(
                      child: Text('No items to display',
                          style: TextStyle(fontSize: 18.0)),
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          _buildDrawerItem(Icons.home, 'Home Page', () {
            _navigateTo(NewHomePage(user: widget.user));
          }),
          _buildDrawerItem(Icons.folder, 'My Lost Items', () {}),
          _buildDrawerItem(Icons.list, 'Found Items', () {
            _navigateTo(FoundUserItemPage(user: widget.user));
          }),
          _buildDrawerItem(Icons.logout, 'Log Out', _logout),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: Color.fromARGB(255, 57, 41, 21)),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.white, size: 32),
          SizedBox(width: 10),
          Text('ClaimIt', style: TextStyle(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _logout() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginForm()));
  }
}
