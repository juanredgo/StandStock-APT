import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final String nombre;
  final String sku;
  final int stockActual;

  const DetalleProductoScreen({
    super.key,
    required this.nombre,
    required this.sku,
    required this.stockActual,
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final FirebaseService _service = FirebaseService();
  int _cantidad = 5;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registrarMovimiento(String tipo) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _service.registrarMovimiento(
        productoId: widget.sku,        // usamos sku como identificador temporal
        tipo: tipo.toLowerCase(),      // 'entrada' o 'salida'
        cantidad: _cantidad,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$tipo de $_cantidad unidades registrada correctamente"),
          backgroundColor: const Color(0xFF00B74A),
        ),
      );

      Navigator.pop(context); // vuelve a la pantalla anterior
    } catch (e) {
      setState(() {
        _errorMessage = "No se pudo registrar el movimiento.";
      });
      print('Error al registrar movimiento: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detalle Producto", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.inventory_2, size: 90, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),
            Text(widget.nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text("SKU: ${widget.sku}", style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Stock actual: ", style: TextStyle(fontSize: 18)),
                Text(
                  "${widget.stockActual} unidades",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.stockActual > 5 ? const Color(0xFF00B74A) : const Color(0xFFFF3B30),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Entrada / Salida
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _registrarMovimiento("Entrada"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B74A),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("+ Entrada", style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _registrarMovimiento("Salida"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("- Salida", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cantidad
            const Text("Cantidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 32),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text("$_cantidad", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _cantidad++),
                  icon: const Icon(Icons.add_circle_outline, size: 32),
                ),
              ],
            ),

            const SizedBox(height: 40),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _registrarMovimiento("Movimiento"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B74A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  "Confirmar movimiento",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}