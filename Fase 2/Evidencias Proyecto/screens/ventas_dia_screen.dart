import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';

class VentasDiaScreen extends StatefulWidget {
  final String standId;
  final String? standNombre;

  const VentasDiaScreen({
    super.key,
    required this.standId,
    this.standNombre,
  });

  @override
  State<VentasDiaScreen> createState() => _VentasDiaScreenState();
}

class _VentasDiaScreenState extends State<VentasDiaScreen> {
  final FirebaseService _service = FirebaseService();
  Map<String, dynamic> _resumen = {
    'totalVendido': 0.0,
    'cantidadVentas': 0,
    'ventas': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() => _isLoading = true);
    final data = await _service.getResumenVentasDelDia(widget.standId);
    setState(() {
      _resumen = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('HH:mm');
    final totalVendido = (_resumen['totalVendido'] as num?)?.toDouble() ?? 0.0;
    final cantidadVentas = (_resumen['cantidadVentas'] as num?)?.toInt() ?? 0;
    final List ventas = _resumen['ventas'] ?? [];
    final Map<String, dynamic> porMetodo = (_resumen['porMetodo'] as Map<String, dynamic>?) ?? {};

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;
    final cardColor = Theme.of(context).cardColor;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Ventas de Hoy",
          style: TextStyle(color: textColor),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total del día
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total vendido hoy",
                        style: TextStyle(color: mutedColor, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${totalVendido.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Color(0xFF00B74A),
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$cantidadVentas ventas realizadas",
                        style: TextStyle(color: mutedColor.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // === Resumen por Método de Pago ===
                if ((_resumen['porMetodo'] as Map?)?.isNotEmpty == true) ...[
                  Text(
                    "Resumen por Método de Pago",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetodoCard("Efectivo", _resumen['porMetodo']?['efectivo'] ?? 0.0, Colors.green),
                      const SizedBox(width: 8),
                      _buildMetodoCard("Tarjeta", _resumen['porMetodo']?['tarjeta'] ?? 0.0, Colors.blue),
                      const SizedBox(width: 8),
                      _buildMetodoCard("Transferencia", _resumen['porMetodo']?['transferencia'] ?? 0.0, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  "Detalle de ventas",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ventas.isEmpty
                      ? Center(
                          child: Text(
                            "Aún no has realizado ventas hoy",
                            style: TextStyle(color: mutedColor, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: ventas.length,
                          itemBuilder: (context, index) {
                            final venta = ventas[index];
                            final fecha = venta['fecha'] as DateTime?;
                            final total = (venta['total'] as num?)?.toDouble() ?? 0.0;

                            return Card(
                              color: cardColor,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text(
                                  venta['producto_nombre'] ?? 'Producto',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${venta['cantidad']} unidades • ${venta['metodo_pago']?.toString().toUpperCase() ?? ''}",
                                      style: TextStyle(color: mutedColor),
                                    ),
                                    if (fecha != null)
                                      Text(
                                        formatter.format(fecha),
                                        style: TextStyle(color: mutedColor.withOpacity(0.6), fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  "\$${total.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Color(0xFF00B74A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetodoCard(String titulo, double monto, Color color) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              titulo,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              "\$${monto.toStringAsFixed(0)}",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
