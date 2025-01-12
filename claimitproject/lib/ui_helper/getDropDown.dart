import 'package:flutter/material.dart';

class getDropdownFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintName;
  final IconData? icon;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  getDropdownFormField({
    this.controller,
    this.hintName,
    this.icon,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.orange),
          ),
          prefixIcon: Icon(icon),
          hintText: hintName,
          labelText: hintName,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }
}
