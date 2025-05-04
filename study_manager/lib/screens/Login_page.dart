import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/fcm_utils.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isPasswordVisible = false; // State to toggle password visibility

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8000/api/token/'),
        body: {'username': username, 'password': password},
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        print("Login Successful: Tokens stored");

        if (fcmToken != null) {
          await sendTokenToBackend(fcmToken!);
        } else {
          print('FCM token not available yet.');
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnackBar(
          'Login failed, please check your credentials.',
          isError: true,
        );
      }
    } catch (e) {
      print("Error during login: $e");
      _showSnackBar('An error occurred during login.', isError: true);
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
                        'Login',
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
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF3674B5)),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _login,
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
                          'Log in',
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
                                'Or Login with',
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
                      SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Register Now',
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
