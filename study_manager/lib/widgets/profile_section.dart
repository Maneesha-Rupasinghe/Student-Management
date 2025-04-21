import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                'assets/profile.jpeg',
              ), // Replace with user's profile image
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Name', // Replace with user's name
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'user@example.com', // Replace with user's email
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        // Add a row for quiz percentage and notification icon
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                '85%', // Replace with the correct percentage
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            // Notification icon to the right of quiz percentage
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.blue),
              onPressed: () {
                // Handle notification icon press
                print('Notification icon pressed');
              },
            ),
          ],
        ),
      ],
    );
  }
}
