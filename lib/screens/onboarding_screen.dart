// lib/screens/onboarding_screen.dart

import 'package:chronictech/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = (index == 2);
              });
            },
            children: const [
              OnboardingPage(
                iconData: Icons.sick_outlined, // Icon for first page
                title: 'Track Your Symptoms',
                description:
                    'Easily log your symptoms and monitor your health trends over time.',
              ),
              OnboardingPage(
                iconData: Icons.bubble_chart_outlined, // Icon for second page
                title: 'Get AI-Powered Insights',
                description:
                    'Our AI analyzes your data to provide actionable insights and reports.',
              ),
              OnboardingPage(
                iconData: Icons.watch_outlined, // Icon for third page
                title: 'Connect Your Wearables',
                description:
                    'Sync with your smart devices for real-time health monitoring.',
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(
                    dotColor: Colors.grey,
                    activeDotColor: Colors.teal,
                  ),
                ),
                _isLastPage
                    ? TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for the page content (updated to use IconData)
class OnboardingPage extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String description;
  const OnboardingPage({
    super.key,
    required this.iconData,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- IMAGE REPLACED WITH A PLACEHOLDER ICON ---
          Icon(iconData, size: 150, color: Colors.teal),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
