// lib/screens/add_symptom_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/symptom_model.dart'
    as sm; // Using a prefix 'sm' for our model

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomNameController = TextEditingController();
  final _notesController = TextEditingController();

  double _intensity = 5.0;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _symptomNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- SAVE FUNCTION UPDATED FOR FIRESTORE ---
  Future<void> _saveSymptom() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User logged in nahi hai to error show karein
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to save symptoms.'),
          ),
        );
        return;
      }

      // 1. Symptom object banayein
      final newSymptom = sm.Symptom(
        name: _symptomNameController.text,
        intensity: _intensity.toInt(),
        notes: _notesController.text,
        timestamp: Timestamp.fromDate(_selectedDate),
      );

      // 2. Firestore mein save karein
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('symptoms')
            .add(newSymptom.toJson());

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save symptom: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI code wesa hi rahega...
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Symptom')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _symptomNameController,
                decoration: const InputDecoration(
                  labelText: 'Symptom Name (e.g., Headache)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a symptom name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Intensity: ${_intensity.toInt()}/10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _intensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _intensity.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _intensity = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSymptom,
                  child: const Text('Save Symptom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
