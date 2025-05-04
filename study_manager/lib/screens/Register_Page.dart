import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false; // State for password visibility
  bool _isConfirmPasswordVisible =
      false; // State for confirm password visibility

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }

    final url = Uri.parse('http://192.168.1.4:8000/api/register/');
    final response = await http.post(
      url,
      body: {'username': username, 'email': email, 'password': password},
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201) {
      _showSnackBar('Registration Successful! Please log in.', isError: false);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnackBar('Registration failed. Please try again.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Color(0xFFF44336) : Color(0xFF4CAF50),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/loginBackground.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF080B0B),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: Color(0xFF080B0B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFB4EBE6).withOpacity(0.2),
                          labelText: 'User Name',
                          labelStyle: TextStyle(color: Color(0xFF080B0B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Color(0xFF080B0B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFB4EBE6).withOpacity(0.2),
                          labelText: 'Email Address',
                          labelStyle: TextStyle(color: Color(0xFF080B0B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(color: Color(0xFF080B0B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFB4EBE6).withOpacity(0.2),
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Color(0xFF080B0B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xFF080B0B),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _confirmPasswordController,
                        style: TextStyle(color: Color(0xFF080B0B)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFB4EBE6).withOpacity(0.2),
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Color(0xFF080B0B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xFF080B0B),
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3674B5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Color(0xFF080B0B)),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Or Register with',
                                style: TextStyle(color: Color(0xFF080B0B)),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Divider(color: Color(0xFF080B0B)),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Image.asset(
                            'assets/gmail.webp',
                            height: 48,
                            width: 48,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Login Now',
                              style: TextStyle(color: Color(0xFF3674B5)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
