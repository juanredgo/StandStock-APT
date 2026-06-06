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
    try {
      _stands = await _service.getStands();
    } catch (e) {
      print("❌ Error cargando stands: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== AGREGAR STAND ====================
  void _agregarStand() {
    final nombreController = TextEditingController();
    final ubicacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Nuevo Stand", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                decoration: InputDecoration(
                  labelText: "Nombre del Stand",
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ubicacionController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                decoration: InputDecoration(
                  labelText: "Ubicación",
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
            onPressed: () async {
              // Primero guardamos
              try {
                await _service.createStand(
                  nombre: nombreController.text.trim(),
                  ubicacion: ubicacionController.text.trim(),
                );

                // Cerramos el diálogo
                if (mounted) Navigator.pop(context);

                // Ahora mostramos mensaje y actualizamos
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Stand agregado"),
                      backgroundColor: Color(0xFF00B74A),
                    ),
                  );
                  _cargarStands();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error: $e")),
                  );
                }
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ==================== EDITAR STAND (CORREGIDO - sin error) ====================
  void _editarStand(Map<String, dynamic> stand) {
    final nombreController = TextEditingController(text: stand['nombre']);
    final ubicacionController = TextEditingController(text: stand['ubicacion']);
    bool activo = stand['activo'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Editar Stand", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                  decoration: InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ubicacionController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                  decoration: InputDecoration(labelText: "Ubicación", labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text("Activo", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
                    const Spacer(),
                    Switch(
                      value: activo,
                      activeColor: const Color(0xFF00B74A),
                      onChanged: (value) => setDialogState(() => activo = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
              onPressed: () async {
                try {
                  await _service.updateStand(
                    stand['id'],
                    nombre: nombreController.text.trim(),
                    ubicacion: ubicacionController.text.trim(),
                    activo: activo,
                  );

                  // Primero cerramos el diálogo
                  if (mounted) Navigator.pop(context);

                  // Luego mostramos el mensaje y actualizamos la lista
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Stand actualizado"), backgroundColor: Color(0xFF00B74A)),
                    );
                    _cargarStands();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
                  }
                }
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ELIMINAR STAND ====================
  Future<void> _eliminarStand(String standId, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Eliminar Stand", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)),
        content: Text("¿Eliminar '$nombre'?\nEsta acción no se puede deshacer.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: Text("Eliminar", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteStand(standId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Stand eliminado"), backgroundColor: Color(0xFF00B74A)));
        _cargarStands();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Gestionar Stands", style: TextStyle(color: textColor)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stands.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: mutedColor.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text("No hay stands registrados", style: TextStyle(color: mutedColor, fontSize: 20)),
            const SizedBox(height: 8),
            Text("Agrega uno con el botón +", style: TextStyle(color: mutedColor.withOpacity(0.6))),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stands.length,
        itemBuilder: (context, index) {
          final s = _stands[index];
          final bool activo = s['activo'] ?? true;
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(s['nombre'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              subtitle: Text(s['ubicacion'] ?? '', style: TextStyle(color: mutedColor)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(activo ? "Activo" : "Pausado"),
                    backgroundColor: activo ? Colors.green : Colors.orange,
                    labelStyle: TextStyle(color: textColor, fontSize: 12),
                  ),
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _editarStand(s)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarStand(s['id'], s['nombre'])),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00B74A),
        onPressed: _agregarStand,
        child: const Icon(Icons.add),
      ),
    );
  }
}