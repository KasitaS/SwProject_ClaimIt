import 'package:flutter/material.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/screens/ReportReceived.dart';
import 'package:claimitproject/screens/FoundAdminItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/LostItemPage.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:claimitproject/screens/AdminReceiveItemPage.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ItemManager itemManager = ItemManager();
  int lostItemCount = 0;
  int foundItemCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchItemCounts();
  }

  void _fetchItemCounts() async {
    Map<String, int> counts = await itemManager.getItemCounts();
    setState(() {
      lostItemCount = counts['lost_count'] ?? 0;
      foundItemCount = counts['found_count'] ?? 0;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
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
    var dummyUser = {"id": 1, "name": "Admin", "role": "admin"};
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoundAdminItemPage()),
    );
  }

  void _navigateToReceiveItems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportReceived()),
    );
  }

  void _navigateToReceiveList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminReceiveItemPage()),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown.shade700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
              Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
          _buildDrawerItem(
              Icons.list, 'Found Items', () => _navigateToFoundItems(context)),
          _buildDrawerItem(
              Icons.search, 'Lost Items', () => _navigateToLostItems(context)),
          _buildDrawerItem(Icons.check_circle, 'Received Items',
              () => _navigateToReceiveList(context)),
          Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
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

  Widget _buildCountCard(String title, int count, Color color, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: _buildCountCard(
                        'Lost Items', lostItemCount, Colors.red, Icons.search)),
                SizedBox(width: 16),
                Expanded(
                    child: _buildCountCard('Found Items', foundItemCount,
                        Colors.green, Icons.list)),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Manage Items",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDrawerItem(
                      Icons.checklist, 'Record Found', () => _upload(context)),
                  _buildDrawerItem(Icons.check_box, 'Record Received',
                      () => _navigateToReceiveItems(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
