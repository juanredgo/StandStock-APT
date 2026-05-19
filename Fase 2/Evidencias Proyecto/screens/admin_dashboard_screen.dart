import 'package:flutter/material.dart';
import 'package:standstock_app/screens/gestion_productos_screen.dart';
import 'package:standstock_app/screens/gestion_usuarios_screen.dart';
import 'package:standstock_app/screens/gestion_stands_screen.dart';
import 'package:standstock_app/screens/reportes_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("Panel de Administrador", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenido, Administrador",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Gestiona todo el sistema desde aquí",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),

            _buildAdminOption(
              icon: Icons.inventory,
              title: "Gestionar Productos",
              subtitle: "Agregar, editar y eliminar productos",
              color: const Color(0xFF00B74A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionProductosScreen(standId: ''))),
            ),
            const SizedBox(height: 16),

            _buildAdminOption(
              icon: Icons.people,
              title: "Gestionar Usuarios",
              subtitle: "Vendedores y administradores",
              color: const Color(0xFF007AFF),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionUsuariosScreen())),
            ),
            const SizedBox(height: 16),

            _buildAdminOption(
              icon: Icons.store,
              title: "Gestionar Stands",
              subtitle: "Rotación y configuración de stands",
              color: const Color(0xFFFF9500),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionStandsScreen())),
            ),
            const SizedBox(height: 16),

            _buildAdminOption(
              icon: Icons.analytics,
              title: "Reportes y Estadísticas",
              subtitle: "Ventas, stock y movimientos",
              color: const Color(0xFFAF52DE),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportesScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}