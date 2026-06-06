import 'package:flutter/material.dart';
import 'package:standstock_app/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:standstock_app/widgets/app_scaffold.dart';

class CierreDiaScreen extends StatefulWidget {
  final String standId;
  final String? standNombre;

  const CierreDiaScreen({
    super.key,
    required this.standId,
    this.standNombre,
  });

  @override
  State<CierreDiaScreen> createState() => _CierreDiaScreenState();
}

class _CierreDiaScreenState extends State<CierreDiaScreen> {
  final FirebaseService _service = FirebaseService();

  // Controladores para los montos ingresados manualmente
  final _efectivoController = TextEditingController(text: '0');
  final _tarjetaController = TextEditingController(text: '0');
  final _transferenciaController = TextEditingController(text: '0');

  Map<String, dynamic> _resumen = {
    'totalVendido': 0.0,
    'cantidadVentas': 0,
    'porMetodo': {},
  };

  bool _isLoading = true;
  bool _puedeCerrar = false;
  String? _errorMessage;

  double get _totalContado {
    final efectivo = double.tryParse(_efectivoController.text) ?? 0.0;
    final tarjeta = double.tryParse(_tarjetaController.text) ?? 0.0;
    final transferencia = double.tryParse(_transferenciaController.text) ?? 0.0;
    return efectivo + tarjeta + transferencia;
  }

  double get _diferencia {
    final totalSistema = (_resumen['totalVendido'] as num?)?.toDouble() ?? 0.0;
    return _totalContado - totalSistema;
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    // Escuchar cambios en los campos para recalcular en tiempo real
    _efectivoController.addListener(_actualizarCalculos);
    _tarjetaController.addListener(_actualizarCalculos);
    _transferenciaController.addListener(_actualizarCalculos);
  }

  @override
  void dispose() {
    _efectivoController.dispose();
    _tarjetaController.dispose();
    _transferenciaController.dispose();
    super.dispose();
  }

  void _actualizarCalculos() {
    setState(() {}); // Fuerza rebuild para mostrar totales actualizados
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Obtener datos del usuario actual
      final usuario = await _service.getUsuarioActual();

      // 2. Lógica de permisos para Cierre del Día
      final rol = (usuario?['rol'] ?? 'vendedor').toString();
      final esAdmin = rol == 'administrador' || rol == 'super_administrador';
      final standDelUsuario = usuario?['stand_id'];

      // Un admin (o super) puede cerrar cualquier stand (modo supervisión)
      // Un vendedor normal solo puede cerrar el stand que tiene asignado
      final puedeCerrar = esAdmin || (standDelUsuario != null && standDelUsuario == widget.standId);

      // 3. Cargar resumen de ventas del día
      final resumen = await _service.getResumenVentasDelDia(widget.standId);

      setState(() {
        _resumen = resumen;
        _puedeCerrar = puedeCerrar;
        _isLoading = false;

        if (!puedeCerrar) {
          _errorMessage = 'No estás asignado a este stand. Solo el vendedor asignado puede cerrar el día.';
        } else if (esAdmin) {
          _errorMessage = 'Estás en modo supervisión. El cierre quedará registrado a tu nombre como administrador.';
        }
      });
    } catch (e) {

      setState(() {
        _errorMessage = 'Error al cargar los datos. Revisa tu conexión.';
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCierre() async {
    if (!_puedeCerrar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permiso para cerrar este stand.')),
      );
      return;
    }

    final totalSistema = (_resumen['totalVendido'] as num?)?.toDouble() ?? 0.0;
    final efectivo = double.tryParse(_efectivoController.text) ?? 0.0;
    final tarjeta = double.tryParse(_tarjetaController.text) ?? 0.0;
    final transferencia = double.tryParse(_transferenciaController.text) ?? 0.0;

    final totalContado = efectivo + tarjeta + transferencia;
    final diferencia = totalContado - totalSistema;

    final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await _service.guardarCierreDelDia(
        standId: widget.standId,
        fecha: fecha,
        totalSistema: totalSistema,
        efectivoContado: efectivo,
        tarjetaReportado: tarjeta,
        transferenciaReportado: transferencia,
        totalContado: totalContado,
        diferencia: diferencia,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cierre del día guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Regresar indicando que se guardó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el cierre: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSistema = (_resumen['totalVendido'] as num?)?.toDouble() ?? 0.0;
    final cantidadVentas = (_resumen['cantidadVentas'] as num?)?.toInt() ?? 0;
    final porMetodo = (_resumen['porMetodo'] as Map<String, dynamic>?) ?? {};

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          widget.standNombre ?? "Cierre del Día",
          style: TextStyle(color: textColor),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Text(
                      "Cierre del Día",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: TextStyle(color: mutedColor.withOpacity(0.7), fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Mensaje de permisos / supervisión
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _puedeCerrar
                              ? Colors.blue.withOpacity(0.15)      // Azul para mensaje de supervisión (permitido)
                              : Colors.red.withOpacity(0.15),    // Rojo para bloqueo
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _puedeCerrar
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _puedeCerrar ? Icons.info_outline : Icons.warning_amber_rounded,
                              color: _puedeCerrar ? Colors.lightBlueAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Resumen del sistema
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total según el sistema", style: TextStyle(color: mutedColor, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(
                            "\$${totalSistema.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Color(0xFF00B74A),
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("$cantidadVentas ventas registradas hoy", style: TextStyle(color: mutedColor.withOpacity(0.7))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Desglose por método de pago (solo informativo)
                    if (porMetodo.isNotEmpty) ...[
                      Text("Según sistema:", style: TextStyle(color: mutedColor, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMetodoChip("Efectivo", porMetodo['efectivo'] ?? 0),
                          const SizedBox(width: 8),
                          _buildMetodoChip("Tarjeta", porMetodo['tarjeta'] ?? 0),
                          const SizedBox(width: 8),
                          _buildMetodoChip("Transfer.", porMetodo['transferencia'] ?? 0),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Sección de conteo manual
                    Text("¿Cuánto contaste / reportas hoy?", style: TextStyle(color: mutedColor, fontSize: 15)),
                    const SizedBox(height: 12),

                    _buildMontoField("Efectivo contado", _efectivoController, Icons.money),
                    const SizedBox(height: 12),
                    _buildMontoField("Tarjeta (reportado)", _tarjetaController, Icons.credit_card),
                    const SizedBox(height: 12),
                    _buildMontoField("Transferencia (reportado)", _transferenciaController, Icons.account_balance),

                    const Spacer(),

                    // Resumen de cierre
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total que cuentas", style: TextStyle(color: mutedColor)),
                              Text(
                                "\$${_totalContado.toStringAsFixed(0)}",
                                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(height: 20, color: mutedColor.withOpacity(0.2)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Diferencia", style: TextStyle(color: mutedColor)),
                              Text(
                                "${_diferencia >= 0 ? '+' : ''}\$${_diferencia.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: _diferencia >= 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_diferencia != 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _diferencia > 0 ? "Sobrante" : "Faltante",
                                style: TextStyle(
                                  color: _diferencia > 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _puedeCerrar ? _guardarCierre : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B74A),
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "Guardar Cierre del Día",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
      );
  }

  Widget _buildMontoField(String label, TextEditingController controller, IconData icon) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: textColor, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mutedColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: mutedColor.withOpacity(0.7)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mutedColor.withOpacity(0.15)),
        ),
      ),
    );
  }

  Widget _buildMetodoChip(String label, dynamic valor) {
    final monto = (valor is num) ? valor.toDouble() : 0.0;
    final cardColor = Theme.of(context).cardColor;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: mutedColor.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              "\$${monto.toStringAsFixed(0)}",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
