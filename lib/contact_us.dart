import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final String recipient = "abhijeetpiyush01@gmail.com";
    final String subject = Uri.encodeComponent("Contact Us Inquiry");
    final String body = Uri.encodeComponent(
        "Name: ${_nameController.text}\nEmail: ${_emailController.text}\nMessage: ${_messageController.text}");

    final String emailUrl = "mailto:$recipient?subject=$subject&body=$body";

    try {
      await launchUrl(Uri.parse(emailUrl), mode: LaunchMode.externalApplication);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email app found! Please install Gmail or Outlook.")),
      );
    }
  }

  Widget _buildInputField(
      {required String label, required TextEditingController controller, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Please enter $label";
        if (label == "Your Email" && !value.contains("@")) return "Enter a valid email";
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Get in Touch",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(label: "Your Name", controller: _nameController),
                    const SizedBox(height: 12),
                    _buildInputField(label: "Your Email", controller: _emailController),
                    const SizedBox(height: 12),
                    _buildInputField(label: "Your Message", controller: _messageController, maxLines: 4),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        shadowColor: Colors.greenAccent,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendEmail();
                        }
                      },
                      child: const Text(
                        "Send Message",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
