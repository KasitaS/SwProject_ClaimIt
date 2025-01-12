import 'package:claimitproject/backend/User.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/MyLostItemList.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String username;

  @override
  void initState() {
    super.initState();
    username = widget.user.username; // Access username from user object
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
          ),
          AspectRatio(
            aspectRatio: 12 / 9,
            child: Container(
              color: Colors.orange,
            ),
          ),
          Positioned(
            left: 35,
            top: MediaQuery.of(context).size.height * 0.15,
            child: Row(
              children: [
                Text(
                  'Hello $username,\nWelcome to ClaimIt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 30),
                Icon(
                  Icons.account_circle_sharp,
                  color: Colors.white,
                  size: 70,
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.05,
            child: GestureDetector(
              onTap: () {
                _onFoundItemListTapped(context);
              },
              child: _buildCard('Found Item List'),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.57,
            right: MediaQuery.of(context).size.width * 0.05,
            child: GestureDetector(
              onTap: () {
                _onLostItemListTapped(context);
              },
              child: _buildCard('My Lost Item'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 237, 237, 239),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Log out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
        ],
        selectedItemColor: Colors.blue,
        onTap: (int index) {
          if (index == 0) {
            _logout(context);
          } else if (index == 1) {
            _upload(context);
          }
        },
      ),
    );
  }

  Widget _buildCard(String title) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

  void _upload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadForm(itemPoster: widget.user)),
    );
  }

  void _onFoundItemListTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoundUserItemPage()),
    );
  }

  void _onLostItemListTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyItemList(username: username)), // Use local username variable
    );
  }
}
