import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    String? storedEmail = prefs.getString('email');
    String? storedPassword = prefs.getString('password');

    String inputEmail = _emailController.text.trim().toLowerCase();
    String inputPassword = _passwordController.text.trim();

    await Future.delayed(const Duration(milliseconds: 800));

    if (storedEmail == null || storedPassword == null) {
      if (mounted) {
        _showSnackBar('No account found. Please sign up first.', isError: true);
      }
    } else if (storedEmail == inputEmail && storedPassword == inputPassword) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      if (mounted) {
        _showSnackBar('Invalid email or password', isError: true);
      }
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
                    Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Image.asset(
                        'assets/logo.jpg',
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'S',
                                style: textTheme.headlineLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),

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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showSnackBar('Forgot password feature coming soon!');
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.g_mobiledata, 'Google'),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.apple, 'Apple'),
                      ],
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

  Widget _buildSocialButton(IconData icon, String platform) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          _showSnackBar('$platform login coming soon!');
        },
        icon: Icon(icon, size: 20),
        label: Text(
          platform,
          style: textTheme.bodyMedium,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          foregroundColor: Colors.black87,
          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}