import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';

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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Inventario", style: TextStyle(color: textColor)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
          ? Center(
        child: Text(
          "No hay productos en este stand",
          style: TextStyle(color: mutedColor, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final p = _productos[index];
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p['nombre'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text("SKU: ${p['sku']} • \$${p['precio']}", style: TextStyle(color: mutedColor)),
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