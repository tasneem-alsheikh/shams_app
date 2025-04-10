import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For jsonEncode

class SignUpPart2 extends StatefulWidget {
  const SignUpPart2({Key? key}) : super(key: key);

  @override
  _SignUpPart2State createState() => _SignUpPart2State();
}

class _SignUpPart2State extends State<SignUpPart2> {
  String? _selectedGender;
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  List<String> _selectedIllnesses = [];
  List<String> _selectedMedications = [];
  bool _isLoading = false;

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> illnesses = [
    'Heart Disease', 'Strokes', 'Asthma', 'COPD', 'Diabetes',
    'Thyroid Disorders', 'Epilepsy', 'Parkinson’s Disease', 'Multiple Sclerosis',
    'Lupus', 'Vitiligo', 'Psoriasis', 'Chronic Kidney Disease', 'None'
  ];
  final List<String> medications = [
    'Diuretics', 'Blood Pressure Medications', 'Psychiatric Medications',
    'Diabetes Medications', 'Neurological Medications', 'Allergy Medications',
    'Hormonal Medications', 'None'
  ];

  Future<void> _completeSignUp() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('gender', _selectedGender ?? '');
    await prefs.setString('age', _ageController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setStringList('illnesses', _selectedIllnesses);
    await prefs.setStringList('medications', _selectedMedications);

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD89E00)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
              const Text(
                'Health Information',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFD89E00)),
              ),
              const SizedBox(height: 8),
              Text('Part 2 of 2', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 40),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                value: _selectedGender,
                items: genderOptions.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _buildMultiSelect('Heat-Sensitive Illnesses', illnesses, _selectedIllnesses),
              const SizedBox(height: 16),
              _buildMultiSelect('Heat/Sun-Sensitive Medications', medications, _selectedMedications),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD89E00),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Complete Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelect(String title, List<String> options, List<String> selectedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMultiSelectDialog(title, options, selectedList),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedList.isEmpty ? "Select options" : selectedList.join(", "),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectDialog(String title, List<String> options, List<String> selectedList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: selectedList.contains(option),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) selectedList.add(option);
                          else selectedList.remove(option);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
        );
      },
    );
  }
}