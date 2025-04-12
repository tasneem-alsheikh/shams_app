import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/get_started.dart';
import 'screens/login_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/sign_up_part2.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const ShamsApp());
}

class ShamsApp extends StatelessWidget {
  const ShamsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shams',
      theme: ThemeData(
        primaryColor: const Color(0xFFD89E00),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineLarge: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade600,
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD89E00),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD89E00),
            textStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD89E00), width: 2),
          ),
          labelStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIconColor: Colors.grey.shade600,
          suffixIconColor: Colors.grey.shade600,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFD89E00),
          secondary: Colors.grey.shade300,
        ),
        useMaterial3: true,
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