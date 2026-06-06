import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/screens/gestion_productos_screen.dart';
import 'package:standstock_app/screens/gestion_usuarios_screen.dart';
import 'package:standstock_app/screens/gestion_stands_screen.dart';
import 'package:standstock_app/screens/reportes_screen.dart';
import 'package:standstock_app/screens/login_screen.dart'; // ← Agregado para logout correcto
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:standstock_app/screens/settings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Panel de Administrador", style: TextStyle(color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor,
                  title: Text("Cerrar sesión", style: TextStyle(color: textColor)),
                  content: Text("¿Estás seguro de cerrar sesión?", style: TextStyle(color: mutedColor)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancelar", style: TextStyle(color: mutedColor)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Cerrar sesión", style: TextStyle(color: textColor)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final service = FirebaseService();
                await service.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text("Bienvenido,", style: TextStyle(fontSize: 28, color: mutedColor)),
          Text("Administrador", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          Text("Gestiona todo el sistema desde aquí", style: TextStyle(fontSize: 16, color: mutedColor)),
          const SizedBox(height: 40),

          _buildAdminOption(
            context: context,
            icon: Icons.inventory_2,
            title: "Gestionar Productos",
            subtitle: "Agregar, editar y eliminar productos",
            color: const Color(0xFF00B74A),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionProductosScreen(standId: ''))),
          ),
          const SizedBox(height: 16),

          _buildAdminOption(
            context: context,
            icon: Icons.people,
            title: "Gestionar Usuarios",
            subtitle: "Vendedores y administradores",
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionUsuariosScreen())),
          ),
          const SizedBox(height: 16),

          _buildAdminOption(
            context: context,
            icon: Icons.store,
            title: "Gestionar Stands",
            subtitle: "Rotación y configuración de stands",
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionStandsScreen())),
          ),
          const SizedBox(height: 16),

          _buildAdminOption(
            context: context,
            icon: Icons.supervisor_account,
            title: "Supervisar Stand",
            subtitle: "Reemplazar vendedor temporalmente (almuerzo, etc.)",
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GestionProductosScreen(
                  standId: '',
                  isSupervisionMode: true,   // ← Esto activa el modo vendedor
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ← NUEVO: Reportes y Estadísticas
          _buildAdminOption(
            context: context,
            icon: Icons.analytics,
            title: "Reportes y Estadísticas",
            subtitle: "Ver estadísticas por stand",
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportesScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: mutedColor, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}