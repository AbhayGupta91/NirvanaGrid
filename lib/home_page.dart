import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'profile_page.dart';
import 'appliance_analysis.dart';
import 'recharge.dart';
import 'feedback.dart';
import 'contact_us.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> options = [
    {"title": "Appliance Analysis", "icon": Icons.electric_meter, "color": Colors.blueGrey},
    {"title": "PF Ratio", "icon": Icons.bar_chart, "color": Colors.blueGrey},
    {"title": "Remote Control", "icon": Icons.settings_remote, "color": Colors.blueGrey},
    {"title": "Recharge/Subscription", "icon": Icons.payment, "color": Colors.blueGrey},
    {"title": "Component Issues", "icon": Icons.warning, "color": Colors.blueGrey},
    {"title": "Energy Consumption", "icon": Icons.bolt, "color": Colors.blueGrey},
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ProjectX'),
        backgroundColor: const Color.fromARGB(255, 65, 103, 167),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Everything is fine"),
                  content: const Text("Nothing to worry about!"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: CircularProgressIndicator());
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>?;

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 65, 103, 167),
                  ),
                  accountName: Text(
                    userData?['name'] ?? "No Name",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  accountEmail: Text(
                    userData?['email'] ?? "No Email",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: userData?['photoURL'] != null
                        ? NetworkImage(userData!['photoURL'])
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text("Profile"),
                  onTap: () {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage(user: currentUser)),
                        );
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.blue),
                  title: const Text("Feedback"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_mail, color: Colors.blue),
                  title: const Text("Contact Us"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactUsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () {
                    Provider.of<AuthService>(context, listen: false).signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (options[index]["title"] == "Appliance Analysis") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppliancePage()),
                  );
                } else if (options[index]["title"] == "Recharge/Subscription") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RechargePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${options[index]["title"]} coming soon!"),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: options[index]["color"],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(options[index]["icon"], size: 40, color: Colors.yellow),
                    const SizedBox(height: 8),
                    Text(
                      options[index]["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
