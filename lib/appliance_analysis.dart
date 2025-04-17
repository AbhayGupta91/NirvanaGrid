import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cloud_data.dart';
import 'app_state.dart';

class AppliancePage extends StatelessWidget {
  final List<Map<String, dynamic>> appliances = [
    {"title": "Refrigerator", "icon": Icons.kitchen, "color": Colors.blue},
    {"title": "Air Conditioner", "icon": Icons.ac_unit, "color": Colors.cyan},
    {"title": "Washing Machine", "icon": Icons.local_laundry_service, "color": Colors.green},
    {"title": "Microwave", "icon": Icons.microwave, "color": Colors.orange},
    {"title": "Television", "icon": Icons.tv, "color": Colors.red},
    {"title": "Fan", "icon": Icons.toys, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appliance Analysis'),
        backgroundColor: const Color.fromARGB(255, 65, 103, 167),
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
          itemCount: appliances.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Provider.of<AppState>(context, listen: false).setSelectedAppliance(appliances[index]["title"]);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CloudDataPage()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: appliances[index]["color"],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Icon(appliances[index]["icon"], size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appliances[index]["title"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}