import 'dart:convert';
import 'package:claimitproject/backend/CallAPI.dart';
import 'package:claimitproject/backend/Item.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/ui_helper/ItemTileP.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/MyLostItemList.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewHomePage extends StatefulWidget {
  final User user;

  const NewHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  List<Item> lostItems = [];
  bool itemsFetched = false;

  @override
  void initState() {
    super.initState();
    fetchLostItems();
  }

  Future<void> fetchLostItems() async {
    List<Item> items = await CallAPI.fetchLostItems();
    setState(() {
      lostItems = items;
      itemsFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ClaimIt'),
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 57, 41, 21),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ClaimIt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text('Home Page'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.folder, color: Colors.blue),
              title: Text('My Lost Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyItemList(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.blue),
              title: Text('Found Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoundUserItemPage(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text('Log Out'),
              onTap: () {
                _logout();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 183, 163, 139),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/main_logo.png',
                    width: 100,
                    height: 100,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Hi, ${widget.user.username}\nWelcome to ClaimIt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Have you seen this?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: itemsFetched
                                ? (lostItems.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No lost items reported.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: lostItems.length,
                                        itemBuilder: (context, index) {
                                          return ItemTileP(
                                              item: lostItems[index]);
                                        },
                                      ))
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  UploadForm(itemPoster: widget.user),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 57, 41, 21),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }
}
