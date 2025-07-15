// lib/screens/add_medicine_screen.dart

import 'package:chronictech/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  String? _selectedFrequency;
  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'As needed',
    'Before bed',
  ];

  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedicine() async {
    // --- DEBUG PRINT 1 ---
    print("DEBUG: Save Medicine button pressed.");

    if (_formKey.currentState!.validate()) {
      // --- DEBUG PRINT 2 ---
      print("DEBUG: Form is valid.");

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("DEBUG: Error - User is not logged in.");
        return;
      }

      final newMedicine = Medicine(
        name: _nameController.text,
        dosage: _dosageController.text,
        frequency: _selectedFrequency!,
      );

      try {
        // --- DEBUG PRINT 3 ---
        print("DEBUG: Attempting to save data to Firestore...");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .add(newMedicine.toJson());
        // --- DEBUG PRINT 4 ---
        print("DEBUG: Data saved to Firestore successfully.");
      } catch (e) {
        // --- DEBUG PRINT 5 ---
        print("DEBUG: Error saving to Firestore: $e");
        return; // Stop if there's an error
      }

      // --- Schedule notification if a time was selected ---
      if (_selectedTime != null) {
        final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
          100000,
        );
        // --- DEBUG PRINT 6 ---
        print(
          "DEBUG: Attempting to schedule notification with ID $notificationId for time: $_selectedTime",
        );

        await NotificationService().scheduleDailyNotification(
          id: notificationId,
          title: 'Medication Reminder',
          body:
              'It\'s time to take your ${_nameController.text} (${_dosageController.text}).',
          notificationTime: _selectedTime!,
        );
        // --- DEBUG PRINT 7 ---
        print("DEBUG: Notification scheduling function called successfully.");
      } else {
        // --- DEBUG PRINT 8 ---
        print("DEBUG: No time was selected. Skipping notification scheduling.");
      }

      if (mounted) Navigator.of(context).pop();
    } else {
      // --- DEBUG PRINT 9 ---
      print("DEBUG: Form is invalid.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Code remains the same...
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Medicine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 500mg)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a dosage' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: _frequencies
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedFrequency = newValue),
                validator: (value) =>
                    value == null ? 'Please select a frequency' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Set Reminder Time (Optional)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No time set'
                          : _selectedTime!.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('SELECT TIME'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  child: const Text('Save Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
