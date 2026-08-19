import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/clients_provider.dart';

class ClientsView extends ConsumerWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Clientes"),
        centerTitle: true,
      ),
      body: clients.isEmpty
          ? Center(
              child: Text(
                "Aún no tienes clientes",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.cedula ?? "Sin cédula"),
                        Text(client.phone ?? "Sin teléfono"),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        IconButton(
                          icon: Icon(Icons.delete, color: colorScheme.error),
                         
                          onPressed: () {
                            showDialog(
                              context: context, 
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: const Text("¿Está seguro de que desea eliminar este cliente?"),
                                  content: const Text("Esta acción no se puede deshacer"),
                                  actions: [
                                    TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(clientsProvider.notifier).removeClient(client.id!);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              );
                            });
                          },
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () {
                      context.push('/client-detail', extra: client);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientDialog(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Nuevo Cliente"),
      ),
    );
  }

  void _showAddClientDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuevo Cliente"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cedulaCtrl,
                decoration: const InputDecoration(labelText: "Cédula"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Teléfono (opcional)"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final cedula = cedulaCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                if (name.isNotEmpty) {
                  ref.read(clientsProvider.notifier).addClient(name, cedula, phone.isEmpty ? null : phone);
                  Navigator.pop(context);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
