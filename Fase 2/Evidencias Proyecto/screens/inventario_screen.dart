import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class InventarioScreen extends StatefulWidget {
  final String standId;   // ← Ahora recibe el stand

  const InventarioScreen({
    super.key,
    required this.standId,
  });

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    setState(() => _isLoading = true);
    _productos = await _service.getProductsByStand(widget.standId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Inventario", style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
          ? const Center(
        child: Text(
          "No hay productos en este stand",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final p = _productos[index];
          return Card(
            color: const Color(0xFF2C2C2E),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("SKU: ${p['sku']} • \$${p['precio']}", style: const TextStyle(color: Colors.white70)),
              trailing: Text(
                "${p['stock_actual']} und",
                style: TextStyle(
                  color: (p['stock_actual'] ?? 0) <= 5 ? Colors.red : const Color(0xFF00B74A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}