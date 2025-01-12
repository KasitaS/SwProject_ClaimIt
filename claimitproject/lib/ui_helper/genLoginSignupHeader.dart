import 'package:flutter/material.dart';


class genLoginSignUpHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50.0),
        Image.asset(
          "assets/images/school.png", 
          height: 80.0 ,
        ),
        SizedBox(height:10.0),
      ],
    );
  }
}