import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _stands = [];
  double _totalVendidoHoyTodos = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarStandsYResumen();
  }

  Future<void> _cargarStandsYResumen() async {
    setState(() => _isLoading = true);

    final stands = await _service.getStands();
    double totalGlobal = 0.0;

    // Cargar resumen de ventas de cada stand para mostrar total global
    for (var stand in stands) {
      final resumen = await _service.getResumenVentasDelDia(stand['id']);
      totalGlobal += (resumen['totalVendido'] as num?)?.toDouble() ?? 0.0;
    }

    setState(() {
      _stands = stands;
      _totalVendidoHoyTodos = totalGlobal;
      _isLoading = false;
    });
  }

  // Ver reporte detallado de un stand
  void _verReporteStand(Map<String, dynamic> stand) async {
    final summary = await _service.getStockSummaryByStand(stand['id']);
    final resumenVentas = await _service.getResumenVentasDelDia(stand['id']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporteDetalleStandScreen(
          stand: stand,
          summary: summary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;
    final cardColor = Theme.of(context).cardColor;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Reportes y Estadísticas", style: TextStyle(color: textColor)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen Global
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Resumen General de Hoy", style: TextStyle(color: mutedColor, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "\$${_totalVendidoHoyTodos.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Color(0xFF00B74A),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Total vendido en todos los stands", style: TextStyle(color: mutedColor.withOpacity(0.6))),
                      const SizedBox(height: 8),
                      Text(
                        "Selecciona un stand para ver su detalle",
                        style: TextStyle(color: mutedColor.withOpacity(0.5), fontSize: 14),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _stands.length,
                    itemBuilder: (context, index) {
                      final s = _stands[index];
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(s['nombre'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          subtitle: Text(s['ubicacion'] ?? '', style: TextStyle(color: mutedColor)),
                          trailing: Icon(Icons.arrow_forward_ios, color: mutedColor.withOpacity(0.5)),
                          onTap: () => _verReporteStand(s),
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

// ==================== PANTALLA DETALLE DE REPORTE POR STAND ====================
class ReporteDetalleStandScreen extends StatefulWidget {
  final Map<String, dynamic> stand;
  final Map<String, dynamic> summary;

  const ReporteDetalleStandScreen({
    super.key,
    required this.stand,
    required this.summary,
  });

  @override
  State<ReporteDetalleStandScreen> createState() => _ReporteDetalleStandScreenState();
}

class _ReporteDetalleStandScreenState extends State<ReporteDetalleStandScreen> {
  final FirebaseService _service = FirebaseService();

  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic> _resumenVentas = {
    'totalVendido': 0.0,
    'cantidadVentas': 0,
    'ventas': [],
    'porMetodo': {},
  };
  bool _isLoadingVentas = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() => _isLoadingVentas = true);

    // Crear rango de todo el día seleccionado
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    final resumen = await _service.getResumenVentasPorRango(
      widget.stand['id'],
      startOfDay,
      endOfDay,
    );

    setState(() {
      _resumenVentas = resumen;
      _isLoadingVentas = false;
    });
  }

  Future<void> _seleccionarDia() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
      _cargarVentas();
    }
  }

  // Exportar las ventas del día seleccionado a CSV
  Future<void> _exportarCSV() async {
    final List<dynamic> ventas = _resumenVentas['ventas'] ?? [];
    if (ventas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ventas para exportar en este día.')),
      );
      return;
    }

    try {
      // Preparar filas del CSV
      List<List<String>> rows = [
        ['Fecha', 'Producto', 'Cantidad', 'Precio Unitario', 'Total', 'Método de Pago', 'Hora'],
      ];

      final dateFormatter = DateFormat('dd/MM/yyyy');
      final timeFormatter = DateFormat('HH:mm');

      for (var venta in ventas) {
        final fecha = venta['fecha'] as DateTime?;
        rows.add([
          fecha != null ? dateFormatter.format(fecha) : '',
          (venta['producto_nombre'] ?? 'Producto').toString(),
          (venta['cantidad'] ?? 0).toString(),
          ((venta['precio_unitario'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0),
          ((venta['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0),
          (venta['metodo_pago'] ?? '').toString().toUpperCase(),
          fecha != null ? timeFormatter.format(fecha) : '',
        ]);
      }

      // Generar contenido CSV
      String csvData = const ListToCsvConverter().convert(rows);

      // Guardar archivo temporal
      final directory = await getTemporaryDirectory();
      final fileName =
          'ventas_${widget.stand['nombre'].toString().replaceAll(' ', '_')}_${DateFormat('yyyy-MM-dd').format(_selectedDate)}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData, encoding: utf8);

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Ventas del ${dateFormatter.format(_selectedDate)} - ${widget.stand['nombre']}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV exportado y listo para compartir.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalVendido = (_resumenVentas['totalVendido'] as num?)?.toDouble() ?? 0.0;
    final int cantidadVentas = (_resumenVentas['cantidadVentas'] as num?)?.toInt() ?? 0;
    final List<dynamic> ventas = _resumenVentas['ventas'] ?? [];

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(widget.stand['nombre'], style: TextStyle(color: textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === KPIs de Stock Actual ===
            Text("Estado Actual del Inventario", style: TextStyle(color: mutedColor, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildKPICard("Total Productos", "${widget.summary['totalProductos']}", Colors.blue),
                const SizedBox(width: 12),
                _buildKPICard("Bajo Stock", "${widget.summary['bajoStock']}", Colors.orange),
              ],
            ),
            const SizedBox(height: 30),

            // === Selector de Día ===
            Text("Seleccionar día", style: TextStyle(color: mutedColor, fontSize: 16)),
            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: _seleccionarDia,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: mutedColor.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Fecha:",
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.calendar_today, color: mutedColor, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Botón Exportar CSV
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingVentas ? null : _exportarCSV,
                icon: const Icon(Icons.download, size: 20),
                label: const Text("Exportar ventas a CSV"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: mutedColor.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === Resumen de Ventas en el Rango ===
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
                    "Total Vendido el ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                    style: TextStyle(color: mutedColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${totalVendido.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Color(0xFF00B74A),
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("$cantidadVentas ventas realizadas", style: TextStyle(color: mutedColor.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === Desglose por Método de Pago ===
            if (!_isLoadingVentas) ...[
              Text("Resumen por Método de Pago", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildMetodosPagoResumen(),
              const SizedBox(height: 24),
            ],

            // === Detalle de Ventas ===
            Text("Detalle de Ventas", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _isLoadingVentas
                ? const Center(child: CircularProgressIndicator())
                : ventas.isEmpty
                    ? Card(
                        color: cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text("No hay ventas en este rango de fechas", style: TextStyle(color: mutedColor.withOpacity(0.6))),
                          ),
                        ),
                      )
                    : Column(
                        children: ventas.map((venta) {
                          final total = (venta['total'] as num?)?.toDouble() ?? 0.0;
                          final fecha = venta['fecha'] as DateTime?;

                          return Card(
                            color: cardColor,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(
                                venta['producto_nombre'] ?? 'Producto',
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${venta['cantidad']} unidades • ${venta['metodo_pago']?.toString().toUpperCase() ?? ''}",
                                style: TextStyle(color: mutedColor),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${total.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Color(0xFF00B74A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (fecha != null)
                                    Text(
                                      "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}",
                                      style: TextStyle(color: mutedColor.withOpacity(0.5), fontSize: 11),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, Color color) {
    final cardColor = Theme.of(context).cardColor;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: mutedColor, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar el desglose por método de pago
  Widget _buildMetodosPagoResumen() {
    final Map<String, dynamic> metodoData = (_resumenVentas['porMetodo'] as Map<String, dynamic>?) ?? {};
    final efectivo = (metodoData['efectivo'] as num?)?.toDouble() ?? 0.0;
    final tarjeta = (metodoData['tarjeta'] as num?)?.toDouble() ?? 0.0;
    final transferencia = (metodoData['transferencia'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        _buildMetodoCard("Efectivo", efectivo, Colors.green),
        const SizedBox(width: 10),
        _buildMetodoCard("Tarjeta", tarjeta, Colors.blue),
        const SizedBox(width: 10),
        _buildMetodoCard("Transfer.", transferencia, Colors.orange),
      ],
    );
  }

  Widget _buildMetodoCard(String label, double monto, Color color) {
    final cardColor = Theme.of(context).cardColor;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: mutedColor, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              "\$${monto.toStringAsFixed(0)}",
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}