import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic> _kpis = {};

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    final data = await _service.getStockSummary();
    setState(() => _kpis = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(backgroundColor: const Color(0xFF1C1C1E),iconTheme: const IconThemeData(color: Colors.white), title: const Text("Reportes y Estadísticas", style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildKPICard("Stock Total", _kpis['stockTotal']?.toString() ?? "248", const Color(0xFF00B74A)),
            const SizedBox(height: 16),
            _buildKPICard("Stock Bajo", _kpis['stockBajo']?.toString() ?? "7", Colors.orange),
            const SizedBox(height: 16),
            _buildKPICard("Ventas Hoy", "\$${_kpis['ventasHoy'] ?? 184500}", const Color(0xFF00B74A)),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}