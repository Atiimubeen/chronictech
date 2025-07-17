// lib/screens/reports_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// A class to hold our processed report data
class SymptomReportData {
  final Map<int, double> frequencyData; // Day of week -> Count
  final List<FlSpot> intensityData; // Day of week -> Avg Intensity

  SymptomReportData({required this.frequencyData, required this.intensityData});
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late Future<SymptomReportData> _reportDataFuture;

  @override
  void initState() {
    super.initState();
    _reportDataFuture = _getSymptomReportData();
  }

  // This function fetches and processes the data
  Future<SymptomReportData> _getSymptomReportData() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('symptoms')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
        )
        .orderBy('timestamp', descending: false)
        .get();

    final Map<int, double> frequencyMap = {};
    final List<FlSpot> intensitySpots = [];
    final Map<int, double> dailyTotalIntensity = {};
    final Map<int, int> dailyEntryCount = {};

    for (var doc in snapshot.docs) {
      final intensity = (doc.data()['intensity'] as int).toDouble();
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
      final dayOfWeek = timestamp.weekday; // Monday = 1, Sunday = 7

      // For Bar Chart (Frequency per day)
      frequencyMap[dayOfWeek] = (frequencyMap[dayOfWeek] ?? 0) + 1;

      // For Line Chart (Intensity over Time)
      dailyTotalIntensity[dayOfWeek] =
          (dailyTotalIntensity[dayOfWeek] ?? 0) + intensity;
      dailyEntryCount[dayOfWeek] = (dailyEntryCount[dayOfWeek] ?? 0) + 1;
    }

    dailyTotalIntensity.forEach((day, totalIntensity) {
      final count = dailyEntryCount[day]!;
      final average = totalIntensity / count;
      intensitySpots.add(FlSpot(day.toDouble(), average));
    });

    intensitySpots.sort((a, b) => a.x.compareTo(b.x));

    return SymptomReportData(
      frequencyData: frequencyMap,
      intensityData: intensitySpots,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // centerTitle: true,
        // leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<SymptomReportData>(
        future: _reportDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading reports: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData ||
              (snapshot.data!.frequencyData.isEmpty &&
                  snapshot.data!.intensityData.isEmpty)) {
            return const Center(
              child: Text(
                'Log symptoms to see your health insights.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final reportData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Insights',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildLineChartCard(context, reportData.intensityData),
                const SizedBox(height: 24),

                _buildBarChartCard(context, reportData.frequencyData),
                const SizedBox(height: 24),

                _buildInsightRow(
                  'Medication Adherence',
                  '95% adherence rate over the past month. Keep up the good work!',
                  'assets/images/medicines.png',
                ),
                const SizedBox(height: 16),
                _buildInsightRow(
                  'Symptom Tracking',
                  'Consistent tracking of symptoms helps in better understanding your health.',
                  'assets/images/symptoms.png',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildLineChartCard(BuildContext context, List<FlSpot> spots) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final averageIntensity =
        spots.map((spot) => spot.y).reduce((a, b) => a + b) / spots.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Intensity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                averageIntensity.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '+2%',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Last 7 Days',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: _bottomTitleWidgets,
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.black,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, Map<int, double> dataMap) {
    if (dataMap.isEmpty) return const SizedBox.shrink();

    final totalSymptoms = dataMap.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Frequency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalSymptoms.toInt().toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'symptoms logged',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Text(
                'Last 7 Days',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: _bottomTitleWidgets,
                    ),
                  ),
                ),
                barGroups: dataMap.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.grey.shade300,
                        width: 20,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String title, String subtitle, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for chart bottom titles
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, color: Colors.black54);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Tue', style: style);
        break;
      case 3:
        text = const Text('Wed', style: style);
        break;
      case 4:
        text = const Text('Thu', style: style);
        break;
      case 5:
        text = const Text('Fri', style: style);
        break;
      case 6:
        text = const Text('Sat', style: style);
        break;
      case 7:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    // --- THIS IS THE CORRECTED CODE ---
    // The SideTitleWidget is no longer needed in recent versions.
    // Just return the Text widget.
    return text;
  }
}
