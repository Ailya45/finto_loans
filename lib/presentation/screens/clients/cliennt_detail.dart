import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/client.dart';
import '../../../domain/entities/prestamo.dart';
import '../../providers/loans_provider.dart';
import '../../widgets/prestamos/prestamo_form_sheet.dart';
import '../../widgets/prestamos/prestamo_section.dart';

class ClientDetailScreen extends ConsumerWidget {
  final Client client;

  const ClientDetailScreen({
    super.key,
    required this.client,
  });

  void _mostrarFormularioPrestamo(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrestamoFormSheet(
        onGuardar: (prestamo) {
          ref.read(loansProvider(client.id!).notifier).addPrestamo(prestamo);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final prestamos = ref.watch(loansProvider(client.id!));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(client.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: prestamos.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildLoanList(prestamos, ref),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioPrestamo(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Prestamo'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin prestamos registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el boton para agregar un prestamo',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanList(List<Prestamo> prestamos, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: prestamos.length,
      itemBuilder: (context, index) {
        final prestamo = prestamos[index];
        return PrestamoSection(
          key: ValueKey(prestamo.id),
          prestamo: prestamo,
          index: index + 1,
          onCuotaPagada: (cuota) {
            ref.read(loansProvider(client.id!).notifier).toggleCuotaStatus(
                  prestamo.id!,
                  cuota.id!,
                  cuota.pagado,
                );
          },
        );
      },
    );
  }
}