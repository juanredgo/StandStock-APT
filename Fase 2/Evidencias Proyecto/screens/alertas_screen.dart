import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';

class AlertasScreen extends StatefulWidget {
  final String? standId;

  const AlertasScreen({super.key, this.standId});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _alertas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    setState(() => _isLoading = true);
    try {
      _alertas = await _service.getLowStockProducts(standId: widget.standId);
    } catch (e) {
      print('Error cargando alertas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalAlertas = _alertas.length;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Alertas de Stock", style: TextStyle(color: textColor)),
        actions: [
          // Campana limpia y bien alineada
          IconButton(
            icon: Badge(
              label: totalAlertas > 0
                  ? Text(
                '$totalAlertas',
                style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
              )
                  : null,
              backgroundColor: Colors.red,
              offset: const Offset(2, -2),
              child: const Icon(Icons.notifications, size: 28),
            ),
            onPressed: () {},
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alertas.isEmpty
          ? Center(
        child: Text(
          "No hay alertas de stock bajo",
          style: TextStyle(color: mutedColor, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _alertas.length,
        itemBuilder: (context, index) {
          final alerta = _alertas[index];
          final int faltan = alerta['faltan'] ?? 0;

          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alerta['nombre'],
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("SKU: ${alerta['sku']}", style: TextStyle(color: mutedColor)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Stock actual:", style: TextStyle(color: mutedColor)),
                          Text(
                            "${alerta['stock_actual']} unidades",
                            style: const TextStyle(color: Colors.orange, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("¡Stock Bajo!", style: TextStyle(color: Colors.red, fontSize: 16)),
                          Text(
                            "Faltan $faltan unidades",
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Marcado como resuelto")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B74A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Marcar como resuelto",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}