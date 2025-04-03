import 'package:flutter/material.dart';

class genLoginSignUpHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20.0),
        Image.asset(
          "assets/images/main_logo.png",
          height: 120.0,
          width: 120.0,
        ),
        SizedBox(height: 5.0),
        Text(
          "Welcome to ClaimIt",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 7.0),
        Text(
          "Your campus lost & found assistant",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}
