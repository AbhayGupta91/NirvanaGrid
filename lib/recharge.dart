import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargePage extends StatefulWidget {
  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  String selectedPlan = "Basic"; // Default plan
  final Map<String, double> planPrices = {
    "Basic": 99.0,
    "Standard": 199.0,
    "Premium": 299.0,
  };

  // UPI ID for payment (Update if needed)
  final String upiId = "7085687361@ptsbi";

  // Function to initiate UPI payment
  void _makeUPIPayment() async {
    double price = planPrices[selectedPlan]!;
    String url = "upi://pay?pa=$upiId&pn=ProjectX&mc=0000&tid=123456&tr=TXN$price&tn=Subscription+Payment&am=$price&cu=INR";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI app found! Please install Google Pay, PhonePe, or Paytm.")),
      );
    }
  }

  Widget _buildPlanOption(String plan, double price) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = plan;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedPlan == plan ? Colors.blueAccent : Colors.blueGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plan,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text("₹$price / month", style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recharge & Subscription"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose a Subscription Plan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: planPrices.entries.map((entry) {
                return _buildPlanOption(entry.key, entry.value);
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _makeUPIPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: const Text("Pay via UPI", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
