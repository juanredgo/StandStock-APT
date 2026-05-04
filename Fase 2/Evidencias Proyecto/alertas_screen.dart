import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _alertas = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getLowStockAlerts();
      setState(() {
        _alertas = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "No se pudieron cargar las alertas.";
      });
      print('Error cargando alertas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Text("Alertas de Stock", style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(width: 12),
            CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFFF3B30),
              child: Text("4", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B74A)))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _cargarAlertas, child: const Text("Reintentar")),
          ],
        ),
      )
          : _alertas.isEmpty
          ? const Center(
        child: Text(
          "No hay alertas de stock bajo en este momento",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _alertas.length,
        itemBuilder: (context, index) {
          final alerta = _alertas[index];
          return _buildAlertaCard(
            nombre: alerta['nombre'],
            sku: alerta['sku'],
            stockActual: alerta['stock_actual'],
          );
        },
      ),
    );
  }

  Widget _buildAlertaCard({
    required String nombre,
    required String sku,
    required int stockActual,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        border: Border.all(color: const Color(0xFFFF3B30), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text("SKU: $sku", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Stock actual:", style: TextStyle(color: Colors.white70)),
                  Text(
                    "$stockActual unidades",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF9500)),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text("¡Stock Bajo! ", style: TextStyle(fontSize: 18, color: Color(0xFFFF3B30))),
                  Icon(Icons.local_fire_department, color: Color(0xFFFF3B30), size: 28),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marcado como resuelto")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B74A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Marcar como resuelto",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}