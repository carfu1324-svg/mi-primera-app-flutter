import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/himnos_provider.dart';
import 'detalle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los datos
    final provider = context.watch<HimnosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Himnario')),
      
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por número o título...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              // Aquí conectamos el teclado con el Provider
              onChanged: (texto) {
                // Usamos 'read' porque es una acción, no estamos escuchando cambios aquí
                context.read<HimnosProvider>().buscar(texto);
              },
            ),
          ),

          // 2. LISTA DE RESULTADOS
          Expanded( // 'Expanded' es vital dentro de Column para ocupar el resto del espacio
            child: provider.cargando
                ? const Center(child: CircularProgressIndicator())
                : provider.himnos.isEmpty 
                  ? const Center(child: Text("No se encontraron himnos")) // Mensaje si no hay resultados
                  : ListView.builder(
                      itemCount: provider.himnos.length,
                      itemBuilder: (context, index) {
                        final himno = provider.himnos[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            child: Text('${himno.numero}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(himno.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(himno.categoria), // Muestra si es Rojo, Verde, etc.
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Aquí navegaremos al detalle pronto...
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleScreen(himno: himno), // Le pasamos el himno clickeado
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}