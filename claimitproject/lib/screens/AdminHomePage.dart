import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/screens/AdminReceiveItemPage.dart';
import 'package:claimitproject/screens/FoundUserItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/LostItemPage.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ItemManager itemManager = ItemManager();
  void _logout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

void _upload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UploadForm(itemPoster: itemManager)),
    );
  }


void _navigateToLostItems(BuildContext context) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LostItemPage()),
    ); 
  }

  void _navigateToFoundItems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoundUserItemPage()),
    ); 
  }

  void _navigateToReceiveItems(BuildContext context) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiveItemPage()),
    ); 
  }

  Widget _buildContainer(String title, Function onTap) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.2,
        margin: EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: _buildContainer('Found Item List', () {
              _navigateToFoundItems(context);
            }),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.1,
            child: _buildContainer('Receive Item List', () {
              _navigateToReceiveItems(context);
            }),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            right: MediaQuery.of(context).size.width * 0.1,
            child: _buildContainer('Lost Item List', () {
              _navigateToLostItems(context);
            }),
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
}
