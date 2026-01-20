import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/home_page.dart';
import 'package:todo_app/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wpulcqamexniaoqrtirf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwdWxjcWFtZXhuaWFvcXJ0aXJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODMxNTEsImV4cCI6MjA4MzI1OTE1MX0.5qzlxMTq7L8kN8ClelGjXi147dj-JCZP-O3utTydluE',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Todo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _handleAuthRedirect();
  }

  Future<void> _handleAuthRedirect() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _redirecting = true;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_redirecting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // If no session, show LoginPage.
    // Ideally we should listen to auth state changes but for simplicity checking on start is often enough for simple apps
    // However, to be robust, let's just default to LoginPage and let LoginPage handle the logged-in state or use a StreamBuilder in a real app.
    // But per requirements: "Automatic session check on app start" and "Redirect to HomePage if user already logged in".

    // We can just return LoginPage. If the user is logged in, the above _handleAuthRedirect will push HomePage.
    // Actually, a better way is to use a StreamBuilder on onAuthStateChange, but the requirement 6 says "Session check using currentSession".

    // So if session is null, we show LoginPage.
    if (supabase.auth.currentSession != null) {
      // We might have already redirected in initState, but to avoid flash of login page:
      return const HomePage();
    }

    return const LoginPage();
  }
}
