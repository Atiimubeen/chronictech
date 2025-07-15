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
  int _selectedIndex = 0; // Yeh track karega ke konsa tab select hua hai

  // Sabhi screens ki list
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SymptomsScreen(),
    MedicinesScreen(),
    ReportsScreen(),
    ProfileScreen(),
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
        selectedItemColor: Colors.teal, // Selected item ka color
        unselectedItemColor: Colors.grey, // Unselected items ka color
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
