import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:intl/intl.dart';   // ← Este import es necesario

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _movimientos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMovimientos();
  }

  Future<void> _cargarMovimientos() async {
    setState(() => _isLoading = true);
    _movimientos = await _service.getMovimientos();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Movimientos", style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movimientos.isEmpty
          ? const Center(child: Text("No hay movimientos aún", style: TextStyle(color: Colors.white70, fontSize: 18)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _movimientos.length,
        itemBuilder: (context, index) {
          final m = _movimientos[index];
          final esEntrada = m['tipo'] == 'entrada';
          return Card(
            color: const Color(0xFF2C2C2E),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                color: esEntrada ? Colors.green : Colors.red,
              ),
              title: Text(
                esEntrada ? "Entrada" : "Salida",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(formatter.format(m['fecha']), style: const TextStyle(color: Colors.white70)),
              trailing: Text(
                "${m['cantidad']} und",
                style: TextStyle(
                  color: esEntrada ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}