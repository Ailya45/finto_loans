import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfigurationScreen extends StatelessWidget {
  final String configurationName;
  const ConfigurationScreen({super.key, this.configurationName = 'Configuración'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(configurationName)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tema'),
            subtitle: const Text('Tema de la aplicación'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/theme-changer');
            },
          ),
        ],
      ),
    );
  }
}
