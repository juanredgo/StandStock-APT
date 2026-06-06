import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  bool _esSuperAdmin = false;
  String? _currentUserId;
  Map<String, dynamic>? _miCuenta;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _cargarCurrentUserRole();
  }

  Future<void> _cargarCurrentUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _currentUserId = uid;

    final rol = await _service.getUserRole(uid);

    // Cargar los datos completos del usuario actual para la sección "Mi cuenta"
    Map<String, dynamic>? userData;
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        userData = doc.data();
        userData!['id'] = doc.id;
      }
    } catch (e) {

    }

    if (mounted) {
      setState(() {
        _esSuperAdmin = rol == 'super_administrador';
        _miCuenta = userData;
      });
    }
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _service.getAllUsers();
      setState(() => _usuarios = users);

      // Extraer la información de la cuenta actual para mostrarla por separado
      if (_currentUserId != null) {
        _miCuenta = users.firstWhere(
          (u) => u['id'] == _currentUserId,
          orElse: () => {},
        );
        if (_miCuenta != null && _miCuenta!.isEmpty) {
          _miCuenta = null;
        }
      }
    } catch (e) {
      // El SnackBar de error ya se muestra más abajo en algunos flujos
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== EDITAR USUARIO ====================
  void _editarUsuario(Map<String, dynamic> usuario) async {
    // Solo Super Administradores pueden editar usuarios
    if (!_esSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes permisos para editar usuarios.")),
      );
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetRol = usuario['rol'] ?? 'vendedor';
    final targetIsSuper = targetRol == 'super_administrador';

    if (currentUid != null && currentUid == usuario['id']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No puedes editar tu propia cuenta desde aquí.")),
      );
      return;
    }

    // Protección adicional: Solo un super_administrador puede editar a otro super_administrador
    if (targetIsSuper && !_esSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solo un Super Administrador puede editar a otro Super Administrador.")),
      );
      return;
    }

    final stands = await _service.getStands();

    String selectedRol = usuario['rol'] ?? 'vendedor';
    String? selectedStandId = usuario['stand_id'];

    // Seguridad: si el stand_id actual no existe en la lista, lo ponemos en null
    final standIds = stands.map((s) => s['id']).toList();
    if (selectedStandId != null && !standIds.contains(selectedStandId)) {
      selectedStandId = null;
    }

    final bool? guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Editar Usuario", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_esSuperAdmin)
                  DropdownButtonFormField<String>(
                    value: selectedRol,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                    decoration: InputDecoration(labelText: "Rol", labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
                    items: const [
                      DropdownMenuItem(value: "vendedor", child: Text("Vendedor")),
                      DropdownMenuItem(value: "administrador", child: Text("Administrador")),
                    ],
                    onChanged: (val) => setDialogState(() => selectedRol = val!),
                  ),
                const SizedBox(height: 16),

                // Solo el Super Administrador puede cambiar la asignación de stand
                if (_esSuperAdmin)
                  DropdownButtonFormField<String>(
                    value: selectedStandId,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                    decoration: InputDecoration(labelText: "Asignar Stand", labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Sin stand")),
                      ...stands.map((s) => DropdownMenuItem(
                        value: s['id'],
                        child: Text(s['nombre']),
                      )),
                    ],
                    onChanged: (val) => setDialogState(() => selectedStandId = val),
                  )
                else
                  // Para administradores normales mostramos el stand actual como solo lectura
                  InputDecorator(
                    decoration: const InputDecoration(labelText: "Stand Asignado"),
                    child: Text(
                      selectedStandId != null
                          ? (stands.firstWhere((s) => s['id'] == selectedStandId, orElse: () => {'nombre': 'Desconocido'})['nombre'])
                          : "Sin stand",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Guardar", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (guardar != true) return;

    try {
      await _service.updateUser(
        targetUid: usuario['id'],
        newRol: selectedRol,
        newStandId: selectedStandId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Usuario actualizado"), backgroundColor: Color(0xFF00B74A)),
        );
        _cargarUsuarios();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  // ==================== ELIMINAR USUARIO ====================
  Future<void> _eliminarUsuario(String uid, String nombre) async {
    // Solo Super Administradores pueden eliminar usuarios
    if (!_esSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes permisos para eliminar usuarios.")),
      );
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Buscar el rol del usuario objetivo
    final targetUser = _usuarios.firstWhere((u) => u['id'] == uid, orElse: () => {});
    final targetRol = targetUser['rol'] ?? 'vendedor';
    final targetIsSuper = targetRol == 'super_administrador';

    if (currentUid != null && currentUid == uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No puedes eliminar tu propia cuenta.")),
      );
      return;
    }

    // Protección adicional
    if (targetIsSuper && !_esSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solo un Super Administrador puede eliminar a otro Super Administrador.")),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Eliminar Usuario", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)),
        content: Text("¿Eliminar a '$nombre'?\nEsta acción es irreversible.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteUser(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Usuario eliminado"), backgroundColor: Color(0xFF00B74A)));
        _cargarUsuarios();
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

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Gestionar Usuarios", style: TextStyle(color: textColor)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
          ? Center(child: Text("No hay usuarios", style: TextStyle(color: mutedColor, fontSize: 18)))
          : Builder(
              builder: (context) {
                final usuariosMostrados = _usuarios.where((u) => u['id'] != _currentUserId).toList();

                return ListView(
                  children: [
                // === Sección "Mi cuenta" (solo para Super Admin) ===
                if (_miCuenta != null && _esSuperAdmin) ...[
                  Text(
                    "Mi cuenta",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                      title: Text(
                        _miCuenta!['nombre'] ?? 'Sin nombre',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _miCuenta!['email'] ?? '',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text("Super Administrador"),
                            backgroundColor: Colors.deepPurple,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarUsuario(_miCuenta!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // === Banner de permisos limitados para Administradores normales ===
                if (!_esSuperAdmin) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Tienes permisos limitados.\n\n"
                            "Solo un Super Administrador puede cambiar roles, asignar stands o eliminar usuarios. "
                            "Aquí puedes ver la lista de usuarios del sistema, pero no realizar modificaciones.",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // === Encabezado con contador ===
                Row(
                  children: [
                    Text(
                      _esSuperAdmin
                          ? "Usuarios del sistema"
                          : "Usuarios registrados",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text("${usuariosMostrados.length}"),
                      backgroundColor: const Color(0xFF00B74A),
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // === Lista de usuarios ===
                if (usuariosMostrados.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text("No hay otros usuarios", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70, fontSize: 18)),
                    ),
                  )
                else
                  ...usuariosMostrados.map((u) {
                    final String rol = u['rol'] ?? 'vendedor';
                    final bool esSuperAdmin = rol == 'super_administrador';
                    final bool esAdmin = rol == 'administrador' || esSuperAdmin;

                    return Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(u['nombre'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['email'], style: TextStyle(color: mutedColor)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  label: Text(
                                    esSuperAdmin
                                        ? "Super Administrador"
                                        : esAdmin
                                        ? "Administrador"
                                        : "Vendedor",
                                  ),
                                  backgroundColor: esSuperAdmin
                                      ? Colors.deepPurple
                                      : esAdmin
                                      ? Colors.purple
                                      : const Color(0xFF00B74A),
                                  labelStyle: TextStyle(color: textColor, fontSize: 12),
                                ),
                                Chip(
                                  label: Text(
                                    u['stand_nombre'] ?? "Sin stand",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  backgroundColor: Colors.blueGrey,
                                  labelStyle: TextStyle(color: textColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Solo el Super Administrador puede ver y usar los botones de editar/eliminar
                        trailing: _esSuperAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editarUsuario(u),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarUsuario(u['id'], u['nombre']),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  }).toList(),
              ],
            );
          },
        ),
      // Ya no se crean usuarios desde la app.
      // Los vendedores se registran solos y el Super Administrador solo los rota de stand.
      floatingActionButton: null,
    );
  }
}