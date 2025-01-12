import 'package:claimitproject/backend/ItemManager.dart';
import 'package:claimitproject/screens/AdminHomePage.dart';
import 'package:flutter/material.dart';
import '../backend/Item.dart';
import '../backend/User.dart';
import '../ui_helper/ItemTile.dart';

class DetailedItemView extends StatefulWidget {
  final Item item;

  DetailedItemView({required this.item});

  @override
  _DetailedItemViewState createState() => _DetailedItemViewState();
}

class _DetailedItemViewState extends State<DetailedItemView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  ItemManager itemManager = ItemManager();

  @override
  void initState() {
    super.initState();
  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Color.fromARGB(255, 243, 237, 206),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ItemTile(item: widget.item),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Text(
                        'Already Received by the Owner',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormWithDecoration(
                    label: 'Name',
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  SizedBox(height: 16),
                  TextFormWithDecoration(
                    label: 'Email',
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        //saveReceiveButton
                        _saveAndMarkAsReceived(widget.item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 161, 239, 163),
                      ),
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Successful'),
          content: Text('This is successfully saved'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Navigate to AdminHome and replace the current route
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHome()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // void _saveAndMarkAsReceived(Item newItem) async {
  //   String name = nameController.text;
  //   String email = emailController.text;

  //   try {
  //     DbHelper dbHelper = DbHelper();

  //     // Get the old item type before updating
  //     String oldItemType = newItem.itemType ?? '';

  //     // Update the item type to 'Received'
  //     newItem.updateItemType('Received');
  //     int itemId = await dbHelper.saveItem(newItem);
  //     await dbHelper.saveReceiveItem(itemId, name, email);

  //     // Delete the item with the old type
  //     await dbHelper.deleteItemByType(itemId, oldItemType);

  //   } catch (e) {
  //     print("Error saving: $e");
  //   }
  //   _showSuccessDialog();
  // }

  void _saveAndMarkAsReceived(Item newItem) async {
    /* itemManager.saveMarkAsReceived(
        newItem, nameController.text, emailController.text);
    _showSuccessDialog(context); */
  }
}

class TextFormWithDecoration extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;

  const TextFormWithDecoration(
      {required this.label, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        controller.text = value;
      },
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.orange),
        ),
        prefixIcon: Icon(icon),
        hintText: label,
        labelText: label,
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }
}
