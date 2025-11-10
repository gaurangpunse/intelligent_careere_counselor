import 'package:flutter/material.dart';
import 'package:intelligent_career_counselling/services/auth_service.dart';
import 'package:intelligent_career_counselling/views/dashboard_page.dart';
import 'package:intelligent_career_counselling/views/login_page.dart';
import 'package:intelligent_career_counselling/views/signup_page.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  // Initialize auth service and start listening
  AuthService.instance.listenToAuthChanges();

  runApp(const CareerCounsellorApp());
}

class CareerCounsellorApp extends StatelessWidget {
  const CareerCounsellorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intelligent Career Counsellor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/': (_) => const DashboardPage(), // Add home route
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
      onUnknownRoute: (settings) {
        // Handle unknown routes gracefully by redirecting to dashboard
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      },
    );
  }
}
