import 'package:flutter/material.dart';
import 'package:standstock_app/screens/escanear_screen.dart';
import 'package:standstock_app/screens/alertas_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';

class DashboardVendedorScreen extends StatefulWidget {
  const DashboardVendedorScreen({super.key});

  @override
  State<DashboardVendedorScreen> createState() => _DashboardVendedorScreenState();
}

class _DashboardVendedorScreenState extends State<DashboardVendedorScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic> _kpis = {'stockTotal': 0, 'stockBajo': 0, 'ventasHoy': 0};
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKPIs();
  }

  Future<void> _loadKPIs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getStockSummary();
      setState(() {
        _kpis = data;
      });
    } catch (e) {
      print('Error cargando KPIs: $e');
      setState(() {
        _errorMessage = "Sin conexión a Firestore.\nUsando datos de prueba.";
        _kpis = {'stockTotal': 248, 'stockBajo': 7, 'ventasHoy': 184500};
      });
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
        title: const Text("Stand Mall Costanera", style: TextStyle(fontSize: 18, color: Colors.white70)),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                    child: const Text("4", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertasScreen())),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bienvenido,\nJuan", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
            const SizedBox(height: 40),

            if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange, size: 48),
                    const SizedBox(height: 12),
                    Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadKPIs, child: const Text("Reintentar")),
                  ],
                ),
              )
            else if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF00B74A)))
            else
              Column(
                children: [
                  _buildKPICard("Stock Total:", "${_kpis['stockTotal']}", const Color(0xFF00B74A)),
                  const SizedBox(height: 16),
                  _buildKPICard("Stock Bajo:", "${_kpis['stockBajo']}", const Color(0xFFFF3B30)),
                  const SizedBox(height: 16),
                  _buildKPICard("Ventas Hoy:", "\$${_kpis['ventasHoy']}", const Color(0xFF00B74A)),
                ],
              ),

            const Spacer(flex: 2),

            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EscanearScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B74A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.black, size: 32),
                    SizedBox(width: 16),
                    Text("Escanear Producto", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}