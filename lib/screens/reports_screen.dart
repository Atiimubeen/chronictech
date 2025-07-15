// lib/screens/reports_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A new class to hold our processed report data
class SymptomReportData {
  final Map<String, double> frequencyData;
  final List<FlSpot> intensityData;

  SymptomReportData({required this.frequencyData, required this.intensityData});
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

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
        .orderBy(
          'timestamp',
          descending: false,
        ) // Order by date for the line chart
        .get();

    // Process data for both charts in one go
    final Map<String, double> frequencyMap = {};
    final List<FlSpot> intensitySpots = [];

    for (var doc in snapshot.docs) {
      final symptomName = doc.data()['name'] as String;
      final intensity = (doc.data()['intensity'] as int).toDouble();
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();

      // For Bar Chart (Frequency)
      frequencyMap[symptomName] = (frequencyMap[symptomName] ?? 0) + 1;

      // For Line Chart (Intensity over Time)
      // X-axis is the day of the month, Y-axis is the intensity
      intensitySpots.add(FlSpot(timestamp.day.toDouble(), intensity));
    }

    return SymptomReportData(
      frequencyData: frequencyMap,
      intensityData: intensitySpots,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Health Reports')),
      body: FutureBuilder<SymptomReportData>(
        future: _getSymptomReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading reports: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.frequencyData.isEmpty) {
            return Center(
              child: Text(
                'Not enough data from the last 7 days to generate a report.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          final reportData = snapshot.data!;
          final frequencyData = reportData.frequencyData;
          final mostFrequentSymptom = frequencyData.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(context, mostFrequentSymptom),
                const SizedBox(height: 24),

                // Frequency Bar Chart
                _buildBarChartCard(context, frequencyData),
                const SizedBox(height: 24),

                // NEW: Intensity Line Chart
                if (reportData.intensityData.isNotEmpty)
                  _buildLineChartCard(context, reportData.intensityData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    MapEntry<String, double> mostFrequentSymptom,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text('Your most frequent symptom was:'),
            Text(
              '"${mostFrequentSymptom.key}"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Logged ${mostFrequentSymptom.value.toInt()} times in the last 7 days.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, Map<String, double> dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptom Frequency',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BarChart(
                // Bar chart data here (same as before)
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: dataMap.values.reduce((a, b) => a > b ? a : b) + 2,
                  barGroups: dataMap.entries.map((entry) {
                    int index = dataMap.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.teal,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final text = dataMap.keys.toList()[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              text.length > 3 ? text.substring(0, 3) : text,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // NEW WIDGET FOR LINE CHART
  Widget _buildLineChartCard(BuildContext context, List<FlSpot> spots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptom Intensity Trend (Last 7 Days)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 11,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 2,
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 2,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.teal.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
