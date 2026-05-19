import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';

class GestionProductosScreen extends StatefulWidget {
  final String standId;

  const GestionProductosScreen({
    super.key,
    required this.standId,
  });

  @override
  State<GestionProductosScreen> createState() => _GestionProductosScreenState();
}

class _GestionProductosScreenState extends State<GestionProductosScreen> {
  final FirebaseService _service = FirebaseService();

  List<Map<String, dynamic>> _stands = [];
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = true;
  bool _mostrandoStands = true;
  String _standNombre = 'Stand';

  @override
  void initState() {
    super.initState();
    _mostrandoStands = widget.standId.isEmpty;
    if (_mostrandoStands) {
      _cargarStands();
    } else {
      _cargarProductos();
    }
  }

  Future<void> _cargarStands() async {
    setState(() => _isLoading = true);
    try {
      final stands = await _service.getStands();
      setState(() {
        _stands = stands;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando stands: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    try {
      final products = await _service.getProductsByStand(widget.standId);
      final stand = await _service.getStandById(widget.standId);
      setState(() {
        _productos = products;
        _standNombre = stand?['nombre'] ?? 'Stand';
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando productos: $e');
      setState(() => _isLoading = false);
    }
  }

  // ==================== ELIMINAR PRODUCTO ====================
  Future<void> _eliminarProducto(String productId, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text("Eliminar producto", style: TextStyle(color: Colors.white)),
        content: Text("¿Estás seguro de eliminar '$nombre'?\nEsta acción no se puede deshacer.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteProduct(productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Producto eliminado"), backgroundColor: Color(0xFF00B74A)));
          _cargarProductos();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
      }
    }
  }

  // ==================== FORMULARIO DE EDICIÓN ====================
  void _editarProducto(Map<String, dynamic> producto) {
    final nombreController = TextEditingController(text: producto['nombre']);
    final skuController = TextEditingController(text: producto['sku']);
    final precioController = TextEditingController(text: producto['precio'].toString());
    final stockController = TextEditingController(text: producto['stock_actual'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text("Editar Producto", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: skuController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "SKU", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: precioController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Precio", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: stockController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Stock actual", labelStyle: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.updateProduct(
                  producto['id'],
                  nombre: nombreController.text.trim(),
                  sku: skuController.text.trim(),
                  precio: double.parse(precioController.text),
                  stockActual: int.parse(stockController.text),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Producto actualizado"), backgroundColor: Color(0xFF00B74A)));
                  _cargarProductos();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ==================== AGREGAR NUEVO PRODUCTO ====================
  void _agregarNuevoProducto() {
    final nombreController = TextEditingController();
    final skuController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text("Nuevo Producto", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: skuController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "SKU", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: precioController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Precio", labelStyle: TextStyle(color: Colors.white70))),
              const SizedBox(height: 12),
              TextField(controller: stockController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Stock inicial", labelStyle: TextStyle(color: Colors.white70))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B74A)),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.createProduct(
                  sku: skuController.text.trim(),
                  nombre: nombreController.text.trim(),
                  precio: double.parse(precioController.text),
                  stockActual: int.parse(stockController.text),
                  standId: widget.standId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Producto agregado"), backgroundColor: Color(0xFF00B74A)));
                  _cargarProductos();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
              }
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _mostrandoStands ? "Seleccionar Stand" : "Productos - $_standNombre";

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        leading: _mostrandoStands ? null : IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mostrandoStands
          ? _buildStandsList()
          : _buildProductosList(),
      floatingActionButton: _mostrandoStands
          ? null
          : FloatingActionButton(
        backgroundColor: const Color(0xFF00B74A),
        onPressed: _agregarNuevoProducto,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStandsList() {
    if (_stands.isEmpty) {
      return const Center(child: Text("No hay stands registrados", style: TextStyle(color: Colors.white70, fontSize: 18)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stands.length,
      itemBuilder: (context, index) {
        final stand = _stands[index];
        return Card(
          color: const Color(0xFF2C2C2E),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GestionProductosScreen(standId: stand['id']))),
            title: Text(stand['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(stand['ubicacion'] ?? '', style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          ),
        );
      },
    );
  }

  Widget _buildProductosList() {
    if (_productos.isEmpty) {
      return const Center(child: Text("No hay productos en este stand", style: TextStyle(color: Colors.white70, fontSize: 18)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final p = _productos[index];
        return Card(
          color: const Color(0xFF2C2C2E),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => _editarProducto(p),
            title: Text(p['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("SKU: ${p['sku']} • \$${p['precio']}", style: const TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${p['stock_actual']} und",
                  style: TextStyle(
                    color: (p['stock_actual'] ?? 0) <= 5 ? Colors.red : const Color(0xFF00B74A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarProducto(p['id'], p['nombre']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}