import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class CloudDataPage extends StatefulWidget {
  @override
  _CloudDataPageState createState() => _CloudDataPageState();
}

class _CloudDataPageState extends State<CloudDataPage> {
  final databaseRef = FirebaseDatabase.instance.ref("realtime_data");
  Map<String, dynamic>? realtimeData;
  List<Map<String, dynamic>> pfDataHistory = [];
  bool showPFChart = false;
  String? selectedAppliance;

  @override
  void initState() {
    super.initState();
    selectedAppliance = Provider.of<AppState>(context, listen: false).selectedAppliance;
    if (selectedAppliance == "Air Conditioner") {
      _listenToRealtimeData();
    }
  }

  void _listenToRealtimeData() {
    databaseRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          realtimeData = data;

          // Save last 10 PF readings
          pfDataHistory.add({
            "timestamp": DateTime.now().toIso8601String(),
            "pf": double.tryParse(data["Power_Factor"].toString()) ?? 0.0,
          });

          if (pfDataHistory.length > 10) {
            pfDataHistory.removeAt(0);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedAppliance ?? "Appliance"} Status"),
        backgroundColor: const Color.fromARGB(255, 65, 103, 167),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedAppliance == "Air Conditioner"
            ? (realtimeData == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataRow("Energy Status", realtimeData!["Energy_Status"].toString()),
                        _buildDataRow("PF Status", realtimeData!["PF_Status"].toString()),
                        GestureDetector(
                          onTap: () => setState(() => showPFChart = !showPFChart),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade100,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(31, 3, 2, 2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Power Factor", style: TextStyle(fontSize: 16)),
                                Text(
                                  double.parse(realtimeData!["Power_Factor"].toString())
                                      .toStringAsFixed(3),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Icon(showPFChart ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        if (showPFChart) _buildPFChart(),
                      ],
                    ),
                  ))
            : const Center(
                child: Text(
                  "Fetching data from cloud...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

Widget _buildPFChart() {
  if (pfDataHistory.isEmpty) return const SizedBox();

  final pfValues = pfDataHistory.map((entry) => double.parse(entry['pf'].toString())).toList();
  final minY = (pfValues.reduce((a, b) => a < b ? a : b) - 0.02).clamp(0.8, 1.0);
  final maxY = (pfValues.reduce((a, b) => a > b ? a : b) + 0.02).clamp(0.9, 1.1);

  return Container(
    height: 300,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black),
    ),
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: (pfDataHistory.length - 1).toDouble().clamp(0, 9),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < pfDataHistory.length) {
                  final time = DateTime.parse(pfDataHistory[index]['timestamp']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.01,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
            spots: pfValues
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                .toList(),
          ),
        ],
      ),
    ),
  );
}
}