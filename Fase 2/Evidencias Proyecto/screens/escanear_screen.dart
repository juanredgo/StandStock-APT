import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:standstock_app/screens/busqueda_manual_screen.dart';
import 'package:standstock_app/screens/detalle_producto_screen.dart';

class EscanearScreen extends StatefulWidget {
  const EscanearScreen({super.key});

  @override
  State<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Escanear", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Cámara en tiempo real
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;
              setState(() => _isScanning = false);

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? "Código desconocido";

                setState(() => _statusMessage = "Código detectado: $code");

                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleProductoScreen(
                          nombre: "Producto escaneado",
                          sku: code,
                          stockActual: 12,
                        ),
                      ),
                    );
                  }
                });
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

          // Línea de escaneo ANIMADA
          Center(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Container(
                  width: 260,
                  height: 4,
                  margin: EdgeInsets.only(
                    top: _scanAnimation.value * 260,
                  ),
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
                  color: _statusMessage != null ? const Color(0xFF00B74A) : Colors.white70,
                ),
              ),
            ),
          ),

          // Botón manual
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusquedaManualScreen(standId: 'stand-costanera'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                "Ingresar código manualmente",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}