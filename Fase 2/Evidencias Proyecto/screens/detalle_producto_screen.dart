import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';

class DetalleProductoScreen extends StatefulWidget {
  final String productoId;
  final String standId;
  final String nombre;
  final String sku;
  final int stockActual;
  final double precio;           // ← Precio del producto (necesario para calcular total de la venta)
  final bool soloSalidas;

  const DetalleProductoScreen({
    super.key,
    required this.productoId,
    required this.standId,
    required this.nombre,
    required this.sku,
    required this.stockActual,
    required this.precio,
    this.soloSalidas = false,
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final FirebaseService _service = FirebaseService();
  late int _cantidad;
  late String _tipoSeleccionado; // 'entrada' o 'salida'
  String _metodoPago = 'efectivo'; // 'efectivo', 'tarjeta', 'transferencia'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = 'salida';
    _cantidad = widget.soloSalidas ? 1 : 5;   // Vendedor → empieza en 1, Admin puede empezar en 5
  }

  Future<void> _registrarMovimiento(String tipo) async {
    // Validaciones básicas
    if (_cantidad <= 0) {
      _mostrarError("La cantidad debe ser mayor a 0");
      return;
    }

    if (tipo == 'salida' && _cantidad > widget.stockActual) {
      _mostrarError("No puedes sacar más unidades de las que hay en stock");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.registrarMovimiento(
        productoId: widget.productoId,
        standId: widget.standId,
        tipo: tipo,
        cantidad: _cantidad,
        precioUnitario: widget.precio,
        metodoPago: _metodoPago,
        nota: tipo == 'salida' ? 'Venta realizada' : 'Reposición',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ ${tipo.toUpperCase()} de $_cantidad unidades registrada vía ${_metodoPago.toUpperCase()}"),
            backgroundColor: const Color(0xFF00B74A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _mostrarError("Ocurrió un error al registrar el movimiento. Intenta nuevamente.");
        print('Error registrarMovimiento: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _confirmarYRegistrar() async {
    final tipo = _tipoSeleccionado;
    final esVenta = widget.soloSalidas || tipo == 'salida';
    final accion = esVenta ? 'VENTA' : 'ENTRADA (reposición)';

    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          widget.soloSalidas ? "Confirmar Venta" : "Confirmar movimiento",
          style: TextStyle(color: textColor),
        ),
        content: Text(
          widget.soloSalidas
              ? "¿Confirmas registrar la venta de $_cantidad unidades por \$${(widget.precio * _cantidad).toStringAsFixed(0)} vía ${_metodoPago.toUpperCase()}?"
              : "¿Deseas registrar una $accion de $_cantidad unidades del producto?",
          style: TextStyle(color: mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: mutedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: esVenta ? Colors.red : const Color(0xFF00B74A),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              widget.soloSalidas 
                  ? "Sí, confirmar venta (${_metodoPago.toUpperCase()})" 
                  : "Sí, registrar",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _registrarMovimiento(tipo);
    }
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
        title: Text("Detalle Producto", style: TextStyle(color: textColor)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.inventory_2, size: 90, color: mutedColor),
              ),
            ),

            const SizedBox(height: 24),
            Text(widget.nombre, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
            Text("SKU: ${widget.sku}", style: TextStyle(fontSize: 16, color: mutedColor)),

            const SizedBox(height: 20),

            Row(
              children: [
                Text("Stock actual: ", style: TextStyle(fontSize: 18, color: mutedColor)),
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

            // Selección de tipo de movimiento
            if (!widget.soloSalidas)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => setState(() => _tipoSeleccionado = 'entrada'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _tipoSeleccionado == 'entrada' ? const Color(0xFF00B74A) : mutedColor.withOpacity(0.25),
                          width: _tipoSeleccionado == 'entrada' ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "+ Entrada",
                        style: TextStyle(
                          fontSize: 18,
                          color: _tipoSeleccionado == 'entrada' ? const Color(0xFF00B74A) : textColor.withOpacity(0.5),
                          fontWeight: _tipoSeleccionado == 'entrada' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => setState(() => _tipoSeleccionado = 'salida'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _tipoSeleccionado == 'salida' ? const Color(0xFFFF3B30) : mutedColor.withOpacity(0.25),
                          width: _tipoSeleccionado == 'salida' ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "- Salida",
                        style: TextStyle(
                          fontSize: 18,
                          color: _tipoSeleccionado == 'salida' ? const Color(0xFFFF3B30) : textColor.withOpacity(0.5),
                          fontWeight: _tipoSeleccionado == 'salida' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Cuando es solo ventas, mostramos un indicador claro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF3B30), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    "REGISTRANDO VENTA (SALIDA)",
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Cantidad
            Text("Cantidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                  icon: Icon(Icons.remove_circle_outline, size: 32, color: textColor),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text("$_cantidad", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _cantidad++),
                  icon: Icon(Icons.add_circle_outline, size: 32, color: textColor),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Selector de método de pago (solo visible en ventas)
            if (widget.soloSalidas || _tipoSeleccionado == 'salida') ...[
              Text("Método de pago", style: TextStyle(color: mutedColor, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "efectivo", child: Text("Efectivo")),
                  DropdownMenuItem(value: "tarjeta", child: Text("Tarjeta")),
                  DropdownMenuItem(value: "transferencia", child: Text("Transferencia")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _metodoPago = value);
                  }
                },
              ),
              const SizedBox(height: 32),
            ],

            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmarYRegistrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B74A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        widget.soloSalidas
                            ? "Confirmar Venta"
                            : "Confirmar ${ _tipoSeleccionado == 'salida' ? 'SALIDA' : 'ENTRADA' }",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}