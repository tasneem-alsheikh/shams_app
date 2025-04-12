import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _proceedToPart2() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstName', _firstNameController.text.trim());
    await prefs.setString('lastName', _lastNameController.text.trim());
    await prefs.setString('email', _emailController.text.trim().toLowerCase());
    await prefs.setString('password', _passwordController.text.trim());

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pushNamed(context, '/sign_up_part2');
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                      'Create Account',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Part 1 of 2',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        hintText: 'John',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Doe',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '• • • • • • • •',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    // Password strength indicator
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 24),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Password must be at least 6 characters',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Continue button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _proceedToPart2,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Continue'),
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
}