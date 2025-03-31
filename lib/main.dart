import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/get_started.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/sign_up_part2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shams',
      theme: ThemeData(
        primaryColor: const Color(0xFFD89E00),
        scaffoldBackgroundColor: Colors.white, // Pure white
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: '/get_started',
      routes: {
        '/get_started': (context) => const GetStartedPage(),
        '/login': (context) => const LoginPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/sign_up_part2': (context) => const SignUpPart2(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}