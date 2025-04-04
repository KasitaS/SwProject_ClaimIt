import 'package:flutter/material.dart';
import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/screens/ReportReceived.dart';
import 'package:claimitproject/screens/FoundAdminItemPage.dart';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/screens/LostItemPage.dart';
import 'package:claimitproject/screens/UploadForm.dart';
import 'package:claimitproject/screens/AdminReceiveItemPage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ItemManager itemManager = ItemManager();
  int lostItemCount = 0;
  int foundItemCount = 0;
  int receivedItemCount = 0;

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
      receivedItemCount = counts['received_count'] ?? 0;
    });
  }

  Widget _buildCountCard(String title, int count, Color color, IconData icon) {
    return Card(
      elevation: 5,
      color: Color.fromARGB(255, 240, 225, 207), // Light Beige
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 237, 233, 228), 
      appBar: AppBar(
        backgroundColor: Color(0xFFF0E1CF), 
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.brown),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
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
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminHome()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text('Found Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FoundAdminItemPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue,),
              title: const Text('Lost Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LostItemPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: const Text('Received Items'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminReceiveItemPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue,),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginForm()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistics",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown),
            ),
            const SizedBox(height: 10),
            _buildPieChart(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: _buildCountCard(
                        'Lost', lostItemCount, Colors.red, Icons.search)),
                const SizedBox(width: 5),
                Expanded(
                    child: _buildCountCard(
                        'Found', foundItemCount, Colors.green, Icons.list)),
                const SizedBox(width: 5),
                Expanded(
                    child: _buildCountCard('Receive', receivedItemCount,
                        Colors.blue, Icons.check_circle)),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Items",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: constraints.maxWidth > 500
                              ? 4
                              : 5, 
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildActionButton(
                                Icons.upload, 'Upload Item', Color(0xFFD6A273),
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UploadForm(itemPoster: itemManager)));
                            }),
                          ),
                        ),
                        const SizedBox(width: 10), 
                        Expanded(
                          flex: constraints.maxWidth > 500 ? 4 : 5,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildActionButton(Icons.check_box,
                                'Record Received', Color(0xFFD6A273), () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReportReceived()));
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: lostItemCount.toDouble(),
              color: Colors.red.shade300,
              title: 'Lost\n$lostItemCount',
              radius: 50,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: foundItemCount.toDouble(),
              color: Colors.green.shade300,
              title: 'Found\n$foundItemCount',
              radius: 50,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: receivedItemCount.toDouble(),
              color: Colors.blue.shade300,
              title: 'Received\n$receivedItemCount',
              radius: 50,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
