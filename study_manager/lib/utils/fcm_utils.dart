// utils/fcm_utils.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Initialize FlutterSecureStorage
final _storage = FlutterSecureStorage();

// Global FCM token variable
String? _fcmToken;

// Getter for _fcmToken
String? get fcmToken => _fcmToken;

// Setter for _fcmToken
void setFcmToken(String? token) {
  _fcmToken = token;
}

// Function to send the FCM token to the backend
Future<void> sendTokenToBackend(String token) async {
  final url = Uri.parse('http://192.168.1.4:8000/api/save-device-token/');
  try {
    final String? userToken = await _storage.read(key: 'access_token');

    // Check if the user is authenticated
    if (userToken == null || userToken.isEmpty) {
      print(
        'No access token found. User may not be logged in. Skipping token send.',
      );
      return;
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'device_token': token}),
    );
    if (response.statusCode == 200) {
      print('Token sent to backend successfully');
    } else {
      print('Failed to send token: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending token: $e');
  }
}
