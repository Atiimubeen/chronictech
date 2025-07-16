// lib/screens/main_layout.dart

import 'package:chronictech/screens/home_screen.dart';
import 'package:chronictech/screens/medicines_screen.dart';
import 'package:chronictech/screens/profile_screen.dart';
import 'package:chronictech/screens/reports_screen.dart';
import 'package:chronictech/screens/symptoms_screen.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // This tracks the currently selected tab

  // --- CHANGE: The list of screens is now correct ---
  // It uses ProfileScreen(), not EditProfileScreen().
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SymptomsScreen(),
    MedicinesScreen(),
    ReportsScreen(),
    ProfileScreen(), // This is the main profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sick_outlined),
            label: 'Symptoms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        onTap: _onItemTapped,
      ),
    );
  }
}
