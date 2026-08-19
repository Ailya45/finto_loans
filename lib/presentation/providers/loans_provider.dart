import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/prestamo.dart';
import '../../infrastructure/datasource/local_db_datasource.dart';
import 'dashboard_provider.dart';

// Family provider to manage loans for a specific client
final loansProvider = StateNotifierProvider.family<LoansNotifier, List<Prestamo>, int>((ref, clientId) {
  return LoansNotifier(clientId, ref);
});

class LoansNotifier extends StateNotifier<List<Prestamo>> {
  final int clientId;
  final Ref ref;

  LoansNotifier(this.clientId, this.ref) : super([]) {
    loadLoans();
  }

  Future<void> loadLoans() async {
    final prestamos = await LocalDbDatasource.instance.readPrestamosByClient(clientId);
    state = prestamos;
  }

  Future<void> addPrestamo(Prestamo prestamo) async {
    final prestamoWithClient = prestamo.copyWith(clientId: clientId);
    final inserted = await LocalDbDatasource.instance.createPrestamo(prestamoWithClient);
    state = [inserted, ...state];
    ref.read(dashboardProvider.notifier).loadStats(); // Update global dashboard stats
  }

  Future<void> toggleCuotaStatus(int prestamoId, int cuotaId, bool currentStatus) async {
    final newStatus = !currentStatus;
    await LocalDbDatasource.instance.updateCuotaPagada(cuotaId, newStatus);
    
    // Refresh loans to get the updated status
    await loadLoans();
    
    // Refresh dashboard stats
    ref.read(dashboardProvider.notifier).loadStats();
  }
}
