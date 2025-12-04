import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/himnos_provider.dart'; // Importamos el provider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider
    final provider = context.watch<HimnosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Himnario')),
      
      // Si está cargando, mostramos circulito. Si no, la lista.
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.himnos.length,
              itemBuilder: (context, index) {
                final himno = provider.himnos[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${himno.numero}'),
                  ),
                  title: Text(himno.titulo),
                  subtitle: Text(himno.categoria),
                );
              },
            ),
    );
  }
}