import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // From old splash
import 'package:cloud_firestore/cloud_firestore.dart'; // From old splash

// Import paths adjusted based on your old splash page's imports
import 'package:carpooling/intro.dart'; // Assuming OnBoardingPage is here
import 'package:carpooling/views/admin/admin_dashboard_page.dart';
import 'package:carpooling/views/auth/login_page.dart';
import 'package:carpooling/widgets/main_navigator.dart';




class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1500,
      ), // Duration for logo scale/fade
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            Curves
                .elasticOut, 
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start the animations
    _controller.forward();

    // After the animation finishes, navigate based on authentication
    // The 3-second delay allows the splash screen animation to fully play out
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Ensure widget is still active before navigation
        _navigateBasedOnAuth();
      }
    });
  }

 


  // --- Integrated from your old SplashPage logic ---
  Future<void> _navigateBasedOnAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in, go to OnBoardingPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingPage()),
      );
      return;
    }

    // User is logged in, check role
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = userDoc.data();
      final role = data?['role'];

      


      if (role == 'admin') {
        // Navigate to Admin Dashboard if admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
        );
      } else {
        // Navigate to Main Navigator for regular users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      }
    } catch (e) {
      // If there's an error fetching role (e.g., user doc doesn't exist or no role)
      // or any other Firebase/Firestore error, navigate to login page.
      print(
        "Error fetching user role or other auth issue: $e",
      ); // For debugging
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
  // --- End of integrated logic ---

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SvgPicture.asset('assets/images/chingooo.svg', color: Colors.blue,),
            ),
          ),
        ),
      ),
    );
  }
}
