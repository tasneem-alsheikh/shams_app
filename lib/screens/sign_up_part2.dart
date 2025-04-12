import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _formKey = GlobalKey<FormState>();

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> illnesses = [
    'Heart Disease', 'Strokes', 'Asthma', 'COPD', 'Diabetes',
    'Thyroid Disorders', 'Epilepsy', 'Parkinson’s Disease', 'Multiple Sclerosis',
    'Lupus', 'Vitiligo', 'Psoriasis', 'Chronic Kidney Disease', 'Pregnant', 'None'
  ];
  final List<String> medications = [
    'Diuretics', 'Blood Pressure Medications', 'Psychiatric Medications',
    'Diabetes Medications', 'Neurological Medications', 'Allergy Medications',
    'Hormonal Medications', 'None'
  ];

  List<String> getFilteredIllnesses() {
    if (_selectedGender == 'Female') {
      return illnesses;
    } else {
      return illnesses.where((illness) => illness != 'Pregnant').toList();
    }
  }

  Future<void> _completeSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('gender', _selectedGender ?? '');
    await prefs.setString('age', _ageController.text.trim());
    await prefs.setString('weight', _weightController.text.trim());
    await prefs.setStringList('illnesses', _selectedIllnesses);
    await prefs.setStringList('medications', _selectedMedications);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Container(
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'S',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Health Information',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Part 2 of 2',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Gender
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      value: _selectedGender,
                      items: genderOptions
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          if (value != 'Female' &&
                              _selectedIllnesses.contains('Pregnant')) {
                            _selectedIllnesses.remove('Pregnant');
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Age
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: '30',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: '70',
                        prefixIcon: Icon(Icons.fitness_center_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Illnesses
                    _buildMultiSelect(
                        'Heat-Sensitive Illnesses', getFilteredIllnesses(), _selectedIllnesses),
                    const SizedBox(height: 16),

                    // Medications
                    _buildMultiSelect(
                        'Heat/Sun-Sensitive Medications', medications, _selectedMedications),
                    const SizedBox(height: 24),

                    // Complete button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _completeSignUp,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Complete Sign Up'),
                    ),
                    const SizedBox(height: 24),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),

                    // Terms
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelect(String title, List<String> options, List<String> selectedList) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMultiSelectDialog(title, options, selectedList),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedList.isEmpty ? 'Select options' : selectedList.join(', '),
                    style: textTheme.bodyMedium?.copyWith(
                      color: selectedList.isEmpty ? Colors.black54 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectDialog(String title, List<String> options, List<String> selectedList) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            title,
            style: textTheme.titleLarge,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: selectedList.contains(option),
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) selectedList.add(option);
                          else selectedList.remove(option);
                        });
                        this.setState(() {});
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}