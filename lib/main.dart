import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Smart Lamp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2F80ED),
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            return auth.user != null
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
