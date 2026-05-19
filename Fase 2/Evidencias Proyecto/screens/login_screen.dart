import 'package:flutter/material.dart';
import 'package:standstock_app/screens/dashboard_vendedor_screen.dart';
import 'package:standstock_app/screens/forgot_password_screen.dart';
import 'package:standstock_app/screens/register_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isVendedor = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Text(
                  "StandStock",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00B74A),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isVendedor ? "Inicia sesión como vendedor" : "Inicia sesión como administrador",
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),

              const SizedBox(height: 60),

              const Text("Email", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Contraseña", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Selección de rol
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isVendedor = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVendedor ? const Color(0xFF00B74A) : const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Soy Vendedor", style: TextStyle(color: _isVendedor ? Colors.black : Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isVendedor = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isVendedor ? const Color(0xFF00B74A) : const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Soy Administrador", style: TextStyle(color: !_isVendedor ? Colors.black : Colors.white)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final service = FirebaseService();
                      final user = await service.signInWithEmail(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      if (user != null && mounted) {
                        final standId = await service.getUserStandId(user.uid);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => DashboardVendedorScreen(standId: standId)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B74A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Ingresar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFF00B74A))),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text("¿No tienes cuenta? Crear cuenta", style: TextStyle(color: Color(0xFF00B74A))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}