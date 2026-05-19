import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _stands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    _usuarios = await _service.getAllUsers();
    _stands = await _service.getStands();
    setState(() => _isLoading = false);
  }

  // ==================== EDITAR USUARIO ====================
  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    String selectedRol = usuario['rol'] ?? 'vendedor';
    String? selectedStandId = usuario['stand_id'];

    // Mostramos el diálogo y esperamos la respuesta del usuario
    final bool? guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2E),
              title: const Text("Editar Usuario", style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: usuario['nombre']),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.white70)),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    const Text("Rol", style: TextStyle(color: Colors.white70)),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: "vendedor", label: Text("Vendedor")),
                        ButtonSegment(value: "administrador", label: Text("Administrador")),
                      ],
                      selected: {selectedRol},
                      onSelectionChanged: (Set<String> selection) {
                        setDialogState(() => selectedRol = selection.first);
                      },
                    ),

                    const SizedBox(height: 24),
                    const Text("Asignar Stand", style: TextStyle(color: Colors.white70)),
                    DropdownButtonFormField<String>(
                      value: selectedStandId,
                      dropdownColor: const Color(0xFF2C2C2E),
                      style: const TextStyle(color: Colors.white),
                      hint: const Text("Selecciona un stand", style: TextStyle(color: Colors.white54)),
                      items: _stands.map<DropdownMenuItem<String>>((stand) {
                        return DropdownMenuItem<String>(
                          value: stand['id'],
                          child: Text(stand['nombre'] ?? 'Sin nombre'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedStandId = value);
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Guardar", style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );

    // Solo continuamos si el usuario pulsó "Guardar"
    if (guardar != true) return;

    // Ahora hacemos la actualización (el diálogo ya está cerrado)
    try {
      await _service.updateUser(
        usuario['id'],
        rol: selectedRol,
        standId: selectedStandId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Usuario actualizado"), backgroundColor: Color(0xFF00B74A)),
        );
        _cargarDatos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    }
  }

  Future<void> _eliminarUsuario(String uid, String nombre) async { /* ... mismo código de antes ... */ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Gestionar Usuarios", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
          ? const Center(child: Text("No hay usuarios registrados", style: TextStyle(color: Colors.white70, fontSize: 18)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final u = _usuarios[index];
          return Card(
            color: const Color(0xFF2C2C2E),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(u['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(u['email'], style: const TextStyle(color: Colors.white70)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(u['rol'].toUpperCase()),
                    backgroundColor: u['rol'] == 'administrador' ? Colors.orange : Colors.green,
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editarUsuario(u),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarUsuario(u['id'], u['nombre']),
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