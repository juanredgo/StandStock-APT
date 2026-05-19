import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class GestionStandsScreen extends StatefulWidget {
  const GestionStandsScreen({super.key});

  @override
  State<GestionStandsScreen> createState() => _GestionStandsScreenState();
}

class _GestionStandsScreenState extends State<GestionStandsScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _stands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarStands();
  }

  Future<void> _cargarStands() async {
    setState(() => _isLoading = true);
    final stands = await _service.getStands();
    setState(() {
      _stands = stands;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(backgroundColor: const Color(0xFF1C1C1E),iconTheme: const IconThemeData(color: Colors.white), title: const Text("Gestionar Stands", style: TextStyle(color: Colors.white))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stands.length,
        itemBuilder: (context, index) {
          final s = _stands[index];
          return Card(
            color: const Color(0xFF2C2C2E),
            child: ListTile(
              title: Text(s['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(s['ubicacion'] ?? '', style: const TextStyle(color: Colors.white70)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B74A),
        child: const Icon(Icons.add),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregar stand - Próximamente"))),
      ),
    );
  }
}