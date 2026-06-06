import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';   // ← Este import es necesario

class MovimientosScreen extends StatefulWidget {
  final String? standId;

  const MovimientosScreen({super.key, this.standId});

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
    final todos = await _service.getMovimientos();

    if (widget.standId != null && widget.standId!.isNotEmpty) {
      _movimientos = todos.where((m) {
        final stand = m['stand_id']?.toString() ?? '';
        return stand == widget.standId;
      }).toList();
    } else {
      _movimientos = todos;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    final titulo = widget.standId != null && widget.standId!.isNotEmpty
        ? "Movimientos del Stand"
        : "Todos los Movimientos";

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(titulo, style: TextStyle(color: textColor)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movimientos.isEmpty
          ? Center(
              child: Text(
                widget.standId != null && widget.standId!.isNotEmpty
                    ? "No hay movimientos para este stand"
                    : "No hay movimientos aún",
                style: TextStyle(color: mutedColor, fontSize: 18),
              ),
            )
          : ListView.builder(
        itemCount: _movimientos.length,
        itemBuilder: (context, index) {
          final m = _movimientos[index];
          final esEntrada = m['tipo'] == 'entrada';
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                color: esEntrada ? Colors.green : Colors.red,
              ),
              title: Text(
                esEntrada ? "Entrada" : "Salida",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(formatter.format(m['fecha']), style: TextStyle(color: mutedColor)),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${m['cantidad']} und",
                    style: TextStyle(
                      color: esEntrada ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (m['metodo_pago'] != null && m['metodo_pago'].toString().isNotEmpty)
                    Text(
                      m['metodo_pago'].toString().toUpperCase(),
                      style: TextStyle(color: mutedColor.withOpacity(0.7), fontSize: 11),
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