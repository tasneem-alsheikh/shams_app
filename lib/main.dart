import 'package:flutter/material.dart';

import 'screens/dashboard.dart'; // Import the dashboard page
import 'screens/get_started.dart';
import 'screens/login_page.dart'; // Import the login page file
import 'screens/sign_up_page.dart'; // Import the sign-up page file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      initialRoute: '/get_started', // Use initialRoute instead of home for better route management
      routes: {
        '/get_started': (context) => GetStartedPage(),
        '/login': (context) => LoginPage(),
        '/sign_up': (context) => SignUpPage(), // Add this line to link to SignUpPage
        '/dashboard': (context) => DashboardPage(), // Add this line for the Dashboard page
      },
    );
  }
}
