// lib/screens/home_screen.dart

import 'package:chronictech/services/health_service.dart';
import 'package:chronictech/services/insight_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late Future<List<String>> _insightsFuture;
  late Future<int?> _stepsFuture; // Future for steps

  @override
  void initState() {
    super.initState();
    _insightsFuture = InsightService().generateSymptomInsights();
    // In home_screen.dart, inside initState()

    _stepsFuture = HealthService().fetchDailySteps(); // Fetch steps
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = _user?.displayName ?? _user?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(title: Text('Welcome, $displayName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: Daily Activity Card ---
            Text(
              "Daily Activity",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int?>(
              future: _stepsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: ListTile(title: Text('Fetching activity data...')),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.error_outline),
                      title: Text('Could not fetch step data.'),
                      subtitle: Text('Please grant health permissions.'),
                    ),
                  );
                }

                final steps = snapshot.data!;
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.directions_walk,
                      color: Colors.teal,
                      size: 32,
                    ),
                    title: const Text("Today's Steps"),
                    subtitle: Text(
                      steps.toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Health Insights Card
            Text(
              "Your Health Insights",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: _insightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Card(
                    child: ListTile(title: Text('No insights available yet.')),
                  );
                }

                final insights = snapshot.data!;
                return Card(
                  child: Column(
                    children: insights
                        .map(
                          (insight) => ListTile(
                            leading: const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.teal,
                            ),
                            title: Text(insight),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
