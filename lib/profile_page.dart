import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  String? _profilePicUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _profilePicUrl = userDoc['photoURL'];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String filePath = 'profile_pictures/${widget.user.uid}.jpg';
      try {
        await _storage.ref(filePath).putFile(imageFile);
        String downloadUrl = await _storage.ref(filePath).getDownloadURL();
        setState(() => _profilePicUrl = downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image")));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(widget.user.uid).update({
        'name': _nameController.text.trim(),
        'photoURL': _profilePicUrl ?? widget.user.photoURL,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed!")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicUrl != null
                    ? NetworkImage(_profilePicUrl!)
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            Text("Tap to change profile picture", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _saveProfile, child: const Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('ProjectX'), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>?;

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  accountName: Text(userData?['name'] ?? "No Name"),
                  accountEmail: Text(userData?['email'] ?? "No Email"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: userData?['photoURL'] != null
                        ? NetworkImage(userData!['photoURL'])
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(user: user!)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Center(child: Text("Home Page Content Here")),
    );
  }
}
