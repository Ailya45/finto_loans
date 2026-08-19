import 'package:flutter_riverpod/legacy.dart';

import '../../infrastructure/datasource/local_db_datasource.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, Map<String, double>>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<Map<String, double>> {
  DashboardNotifier() : super({'pagados': 0, 'pendientes': 0}) {  
    loadStats();
  }

  Future<void> loadStats() async {
    final stats = await LocalDbDatasource.instance.readDashboardStats();
    state = stats;
  }
}
