import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:standstock_app/screens/dashboard_vendedor_screen.dart';
import 'package:standstock_app/screens/admin_dashboard_screen.dart';
import 'package:standstock_app/screens/forgot_password_screen.dart';
import 'package:standstock_app/screens/register_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/screens/settings_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;
    final cardColor = Theme.of(context).cardColor;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings icon (top right)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.settings, color: mutedColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

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
                  "Inicia sesión con tu cuenta",
                  style: TextStyle(color: mutedColor, fontSize: 18),
                ),
              ),

              const SizedBox(height: 32),

              Text("Email", style: TextStyle(color: mutedColor, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: textColor),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text("Contraseña", style: TextStyle(color: mutedColor, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: dividerColor),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: mutedColor),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                        final role = await service.getUserRole(user.uid);
                        final standId = await service.getUserStandId(user.uid);

                        if (role == 'administrador' || role == 'super_administrador') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => DashboardVendedorScreen(standId: standId)),
                          );
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      if (mounted) {
                        String mensaje = "Ocurrió un error al iniciar sesión.";

                        switch (e.code) {
                          case 'user-not-found':
                          case 'wrong-password':
                          case 'invalid-credential':
                          case 'invalid-email':
                            mensaje = "Correo o contraseña incorrectos.";
                            break;
                          case 'too-many-requests':
                            mensaje = "Demasiados intentos fallidos. Intenta más tarde.";
                            break;
                          case 'network-request-failed':
                            mensaje = "Sin conexión a internet. Verifica tu conexión.";
                            break;
                          case 'user-disabled':
                            mensaje = "Esta cuenta ha sido deshabilitada.";
                            break;
                          default:
                            mensaje = "No se pudo iniciar sesión. Intenta nuevamente.";
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(mensaje),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ocurrió un error inesperado."),
                            backgroundColor: Colors.red,
                          ),
                        );
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

              const SizedBox(height: 24),

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