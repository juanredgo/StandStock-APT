import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:standstock_app/screens/detalle_producto_screen.dart';
import 'package:standstock_app/constants/app_constants.dart';

class BusquedaManualScreen extends StatefulWidget {
  final String? standId;

  const BusquedaManualScreen({
    super.key,
    this.standId,
  });

  @override
  State<BusquedaManualScreen> createState() => _BusquedaManualScreenState();
}

class _BusquedaManualScreenState extends State<BusquedaManualScreen> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _resultados = [];
  bool _isLoading = false;

  Future<void> _buscar(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _service.searchProducts(
        query,
        standId: widget.standId ?? AppConstants.defaultStandId,
      );
      setState(() {
        _resultados = results;
      });
    } catch (e) {
      print('Error en búsqueda: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _buscar(""); // carga solo los productos del stand actual
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
        title: Text("Buscar Producto", style: TextStyle(color: textColor)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        children: [
          TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Buscar por nombre, SKU o parte del nombre...",
                hintStyle: TextStyle(color: mutedColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: mutedColor),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _buscar,
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _resultados.isEmpty
                ? Center(
              child: Text(
                "No se encontraron productos.\nIntenta con otra palabra o revisa el inventario.",
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final p = _resultados[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(p['nombre'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "SKU: ${p['sku']} • \$${p['precio']}",
                      style: TextStyle(color: mutedColor),
                    ),
                    trailing: Text(
                      "${p['stock_actual'] ?? 0} und",
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
                            productoId: p['id'],
                            standId: widget.standId ?? AppConstants.defaultStandId,
                            nombre: p['nombre'],
                            sku: p['sku'],
                            stockActual: p['stock_actual'] ?? 0,
                            precio: (p['precio'] as num?)?.toDouble() ?? 0.0,
                            soloSalidas: true, // Vendedores solo registran ventas
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}