import 'dart:convert';
import 'package:claimitproject/screens/LoginForm.dart';
import 'package:claimitproject/ui_helper/genLoginSignupHeader.dart';
import 'package:claimitproject/ui_helper/genTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> signUp(String username, String email, String password) async {
    setState(() {
      _isLoading = true; // Show progress indicator
    });

    var url = Uri.parse('http://172.20.10.5:8000/api/register/');
    var response = await http.post(url, headers: {
      "Content-Type": "application/json"
    }, body: jsonEncode({
      "username": username,
      "email": email,
      "password": password
    }));

    setState(() {
      _isLoading = false; // Hide progress indicator
    });

    if (response.statusCode == 201) {
      // Show success dialog and navigate to login
      _showSuccessDialog();
    } else {
      // Show error dialog
      _showErrorDialog("Sign up failed. Please try again.");
    }
  }

  Future<void> getUserData(String token) async {
    var url = Uri.parse('http://172.20.10.5:8000/api/user/');
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // Pass the token here
    });

    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body); // Parse the user data
      print(userData); // Print or use the user data
    } else {
      print("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                genLoginSignUpHeader(),
                GetTextFormField(
                  controller: _usernameController,
                  icon: Icons.person,
                  inputType: TextInputType.name,
                  hintName: 'Username',
                ),
                SizedBox(height: 10.0),
                GetTextFormField(
                  controller: _emailController,
                  icon: Icons.email,
                  inputType: TextInputType.emailAddress,
                  hintName: 'Email',
                ),
                SizedBox(height: 10.0),
                GetTextFormField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  hintName: 'Password',
                  isObscureText: true,
                ),
                SizedBox(height: 10.0),
                GetTextFormField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock,
                  hintName: 'Confirm Password',
                  isObscureText: true,
                ),
                _isLoading
                    ? CircularProgressIndicator() // Show loading spinner
                    : Container(
                        margin: EdgeInsets.all(30.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_passwordController.text ==
                                  _confirmPasswordController.text) {
                                signUp(
                                  _usernameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              } else {
                                _showPasswordMismatchDialog();
                              }
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Do you have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginForm()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('Log In'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Successful'),
          content: const Text('You have successfully signed up.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginForm()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordMismatchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Mismatch'),
          content: const Text('Passwords do not match. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
