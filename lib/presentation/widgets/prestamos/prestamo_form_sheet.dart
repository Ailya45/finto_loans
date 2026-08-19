import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/prestamo.dart';
import '../../../domain/utils/loan_calculator.dart';
import '../../shared/utils/formatters.dart';

class PrestamoFormSheet extends StatefulWidget {
  final void Function(Prestamo prestamo) onGuardar;

  const PrestamoFormSheet({super.key, required this.onGuardar});

  @override
  State<PrestamoFormSheet> createState() => _PrestamoFormSheetState();
}

class _PrestamoFormSheetState extends State<PrestamoFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _valorCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController();
  final _interesCtrl = TextEditingController();
  final _cuotaDeseadaCtrl = TextEditingController();

  FrecuenciaPago _frecuencia = FrecuenciaPago.mensual;
  DateTime _fechaInicio = DateTime.now();

  @override
  void initState() {
    super.initState();
    _valorCtrl.addListener(_recalcularCuota);
    _cuotasCtrl.addListener(_recalcularCuota);
    _interesCtrl.addListener(_recalcularCuota);
  }

  @override
  void dispose() {
    _valorCtrl.removeListener(_recalcularCuota);
    _cuotasCtrl.removeListener(_recalcularCuota);
    _interesCtrl.removeListener(_recalcularCuota);
    _valorCtrl.dispose();
    _cuotasCtrl.dispose();
    _interesCtrl.dispose();
    _cuotaDeseadaCtrl.dispose();
    super.dispose();
  }

  // Auto-calcula la cuota: valor * (1 + interes%) / numCuotas
  void _recalcularCuota() {
    final valor = double.tryParse(_valorCtrl.text) ?? 0;
    final numCuotas = int.tryParse(_cuotasCtrl.text) ?? 0;
    final interes = double.tryParse(_interesCtrl.text) ?? 0;

    if (valor > 0 && numCuotas > 0) {
      final cuota = valor * (1 + interes / 100) / numCuotas;
      final formatted = cuota.toStringAsFixed(2);
      if (_cuotaDeseadaCtrl.text != formatted) {
        _cuotaDeseadaCtrl.text = formatted;
      }
    } else {
      if (_cuotaDeseadaCtrl.text.isNotEmpty) {
        _cuotaDeseadaCtrl.text = '';
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _fechaInicio = picked);
    }
  }

  String _formatDate(DateTime date) => formatDateShort(date);

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final valor = double.parse(_valorCtrl.text);
    final numCuotas = int.parse(_cuotasCtrl.text);
    final interesPct = double.parse(_interesCtrl.text);
    final cuotaDeseada = double.tryParse(_cuotaDeseadaCtrl.text) ?? 0;

    final cuotas = generarCuotas(
      valor: valor,
      numCuotas: numCuotas,
      interesPct: interesPct,
      frecuencia: _frecuencia,
      fechaInicio: _fechaInicio,
    );

    final prestamo = Prestamo(
      valor: valor,
      numCuotas: numCuotas,
      interesPct: interesPct,
      cuotaDeseada: cuotaDeseada,
      frecuencia: _frecuencia,
      fechaInicio: _fechaInicio,
      cuotas: cuotas,
    );

    widget.onGuardar(prestamo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Titulo
              Row(
                children: [
                  Icon(Icons.add_card_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Agregar Prestamo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo: Valor
              _buildLabel('Valor del prestamo'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _valorCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: _inputDecoration(
                  context,
                  hint: '0.00',
                  prefix: r'$',
                  icon: Icons.attach_money_rounded,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el valor';
                  if (double.tryParse(v) == null) return 'Valor invalido';
                  if (double.parse(v) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Cuotas
              _buildLabel('Numero de cuotas'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cuotasCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  context,
                  hint: 'Ej: 12',
                  suffix: 'cuotas',
                  icon: Icons.format_list_numbered_rounded,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingresa el numero de cuotas';
                  }
                  if (int.tryParse(v) == null) return 'Numero invalido';
                  if (int.parse(v) <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Interes
              _buildLabel('Interes (%)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _interesCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: _inputDecoration(
                  context,
                  hint: 'Ej: 5.5',
                  suffix: '%',
                  icon: Icons.percent_rounded,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el interes';
                  if (double.tryParse(v) == null) return 'Valor invalido';
                  if (double.parse(v) < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Cuota deseada (calculada automaticamente)
              Row(
                children: [
                  _buildLabel('Cuota deseada'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 11,
                            color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 3),
                        Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cuotaDeseadaCtrl,
                readOnly: true,
                decoration: _inputDecoration(
                  context,
                  hint: 'Se calcula automaticamente',
                  prefix: r'$',
                  icon: Icons.payments_rounded,
                ).copyWith(
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Frecuencia de pago
              _buildLabel('Frecuencia de pago'),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: FrecuenciaPago.values.map((f) {
                    final selected = _frecuencia == f;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _frecuencia = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              f.label,
                              style: TextStyle(
                                color: selected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Fecha de inicio
              _buildLabel('Fecha de inicio del prestamo'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _seleccionarFecha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(_fechaInicio),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (_isToday(_fechaInicio))
                              Text(
                                'Hoy',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar Prestamo'),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.75),
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    String? prefix,
    String? suffix,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor:
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
