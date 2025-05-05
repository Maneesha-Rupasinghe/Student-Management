import 'package:flutter/material.dart';
import 'package:study_manager/widgets/bottom_bar/notch_bottom_bar_controller.dart';
import 'package:study_manager/widgets/user/all_task_list.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset the bottom navigation bar index to Home (index 0)
            final controller = NotchBottomBarController(index: 0);
            controller.jumpTo(0);
            Navigator.popUntil(context, ModalRoute.withName('/home'));
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('User Profile'),
            subtitle: const Text(
              'Manage your strengths, weaknesses, and study preferences',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF3674B5),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user-profile');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('User Account'),
            subtitle: const Text('Update your profile and password'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF3674B5),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user-account');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('History'),
            subtitle: const Text('View your activity history'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF3674B5),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user-tasks');
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
