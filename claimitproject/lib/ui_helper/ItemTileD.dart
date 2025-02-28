import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../backend/Item.dart';

class ItemTileD extends StatelessWidget {
  final Item item;
  final void Function(BuildContext)? deleteFunction;

  const ItemTileD({
    Key? key,
    required this.item,
    required this.deleteFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLocalImage = item.imagePath != null && item.imagePath!.startsWith('/data/'); // Check if the path is local

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            border: Border.all(color: Colors.black), // Border color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow effect
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded image corners
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: isLocalImage
                  ? Image.file(
                      File(item.imagePath!), // Load local image
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 50); // Fallback for broken images
                      },
                    )
                  : const Icon(Icons.image_not_supported, size: 50), // Show default icon if no image
            ),
            title: Text(
              item.name ?? 'Unknown Item',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Color: ${item.color ?? 'Unknown'}'),
                Text('Category: ${item.category ?? 'Unknown'}'),
                Text('Location: ${item.location ?? 'Unknown'}'),
                Text('Description: ${item.description ?? 'No description'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
