import 'package:finto_loans/presentation/providers/cuotas_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cuota.dart';
import '../../../domain/utils/loan_calculator.dart';
import '../../shared/utils/formatters.dart';
import 'mini_info_col.dart';

class CuotaCard extends ConsumerStatefulWidget {
  final Cuota cuota;
  final int totalCuotas;
  final VoidCallback onAbonar;

  const CuotaCard({
    super.key,
    required this.cuota,
    required this.totalCuotas,
    required this.onAbonar,
  });

  @override
  ConsumerState<CuotaCard> createState() => _CuotaCardState();
}

class _CuotaCardState extends ConsumerState<CuotaCard> {
  final TextEditingController _montoAbonarController = TextEditingController();
  double _montoIngresado = 0.0;

  @override
  void initState() {
    super.initState();
    _montoAbonarController.addListener(_onMontoChange);
  }

  @override
  void dispose() {
    _montoAbonarController.removeListener(_onMontoChange);
    _montoAbonarController.dispose();
    super.dispose();
  }

  void _onMontoChange() {
    final t = _montoAbonarController.text;

    setState(() {
      _montoIngresado = double.tryParse(t) ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final estado = calcularEstadoCuota(widget.cuota);
    final listaCuotas = ref.watch(cuotasProvider);

    final cuotaActualizada = listaCuotas.firstWhere(
      (c) => c.id == widget.cuota.id,
      orElse: () => widget.cuota,
    );

    final totalFaltante = cuotaActualizada.saldoRestanteCuota;

    final Color estadoColor;
    final Color estadoBg;
    final IconData estadoIcon;
    final String estadoLabel;

    switch (estado) {
      case EstadoCuota.pagado:
        estadoColor = Colors.green.shade700;
        estadoBg = Colors.green.shade50;
        estadoIcon = Icons.check_circle_rounded;
        estadoLabel = 'Pagado';
        break;
      case EstadoCuota.pendiente:
        estadoColor = Colors.amber.shade700;
        estadoBg = Colors.amber.shade50;
        estadoIcon = Icons.schedule_rounded;
        estadoLabel = 'Pendiente';
        break;
      case EstadoCuota.vencido:
        estadoColor = Colors.red.shade700;
        estadoBg = Colors.red.shade50;
        estadoIcon = Icons.warning_amber_rounded;
        estadoLabel = 'Vencido';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(left: 12, bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: estadoColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numero de cuota + badge de estado
              Row(
                children: [
                  Text(
                    'Cuota ${widget.cuota.numero} de ${widget.totalCuotas}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estadoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(estadoIcon, color: estadoColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          estadoLabel,
                          style: TextStyle(
                            color: estadoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Fecha limite
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: estado == EstadoCuota.vencido
                        ? Colors.red.shade600
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Fecha limite: ${formatDateEs(widget.cuota.fechaLimite)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: estado == EstadoCuota.vencido
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: estado == EstadoCuota.vencido
                          ? Colors.red.shade700
                          : colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),

              // Saldos: capital / interes / total
              Row(
                children: [
                  Expanded(
                    child: MiniInfoCol(
                      label: 'Saldo capital',
                      value: formatMoney(widget.cuota.capitalCuota),
                      color: colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: MiniInfoCol(
                      label: 'Saldo interes',
                      value: formatMoney(widget.cuota.interesCuota),
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Expanded(
                    child: MiniInfoCol(
                      label: 'Total a pagar',
                      value: formatMoney(cuotaActualizada.totalCuota),
                      color: colorScheme.tertiary,
                      bold: true,
                    ),
                  ),
                  Expanded(
                    child: MiniInfoCol(
                      label: 'Saldo faltante',
                      value: formatMoney(
                        totalFaltante < 0 ? 0.0 : totalFaltante,
                      ),
                      color: totalFaltante <= 0
                          ? Colors.green
                          : colorScheme.secondary,
                      bold: true,
                    ),
                  ),
                ],
              ),

              // Capital pendiente
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Capital pendiente: ${formatMoney(widget.cuota.saldoCapitalRestante)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),

              // Boton Abonar (solo si no esta pagado)
              if (!widget.cuota.pagado) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final TextEditingController textController =
                          TextEditingController();
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text('Abonar cuota #${widget.cuota.numero}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: textController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Monto abonado',
                                    hintText: 'Ingrese  monto',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                 onPressed: () async {
                                  final String montoIngresado = textController
                                      .text
                                      .trim();
                                  if (montoIngresado.isNotEmpty &&
                                      double.parse(montoIngresado) >
                                          cuotaActualizada.saldoRestanteCuota) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(
                                            'El monto abonado no puede superar el saldo restante (${formatMoney(cuotaActualizada.saldoRestanteCuota)}).',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cerrar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }
                                  if (montoIngresado.isNotEmpty) {
                                    final montoAbonar = double.parse(
                                      montoIngresado,
                                    );
                                    await ref
                                        .read(cuotasProvider.notifier)
                                        .pagarCuota(
                                          widget.cuota.id!,
                                          montoAbonar,
                                          widget.cuota.totalCuota,
                                        );
                                  }
                                  if (!context.mounted) return;
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Confirmar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: const Text(
                      'Abonar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: estado == EstadoCuota.vencido
                          ? Colors.red.shade600
                          : colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
