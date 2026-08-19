import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/client.dart';
import '../../infrastructure/datasource/local_db_datasource.dart';

final clientsProvider = StateNotifierProvider<ClientsNotifier, List<Client>>(
  (ref) {
    return ClientsNotifier();
  },
);

class ClientsNotifier extends StateNotifier<List<Client>> {
  ClientsNotifier() : super([]) {
    loadClients();
  }

  Future<void> loadClients() async {
    final clients = await LocalDbDatasource.instance.readAllClients();
    state = clients;
  }

  Future<void> addClient(String name, String cedula, String? phone) async {
    final newClient = Client(
      name: name,
      cedula: cedula,
      phone: phone,
      createdAt: DateTime.now(),
    );
    final insertedClient = await LocalDbDatasource.instance.createClient(newClient);
    state = [insertedClient, ...state];
  }

  Future<void> removeClient(int id) async {
    await LocalDbDatasource.instance.deleteClient(id);
    state = state.where((client) => client.id != id).toList();
  }
}
