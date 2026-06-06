import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:standstock_app/screens/admin_dashboard_screen.dart';
import 'package:standstock_app/screens/gestion_productos_screen.dart';
import 'package:standstock_app/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  print("✅ Firebase inicializado correctamente");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StandStock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B74A)),
        useMaterial3: true,
      ),
      home: const AdminDashboardScreen(),   // Ahora sí reconoce la clase
    );
  }
}