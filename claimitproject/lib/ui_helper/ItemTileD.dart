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
    // Determine if the image path is a network URL or local path
    bool isLocalImage = item.image_path != null &&
        item.image_path!
            .startsWith('items/images/'); // Adjust according to your media path

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: item.image_path != null
                  ? Image.network(
                      'http://172.20.10.5:8000/api/get_image_file/?image_path=${Uri.encodeComponent(item.image_path!)}',
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
