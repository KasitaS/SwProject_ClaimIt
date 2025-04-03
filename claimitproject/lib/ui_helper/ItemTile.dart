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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: item.image_path != null
                ? Image.network(
                    'http://172.20.10.5:8000/api/get_image_file/?image_path=${item.image_path!}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 50);
                    },
                  )
                : const Icon(Icons.image_not_supported,
                    size: 50), // Placeholder if no image path
          ),
          title: Text(
            item.name ?? 'Unknown Item',
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Make name text bold
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Color: ${item.color ?? 'Unknown'}'),
              Text('Category: ${item.category ?? 'Unknown'}'),
              Text('Location: ${item.location ?? 'Unknown'}'),
              Text('Description: ${item.description ?? 'Unknown'}'),
            ],
          ),
        ),
      ),
    );
  }
}
