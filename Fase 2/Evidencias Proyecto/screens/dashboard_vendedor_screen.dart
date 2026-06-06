import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:standstock_app/screens/alertas_screen.dart';
import 'package:standstock_app/screens/escanear_screen.dart';
import 'package:standstock_app/screens/inventario_screen.dart';
import 'package:standstock_app/screens/movimientos_screen.dart';
import 'package:standstock_app/screens/ventas_dia_screen.dart';
import 'package:standstock_app/screens/cierre_dia_screen.dart';
import 'package:standstock_app/screens/login_screen.dart'; // ← Agregado para logout correcto
import 'package:standstock_app/screens/busqueda_manual_screen.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';
import 'package:standstock_app/constants/app_constants.dart';
import 'package:standstock_app/screens/settings_screen.dart';

class DashboardVendedorScreen extends StatefulWidget {
  final String? standId;
  final String? standNombre;

  const DashboardVendedorScreen({
    super.key,
    this.standId,
    this.standNombre,
  });

  @override
  State<DashboardVendedorScreen> createState() => _DashboardVendedorScreenState();
}

class _DashboardVendedorScreenState extends State<DashboardVendedorScreen> {
  final FirebaseService _service = FirebaseService();

  Map<String, dynamic> _kpis = {
    'stockTotal': 0,
    'stockBajo': 0,
    'ventasHoy': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadKPIs();
  }

  Future<void> _loadKPIs() async {
    try {
      final data = await _service.getStockSummary(widget.standId ?? AppConstants.defaultStandId);
      setState(() {
        _kpis = data;
      });
    } catch (e) {
      // Silencioso: la pantalla sigue mostrando los datos anteriores
    }
  }

  Future<void> _logout() async {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Cerrar sesión", style: TextStyle(color: textColor)),
        content: Text("¿Estás seguro de cerrar sesión?", style: TextStyle(color: mutedColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: mutedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          widget.standNombre ?? "Stand Mall Costanera",
          style: TextStyle(color: textColor),
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: (_kpis['stockBajo'] ?? 0) > 0
                  ? Text('${_kpis['stockBajo']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                  : null,
              backgroundColor: Colors.red,
              child: const Icon(Icons.notifications, size: 28),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertasScreen(standId: widget.standId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              "Bienvenido,",
              style: TextStyle(
                fontSize: 28,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            Text(
              "Juan",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),

            _buildKPICard("Stock Total:", "${_kpis['stockTotal']}", const Color(0xFF00B74A)),
            const SizedBox(height: 12),
            _buildKPICard("Stock Bajo:", "${_kpis['stockBajo']}", Colors.orange),
            const SizedBox(height: 12),
            _buildKPICard("Ventas Hoy:", "\$${_kpis['ventasHoy']}", const Color(0xFF00B74A)),

            const Spacer(),

            // === Búsqueda Manual (Flujo principal recomendado) ===
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusquedaManualScreen(
                        standId: widget.standId,
                      ),
                    ),
                  ).then((_) {
                    _loadKPIs();
                  });
                },
                icon: const Icon(Icons.search, size: 22),
                label: const Text("Buscar producto manualmente", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Escanear - Ahora secundario (opcional, para productos con código de barras)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EscanearScreen(
                        standId: widget.standId,
                      ),
                    ),
                  ).then((_) {
                    _loadKPIs();
                  });
                },
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text("Escanear código de barras (opcional)", style: TextStyle(fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: mutedColor,
                  side: BorderSide(color: mutedColor.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Botones inferiores
            Column(
              children: [
                // Nuevo botón: Resumen del día
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VentasDiaScreen(
                          standId: widget.standId ?? AppConstants.defaultStandId,
                          standNombre: widget.standNombre,
                        ),
                      ),
                    ).then((_) => _loadKPIs()),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("Resumen del día (Ventas)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B74A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Botón Cierre del Día
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CierreDiaScreen(
                          standId: widget.standId ?? AppConstants.defaultStandId,
                          standNombre: widget.standNombre,
                        ),
                      ),
                    ).then((_) => _loadKPIs()),
                    icon: const Icon(Icons.lock_clock),
                    label: const Text("Cierre del Día"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B74A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InventarioScreen(standId: widget.standId ?? AppConstants.defaultStandId),
                          ),
                        ).then((_) => _loadKPIs()),
                        icon: const Icon(Icons.inventory),
                        label: const Text("Ver Inventario"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovimientosScreen(standId: widget.standId),
                          ),
                        ).then((_) => _loadKPIs()),
                        icon: const Icon(Icons.history),
                        label: const Text("Ver Movimientos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildKPICard(String title, String value, Color valueColor) {
    final Color cardColor = Theme.of(context).cardColor;
    final Color mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 17, color: mutedColor)),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}