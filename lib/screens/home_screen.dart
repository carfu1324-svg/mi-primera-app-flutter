import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/himnos_provider.dart';
import '../providers/ui_provider.dart';
import 'detalle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlador para saber qué está escribiendo el usuario y resaltar el texto
  final TextEditingController _searchController = TextEditingController();

  Color _obtenerColorCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat == 'favoritos') return Colors.red;
    if (cat.contains('verde')) return Colors.green;
    if (cat.contains('especial')) return Colors.teal;
    if (cat.contains('niño') || cat.contains('nino')) return Colors.blue;
    return Colors.indigo;
  }

  // FUNCIÓN MAGICA: Extrae un pedacito de la letra donde aparece la búsqueda
  String? _obtenerFragmentoCoincidencia(String letra, String busqueda) {
    if (busqueda.isEmpty) return null;
    
    final letraLower = letra.toLowerCase();
    final busquedaLower = busqueda.toLowerCase();
    
    final index = letraLower.indexOf(busquedaLower);
    if (index == -1) return null; // No encontró nada en la letra (quizás fue por título)

    // Calculamos inicio y fin para mostrar un texto cortito (ej: 30 letras antes y después)
    final inicio = (index - 20).clamp(0, letra.length);
    final fin = (index + busqueda.length + 40).clamp(0, letra.length);

    String fragmento = letra.substring(inicio, fin).replaceAll("\n", " ");
    return "...$fragmento...";
  }

  @override
  Widget build(BuildContext context) {
    final himnosProvider = context.watch<HimnosProvider>();
    final uiProvider = context.watch<UiProvider>();
    final textoBusqueda = _searchController.text; // Lo que el usuario escribió

    return Scaffold(
      appBar: AppBar(
        title: const Text('Himnario'),
        actions: [
          // BOTÓN MODO OSCURO
          IconButton(
            icon: Icon(
              uiProvider.modoOscuro ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Cambiar Tema',
            onPressed: () {
              context.read<UiProvider>().alternarTema();
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
            child: TextField(
              controller: _searchController, // Conectamos el controlador
              decoration: InputDecoration(
                hintText: 'Buscar título, número o letra...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: textoBusqueda.isNotEmpty 
                  ? IconButton( // Botón X para borrar rápido
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HimnosProvider>().buscar("");
                        setState(() {}); // Actualizar para quitar la X
                      },
                    ) 
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (texto) {
                context.read<HimnosProvider>().buscar(texto);
                setState(() {}); // Actualizamos la pantalla para que el fragmento reaccione
              },
            ),
          ),

          // 2. BARRA DE FILTROS (CHIPS)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: himnosProvider.categorias.length,
              itemBuilder: (context, index) {
                final categoria = himnosProvider.categorias[index];
                final estaSeleccionada = himnosProvider.categoriaSeleccionada == categoria;
                
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
                        // Limpiamos búsqueda al cambiar categoría para evitar confusiones
                        _searchController.clear(); 
                        context.read<HimnosProvider>().buscar("");
                      }
                    },
                    selectedColor: colorChip,
                    labelStyle: TextStyle(
                      color: estaSeleccionada ? Colors.white : Colors.black87,
                      fontWeight: estaSeleccionada ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    showCheckmark: false,
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
                          const Icon(Icons.search_off, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text("No encontré '$textoBusqueda' en ${himnosProvider.categoriaSeleccionada}"),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: himnosProvider.himnos.length,
                      itemBuilder: (context, index) {
                        final himno = himnosProvider.himnos[index];
                        
                        // LÓGICA VISUAL: ¿Mostramos categoría o fragmento de letra?
                        // Si hay búsqueda y la letra contiene el texto, mostramos el fragmento.
                        // Si no, mostramos la categoría normal.
                        String subtitulo = himno.categoria;
                        bool esCoincidenciaLetra = false;

                        if (textoBusqueda.isNotEmpty) {
                           final fragmento = _obtenerFragmentoCoincidencia(himno.letra, textoBusqueda);
                           if (fragmento != null) {
                             subtitulo = fragmento; // Reemplazamos "Verdes" por "...atribuimos la..."
                             esCoincidenciaLetra = true;
                           }
                        }

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
                          subtitle: Text(
                            subtitulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              // Si es un fragmento de letra, lo ponemos en cursiva y gris oscuro
                              fontStyle: esCoincidenciaLetra ? FontStyle.italic : FontStyle.normal,
                              color: esCoincidenciaLetra ? Colors.black87 : Colors.grey,
                            ),
                          ),
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