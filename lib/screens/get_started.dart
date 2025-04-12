import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fixed Logo - Center it properly
                  Center(
                    child: Container(
                      width: 100, // Reduced size from 120 to 100
                      height: 100, // Reduced size from 120 to 100
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50), // Adjusted to match new size
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 100, // Explicitly set width
                          height: 100, // Explicitly set height
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD89E00).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  'S',
                                  style: GoogleFonts.nunito(
                                    textStyle: textTheme.headlineLarge?.copyWith(
                                      color: const Color(0xFFD89E00),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'SHAMS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      textStyle: textTheme.displayMedium?.copyWith(
                        color: const Color(0xFFD89E00),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  Text(
                    'Your Personal Weather Companion',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      textStyle: textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Get Started button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD89E00),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New here?',
                        style: GoogleFonts.nunito(
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                        child: Text(
                          'Create an Account',
                          style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                              color: Color(0xFFD89E00),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Footer
                  Text(
                    "Sun's Out, Safety On",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      textStyle: textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}