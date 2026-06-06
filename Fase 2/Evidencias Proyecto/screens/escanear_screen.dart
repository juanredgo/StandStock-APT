import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/screens/busqueda_manual_screen.dart';
import 'package:standstock_app/screens/detalle_producto_screen.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:standstock_app/constants/app_constants.dart';

class EscanearScreen extends StatefulWidget {
  final String? standId;          // ← Agregado para pasar el stand real

  const EscanearScreen({
    super.key,
    this.standId,
  });

  @override
  State<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _service = FirebaseService();

  bool _isScanning = true;
  String? _statusMessage;

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos cálculo manual porque esta pantalla usa Stack + Positioned
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return AppScaffold(
      automaticallyHandleBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Escanear", style: TextStyle(color: textColor)),
      ),
      body: Stack(
        children: [
          // Cámara en tiempo real
          MobileScanner(
            onDetect: (capture) async {
              if (!_isScanning) return;
              setState(() => _isScanning = false);

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? "";

                setState(() => _statusMessage = "Código detectado: $code");

                // Buscar el producto real por el código escaneado
                final products = await _service.searchProducts(code);

                if (products.isNotEmpty && mounted) {
                  final p = products.first;

                  Navigator.pushReplacement(
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
                } else if (mounted) {
                  // Producto no encontrado
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Producto no encontrado")),
                  );
                  setState(() => _isScanning = true);
                }
              }
            },
          ),

          // Overlay visual
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B74A), width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Línea de escaneo animada
          Center(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Container(
                  width: 260,
                  height: 4,
                  margin: EdgeInsets.only(top: _scanAnimation.value * 260),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B74A),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B74A).withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Mensajes de estado
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _statusMessage ?? "Apunta al código de barras o QR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: _statusMessage != null ? const Color(0xFF00B74A) : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70),
                ),
              ),
            ),
          ),

          // Manual button
          Positioned(
            bottom: 40 + bottomInset,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusquedaManualScreen(
                      standId: widget.standId ?? AppConstants.defaultStandId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                "Preferir búsqueda manual (recomendado)",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}