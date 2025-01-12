import 'package:claimitproject/screens/AdminHomePage.dart';
import 'package:claimitproject/ui_helper/genTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminForm extends StatefulWidget {
  const AdminForm({super.key});

  @override
  State<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final TextEditingController _conVerify = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 35.0),
            Image.asset(
              'assets/images/staff.png',
              height: 150,
            ),
            const SizedBox(height: 35.0),
            GetTextFormField(
              controller: _conVerify,
              hintName: 'Verification Code',
              icon: Icons.description,
              isObscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _validateCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Set button background color
              ),
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to validate the verification code with the backend
  Future<void> _validateCode() async {
    String enteredCode = _conVerify.text.trim();

    if (enteredCode.isEmpty) {
      _showErrorDialog('Verification Code is required.');
    } else {
      try {


        final csrfResponse = await http.get(Uri.parse('http://172.20.10.5:8000/api/get_csrf_token/'));
        String csrfToken = csrfResponse.body; 

        final response = await http.post(
  Uri.parse('http://172.20.10.5:8000/api/verify_admin_code/'),
  headers: {
    "Content-Type": "application/json",
    "X-CSRFToken": csrfToken,  // Make sure this header is included
  },
  body: json.encode({'admincode': enteredCode}),  // Ensure this is a valid JSON
);

        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminHome()),
            (Route<dynamic> route) => false,
          );
        } else {
          _showErrorDialog('Incorrect Verification Code. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
