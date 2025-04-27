import 'package:flutter/material.dart';
import 'package:study_manager/screens/User_profile_screen.dart';
import 'package:study_manager/screens/home_screen.dart';
import 'package:study_manager/screens/user_account_screen.dart';
import 'package:study_manager/widgets/task/completed_task.dart'; // Import your home screen

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent the back button from showing up in the AppBar
      onWillPop: () async {
        // Returning false to disable the back button on Android
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: null, // This will remove the back button
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Account'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [GeneralTab(), AccountTab(), HistoryTab()],
        ),
      ),
    );
  }
}

class GeneralTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: UserProfileScreen());
  }
}

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: UserAccountScreen());
  }
}

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CompletedTasksList());
  }
}
