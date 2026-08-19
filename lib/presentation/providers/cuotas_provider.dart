import 'package:finto_loans/presentation/providers/dashboard_provider.dart';
import 'package:finto_loans/presentation/providers/loans_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/cuota.dart';
import '../../infrastructure/datasource/local_db_datasource.dart';

final cuotasProvider = StateNotifierProvider<CuotasNotifier, List<Cuota>>((
  ref,
) {
  return CuotasNotifier(ref);
});

class CuotasNotifier extends StateNotifier<List<Cuota>> {
  final db = LocalDbDatasource.instance;
  final Ref _ref;

  CuotasNotifier(this._ref) : super([]);

  /// Carga (o re-carga) una lista de cuotas en el estado del provider.
  /// Llamar esto antes de mostrar el detalle del préstamo para que el
  /// estado esté sincronizado con la DB desde el inicio.
  void cargarCuotas(List<Cuota> cuotas) {
    // Merge: conserva cuotas ya existentes (actualizadas en memoria) y
    // agrega las nuevas que no estaban en el estado.
    final mapaActual = {for (final c in state) c.id: c};
    final merged = cuotas.map((c) => mapaActual[c.id] ?? c).toList();
    state = merged;
  }

  Future<void> pagarCuota(
    int cuotaId,
    double montoAbonado,
    double montoTotalCuota,
  ) async {
    await db.registrarAbono(cuotaId, montoAbonado, montoTotalCuota);

    state = [
      for (final cuota in state)
        if (cuota.id == cuotaId)
          cuota.copyWith(
            saldoRestanteCuota:
                (cuota.saldoRestanteCuota - montoAbonado).clamp(0.0, cuota.totalCuota),
            pagado: (cuota.saldoRestanteCuota - montoAbonado) <= 0,
          )
        else
          cuota
    ];
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(loansProvider);
  }
}
