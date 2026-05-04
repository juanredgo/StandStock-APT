import 'package:flutter/material.dart';
import 'package:standstock_app/screens/detalle_producto_screen.dart';
import 'package:standstock_app/services/firebase_service.dart';

class BusquedaManualScreen extends StatefulWidget {
  const BusquedaManualScreen({super.key});

  @override
  State<BusquedaManualScreen> createState() => _BusquedaManualScreenState();
}

class _BusquedaManualScreenState extends State<BusquedaManualScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _resultados = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _buscar(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _service.searchProducts(query);
      setState(() {
        _resultados = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "No se pudo conectar con Firestore.\nVerifica tu internet.";
      });
      print('Error en búsqueda: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _buscar(""); // carga inicial
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
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
                ),
              ),
              onChanged: _buscar,
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B74A)))
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.white54),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _buscar(_searchController.text),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            )
                : _resultados.isEmpty
                ? const Center(
              child: Text(
                "No se encontraron productos",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final p = _resultados[index];
                return ListTile(
                  title: Text(p['nombre'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text("SKU: ${p['sku']} • \$${p['precio']}",
                      style: const TextStyle(color: Colors.white60)),
                  trailing: Text(
                    "${p['stock_actual']} und",
                    style: TextStyle(
                      color: (p['stock_actual'] ?? 0) <= 5
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF00B74A),
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