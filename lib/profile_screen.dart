import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'myprofile.dart';

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF17395E),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      user?.photoURL ?? 'https://via.placeholder.com/150'),
                ),
                SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'User Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Edit Profile Screen
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to MyProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyProfileScreen()),
                    );
                  },
                  icon: Icon(Icons.person),
                  label: Text('My profile'),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/auth');
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
