import 'dart:io';
import 'package:flutter/material.dart';
import '../backend/Item.dart';

 import 'dart:io';
import 'package:flutter/material.dart';
import '../backend/Item.dart';

class ItemTile extends StatelessWidget {
  final Item item;

  const ItemTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set background color to white
          borderRadius:
              BorderRadius.circular(12), // Add border radius for curves
          border: Border.all(color: Colors.black), // Set border color to black
          boxShadow: [
            BoxShadow(
              color:
                  Colors.grey.withOpacity(0.5), // Set shadow color and opacity
              spreadRadius: 3, // Set spread radius
              blurRadius: 5, // Set blur radius
              offset: Offset(0, 3), // Set shadow offset
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 100,
            height: 100,
            child: item.imagePath != null
                ? Image.file(
                    File(item.imagePath!), // Load image from file path
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Placeholder(), // Placeholder if image is not available
          ),
          title: Text(
            item.name ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Make name text bold
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Color: ${item.color ?? ''}'),
              Text('Category: ${item.category ?? ''}'),
              Text('Location: ${item.location ?? ''}'),
              Text('Description: ${item.description ?? ''}'),
            ],
          ),
          // You can add other actions or UI elements as needed
        ),
      ),
    );
  }
}