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
        backgroundColor: Color.fromARGB(255, 240, 225, 207),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 35.0),
            Image.asset(
              'assets/images/admin.png',
              height: 250,
            ),
            const SizedBox(height: 10.0),
            GetTextFormField(
              controller: _conVerify,
              hintName: 'Enter Verification Code',
              icon: Icons.description,
              isObscureText: true, // Use this for sensitive input
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _validateCode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                    255, 240, 225, 207), // Set button background color
              ),
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateCode() async {
    String enteredCode = _conVerify.text.trim();

    if (enteredCode.isEmpty) {
      _showErrorDialog('Verification Code is required.');
    } else {
      try {
        // Fetch CSRF token for security
        final csrfResponse = await http
            .get(Uri.parse('http://172.20.10.3:8000/api/get_csrf_token/'));
        String csrfToken = csrfResponse.body;

        // Send POST request to verify the admin code
        final response = await http.post(
          Uri.parse('http://172.20.10.3:8000/api/verify_admin_code/'),
          headers: {
            "Content-Type": "application/json",
            "X-CSRFToken": csrfToken,
          },
          body: json.encode({'admincode': enteredCode}),
        );

        if (response.statusCode == 200) {
          // Navigate to AdminHome if verification is successful
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
