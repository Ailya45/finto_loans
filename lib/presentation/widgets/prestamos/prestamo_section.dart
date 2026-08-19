import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/prestamo.dart';
import '../../providers/cuotas_provider.dart';
import '../../shared/utils/formatters.dart';
import 'cuota_card.dart';

import '../../../domain/entities/cuota.dart';

class PrestamoSection extends ConsumerStatefulWidget {
  final Prestamo prestamo;
  final int index;
  final Function(Cuota) onCuotaPagada;

  const PrestamoSection({
    super.key,
    required this.prestamo,
    required this.index,
    required this.onCuotaPagada,
  });

  @override
  ConsumerState<PrestamoSection> createState() => _PrestamoSectionState();
}

class _PrestamoSectionState extends ConsumerState<PrestamoSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final p = widget.prestamo;
    final pagadas = p.cuotas.where((c) => c.pagado).length;
    final total = p.cuotas.length;
    final progreso = total > 0 ? pagadas / total : 0.0;

    // Sincronizar las cuotas del préstamo en el provider para que
    // CuotaCard pueda observar los cambios locales al abonar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cuotasProvider.notifier).cargarCuotas(p.cuotas);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta encabezado del prestamo
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          '#${widget.index}',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prestamo #${widget.index}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${formatMoney(p.valor)} - ${p.interesPct}% - ${p.frecuencia.label}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Barra de progreso de cuotas
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso,
                            minHeight: 7,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              pagadas == total && total > 0
                                  ? Colors.green
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$pagadas / $total pagadas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lista de cuotas (expandible)
        if (_expanded)
          ...p.cuotas.map(
            (cuota) => CuotaCard(
              cuota: cuota,
              totalCuotas: total,
              onAbonar: () {
                widget.onCuotaPagada(cuota);
              },
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
