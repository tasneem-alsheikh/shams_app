import 'package:flutter/material.dart';

import 'dashboard.dart'; // Import the DashboardPage

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedIllness;
  String? _selectedMedication;

  final List<String> illnesses = [
    '❤️ Heart Disease', '🧠 Strokes', '🌬️ Asthma', '😷 COPD', '🍭 Diabetes',
    '🦋 Thyroid Disorders', '⚡ Epilepsy', '🧑‍🦽 Parkinson’s Disease', '🦵 Multiple Sclerosis (MS)',
    '🌞 Lupus', '🌅 Vitiligo', '🧴 Psoriasis & Eczema', '🏥 Chronic Kidney Disease (CKD)',
    '🤰 Pregnancy', '⚖️ Obesity'
  ];

  final List<String> medications = [
    '💧 Diuretics', '❤️ Blood Pressure & Heart Medications', '🧠 Psychiatric Medications',
    '🩸 Diabetes Medications', '⚡ Neurological Medications', '🤧 Allergy & Cold Medications',
    '⚖️ Hormonal Medications'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Center the title
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD89E00), // Golden amber color
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xFFD89E00), // Amber color for the back arrow
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center everything in the body
            children: [
              const SizedBox(height: 40),
              // Logo below the title, centered
              Image.asset(
                'assets/logo.jpg', // Update with your actual logo path
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20), // Space between logo and form fields

              // First Name and Last Name fields side by side
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      textAlign: TextAlign.center, // Centered text
                      decoration: InputDecoration(
                        hintText: 'First Name',
                        filled: true,
                        fillColor: Colors.grey.shade300, // Grey background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      textAlign: TextAlign.center, // Centered text
                      decoration: InputDecoration(
                        hintText: 'Last Name',
                        filled: true,
                        fillColor: Colors.grey.shade300, // Grey background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email input
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center, // Centered text
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password input
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center, // Centered text
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // Gender input
              TextField(
                controller: _genderController,
                textAlign: TextAlign.center, // Centered text
                decoration: InputDecoration(
                  hintText: 'Gender',
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Age input
              TextField(
                controller: _ageController,
                textAlign: TextAlign.center, // Centered text
                decoration: InputDecoration(
                  hintText: 'Age',
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Weight input
              TextField(
                controller: _weightController,
                textAlign: TextAlign.center, // Centered text
                decoration: InputDecoration(
                  hintText: 'Weight (kg)',
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Illnesses dropdown
              DropdownButtonFormField<String>(
                value: _selectedIllness,
                hint: const Text('Any Illnesses triggered by excessive heat?'),
                items: illnesses.map((String illness) {
                  return DropdownMenuItem<String>( 
                    value: illness,
                    child: Row(
                      children: [
                        Text(illness.split(' ')[0]), // Display emoji on the left
                        const SizedBox(width: 10),
                        Text(illness.split(' ').sublist(1).join(' ')),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedIllness = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Medications dropdown
              DropdownButtonFormField<String>(
                value: _selectedMedication,
                hint: const Text('Any Medications you are using currently?'),
                items: medications.map((String medication) {
                  return DropdownMenuItem<String>( 
                    value: medication,
                    child: Row(
                      children: [
                        Text(medication.split(' ')[0]), // Display emoji on the left
                        const SizedBox(width: 10),
                        Text(medication.split(' ').sublist(1).join(' ')),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMedication = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300, // Grey background
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the Dashboard page when sign-up is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD89E00), // Golden amber color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
