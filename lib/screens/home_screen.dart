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
  final TextEditingController _searchController = TextEditingController();
  
  // Variable local para controlar el ordenamiento
  bool _ordenAlfabetico = false; 

  Color _obtenerColorCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat == 'favoritos') return Colors.red;
    if (cat.contains('verde')) return Colors.green;
    if (cat.contains('especial')) return Colors.teal;
    if (cat.contains('niño') || cat.contains('nino')) return Colors.blue;
    return Colors.indigo;
  }

  String? _obtenerFragmentoCoincidencia(String letra, String busqueda) {
    if (busqueda.isEmpty) return null;
    final letraLower = letra.toLowerCase();
    final busquedaLower = busqueda.toLowerCase();
    final index = letraLower.indexOf(busquedaLower);
    if (index == -1) return null; 

    final inicio = (index - 20).clamp(0, letra.length);
    final fin = (index + busqueda.length + 40).clamp(0, letra.length);

    String fragmento = letra.substring(inicio, fin).replaceAll("\n", " ");
    return "...$fragmento...";
  }

  @override
  Widget build(BuildContext context) {
    final himnosProvider = context.watch<HimnosProvider>();
    final uiProvider = context.watch<UiProvider>();
    final textoBusqueda = _searchController.text;

    // 1. DETECTAR MODO OSCURO (Usamos tu variable del provider)
    final esOscuro = uiProvider.modoOscuro;

    // 2. PREPARAR LA LISTA (LÓGICA DE ORDENAMIENTO)
    // Creamos una copia de la lista para no alterar la original del provider
    var listaA_Mostrar = List.of(himnosProvider.himnos);
    
    if (_ordenAlfabetico) {
      // Si el botón está activo, ordenamos por Título (A-Z)
      listaA_Mostrar.sort((a, b) => a.titulo.compareTo(b.titulo));
    }
    // Si no está activo, se muestra tal cual viene del provider (usualmente por número)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Himnario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Actualizar lista",
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Actualizando himnos...")),
              );
              await context.read<HimnosProvider>().recargarLista();

              // --- AGREGA ESTA LÍNEA ---
              // Esto vuelve a filtrar la lista nueva con el texto que ya tenías escrito
              if (context.mounted) {
                 context.read<HimnosProvider>().buscar(_searchController.text); 
              }
              // -------------------------
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Lista actualizada!")),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              esOscuro ? Icons.light_mode : Icons.dark_mode,
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
          // ======================================================
          // 1. BARRA DE BÚSQUEDA (MEJORADA PARA MODO OSCURO)
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                // Color del texto que escribes
                color: esOscuro ? Colors.white : Colors.black, 
              ),
              decoration: InputDecoration(
                hintText: 'Buscar título, número o letra...',
                // Color del Hint Text (ahora se verá bien en ambos modos)
                hintStyle: TextStyle(
                  color: esOscuro ? Colors.white60 : Colors.black54
                ),
                prefixIcon: Icon(
                  Icons.search, 
                  color: esOscuro ? Colors.white70 : Colors.grey
                ),
                suffixIcon: textoBusqueda.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear, color: esOscuro ? Colors.white70 : Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HimnosProvider>().buscar("");
                        setState(() {}); 
                      },
                    ) 
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                // Color de Fondo: Gris oscuro si es DarkMode, Rosado claro si es LightMode
                fillColor: esOscuro ? Colors.grey[800] : const Color(0xFFE8D5D5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (texto) {
                context.read<HimnosProvider>().buscar(texto);
                setState(() {}); 
              },
            ),
          ),

          // ======================================================
          // 2. BARRA DE FILTROS (BOTÓN ESTÁTICO + LISTA)
          // ======================================================
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // --- A. BOTÓN ESTÁTICO (ORDENAR A-Z) ---
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text("ABC"),
                    tooltip: "Ordenar alfabéticamente",
                    selected: _ordenAlfabetico,
                    showCheckmark: false,
                    // Colores personalizados para cuando está activo/inactivo
                    selectedColor: Colors.orangeAccent,
                    backgroundColor: esOscuro ? Colors.grey[800] : Colors.grey[300],
                    labelStyle: TextStyle(
                      color: _ordenAlfabetico 
                          ? Colors.black 
                          : (esOscuro ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _ordenAlfabetico ? Colors.orange : Colors.transparent
                      )
                    ),
                    onSelected: (val) {
                      setState(() {
                        _ordenAlfabetico = val;
                      });
                    },
                  ),
                ),

                // --- B. DIVISOR VISUAL ---
                Container(
                  width: 1, 
                  height: 30, 
                  color: Colors.grey.withOpacity(0.5),
                  margin: const EdgeInsets.only(right: 8),
                ),

                // --- C. LISTA DE CATEGORÍAS (SCROLLABLE) ---
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: himnosProvider.categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = himnosProvider.categorias[index];
                      final estaSeleccionada = himnosProvider.categoriaSeleccionada == categoria;
                      
                      Color colorChip;
                      if (categoria == "Todos") {
                        colorChip = const Color(0xFFA96565);
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
                              _searchController.clear(); 
                              context.read<HimnosProvider>().buscar("");
                            }
                          },
                          selectedColor: colorChip,
                          labelStyle: TextStyle(
                            color: estaSeleccionada ? Colors.white : (esOscuro ? Colors.white : Colors.black87),
                            fontWeight: estaSeleccionada ? FontWeight.bold : FontWeight.normal,
                          ),
                          // Fondo del chip inactivo según el tema
                          backgroundColor: esOscuro ? Colors.grey[800] : Colors.grey[200],
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
              ],
            ),
          ),

          // 3. LISTA DE RESULTADOS
          Expanded(
            child: himnosProvider.cargando
                ? const Center(child: CircularProgressIndicator())
                : listaA_Mostrar.isEmpty  // <--- USAMOS listaA_Mostrar EN VEZ DE himnosProvider.himnos
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
                      itemCount: listaA_Mostrar.length, // <--- USAMOS listaA_Mostrar
                      itemBuilder: (context, index) {
                        final himno = listaA_Mostrar[index]; // <--- USAMOS listaA_Mostrar
                        
                        String subtitulo = himno.categoria;
                        bool esCoincidenciaLetra = false;

                        if (textoBusqueda.isNotEmpty) {
                           final fragmento = _obtenerFragmentoCoincidencia(himno.letra, textoBusqueda);
                           if (fragmento != null) {
                             subtitulo = fragmento;
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
                              // Color del título dinámico
                              color: esOscuro ? Colors.white : Colors.black87,
                            )
                          ),
                          subtitle: Text(
                            subtitulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontStyle: esCoincidenciaLetra ? FontStyle.italic : FontStyle.normal,
                              // Color del subtítulo (fragmento o categoría)
                              color: esCoincidenciaLetra 
                                ? (esOscuro ? Colors.white70 : Colors.black87) 
                                : Colors.grey,
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