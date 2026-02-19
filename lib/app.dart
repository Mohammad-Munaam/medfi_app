import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'services/admin_service.dart';

class MedfiApp extends StatelessWidget {
  const MedfiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDFI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A8F5A),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A8F5A),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A8F5A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // User is logged in → determine role-based routing
          return _RoleRouter(user: snapshot.data!);
        },
      ),
    );
  }
}

/// Fetches user role from Firestore and routes accordingly
class _RoleRouter extends StatefulWidget {
  final User user;
  const _RoleRouter({required this.user});

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final role = await _adminService.getUserRole(widget.user.uid);
      if (!mounted) return;
      setState(() {
        _role = role;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _role = 'user';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (_role == 'admin') {
      return const AdminDashboardScreen();
    }

    return const HomeScreen();
  }
}
