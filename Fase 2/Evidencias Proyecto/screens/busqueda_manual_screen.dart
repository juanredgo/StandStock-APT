import 'package:flutter/material.dart';
import 'package:standstock_app/screens/detalle_producto_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';

class BusquedaManualScreen extends StatefulWidget {
  final String standId;   // ← Ahora recibe el stand del vendedor

  const BusquedaManualScreen({
    super.key,
    required this.standId,
  });

  @override
  State<BusquedaManualScreen> createState() => _BusquedaManualScreenState();
}

class _BusquedaManualScreenState extends State<BusquedaManualScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _resultados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buscar(""); // carga inicial solo del stand actual
  }

  Future<void> _buscar(String query) async {
    setState(() => _isLoading = true);

    try {
      // Cargamos solo los productos del stand actual
      final allProducts = await _service.getProductsByStand(widget.standId);

      if (query.trim().isEmpty) {
        _resultados = allProducts;
      } else {
        final lowerQuery = query.toLowerCase();
        _resultados = allProducts.where((p) {
          final nombre = (p['nombre'] ?? '').toLowerCase();
          final sku = (p['sku'] ?? '').toLowerCase();
          return nombre.contains(lowerQuery) || sku.contains(lowerQuery);
        }).toList();
      }
    } catch (e) {
      print('Error en búsqueda: $e');
      _resultados = [];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text("Buscar producto", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nombre o SKU...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                ),
              ),
              onChanged: _buscar,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _resultados.isEmpty
                ? const Center(
              child: Text(
                "No se encontraron productos",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final p = _resultados[index];
                return ListTile(
                  title: Text(p['nombre'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "SKU: ${p['sku']} • \$${p['precio']}",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: Text(
                    "${p['stock_actual']} und",
                    style: TextStyle(
                      color: (p['stock_actual'] ?? 0) <= 5 ? const Color(0xFFFF3B30) : const Color(0xFF00B74A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleProductoScreen(
                          nombre: p['nombre'],
                          sku: p['sku'],
                          stockActual: p['stock_actual'] ?? 0,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}