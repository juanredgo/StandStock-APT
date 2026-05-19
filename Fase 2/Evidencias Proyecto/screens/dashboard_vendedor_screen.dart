import 'package:flutter/material.dart';
import 'package:standstock_app/screens/escanear_screen.dart';
import 'package:standstock_app/screens/alertas_screen.dart';
import 'package:standstock_app/screens/inventario_screen.dart';
import 'package:standstock_app/screens/movimientos_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/screens/login_screen.dart';

class DashboardVendedorScreen extends StatefulWidget {
  final String standId;   // ← Ahora recibe el stand del vendedor

  const DashboardVendedorScreen({super.key, required this.standId});

  @override
  State<DashboardVendedorScreen> createState() => _DashboardVendedorScreenState();
}

class _DashboardVendedorScreenState extends State<DashboardVendedorScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic> _kpis = {'stockTotal': 0, 'stockBajo': 0, 'ventasHoy': 184500};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadKPIs();
  }

  Future<void> _loadKPIs() async { /* ... mismo código ... */ }

  Future<void> _logout() async { /* ... mismo código ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text("Stand Mall Costanera", style: TextStyle(color: Colors.white70)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertasScreen()))),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenido,\nJuan", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
            const SizedBox(height: 40),

            _buildKPICard("Stock Total:", _kpis['stockTotal'].toString(), const Color(0xFF00B74A)),
            const SizedBox(height: 16),
            _buildKPICard("Stock Bajo:", _kpis['stockBajo'].toString(), Colors.orange),
            const SizedBox(height: 16),
            _buildKPICard("Ventas Hoy:", "\$${_kpis['ventasHoy']}", const Color(0xFF00B74A)),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EscanearScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 8),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.black, size: 32), SizedBox(width: 16), Text("Escanear Producto", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black))]),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioScreen(standId: widget.standId))),
                    icon: const Icon(Icons.inventory, color: Colors.black),
                    label: const Text("Ver Inventario", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MovimientosScreen())),
                    icon: const Icon(Icons.history, color: Colors.black),
                    label: const Text("Ver Movimientos", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, Color valueColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, color: Colors.white70)), Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor))]),
    );
  }
}