import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/himnos_provider.dart';
import '../providers/ui_provider.dart';
import 'detalle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color _obtenerColorCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('verde')) return Colors.green;
    if (cat.contains('especial')) return Colors.teal;
    if (cat.contains('niño') || cat.contains('nino')) return Colors.blue;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final himnosProvider = context.watch<HimnosProvider>();
    final uiProvider = context.watch<UiProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Himnario')),
      
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 5), // Menos padding abajo
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar en ${himnosProvider.categoriaSeleccionada}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (texto) {
                context.read<HimnosProvider>().buscar(texto);
              },
            ),
          ),

          // 2. BARRA DE FILTROS (NUEVO)
          // Usamos un Container con altura fija para la lista horizontal
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Scroll horizontal
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: himnosProvider.categorias.length,
              itemBuilder: (context, index) {
                final categoria = himnosProvider.categorias[index];
                final estaSeleccionada = himnosProvider.categoriaSeleccionada == categoria;
                
                // Color del chip
                Color colorChip;
                if (categoria == "Todos") {
                  colorChip = Colors.indigo;
                } else {
                  colorChip = _obtenerColorCategoria(categoria);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(categoria),
                    selected: estaSeleccionada,
                    onSelected: (bool selected) {
                      if (selected) {
                        context.read<HimnosProvider>().seleccionarCategoria(categoria);
                      }
                    },
                    // Estilos visuales
                    selectedColor: colorChip,
                    labelStyle: TextStyle(
                      color: estaSeleccionada ? Colors.white : Colors.black87,
                      fontWeight: estaSeleccionada ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.transparent), // Sin borde feo
                    ),
                    showCheckmark: false, // Quitamos el check ☑️ para que se vea más limpio
                  ),
                );
              },
            ),
          ),

          // 3. LISTA DE RESULTADOS
          Expanded(
            child: himnosProvider.cargando
                ? const Center(child: CircularProgressIndicator())
                : himnosProvider.himnos.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.library_music_outlined, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text("No hay himnos en '${himnosProvider.categoriaSeleccionada}'"),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: himnosProvider.himnos.length,
                      itemBuilder: (context, index) {
                        final himno = himnosProvider.himnos[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _obtenerColorCategoria(himno.categoria),
                            foregroundColor: Colors.white,
                            child: Text(
                              '${himno.numero}', 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ),
                          title: Text(
                            himno.titulo, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: uiProvider.tamanoLetra - 2, 
                            )
                          ),
                          subtitle: Text(himno.categoria),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleScreen(himno: himno),
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