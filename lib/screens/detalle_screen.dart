import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart'; 
import '../models/himno.dart';
import '../providers/ui_provider.dart';
import '../providers/himnos_provider.dart'; 
import 'package:share_plus/share_plus.dart'; // <--- AGREGAR ESTO

class DetalleScreen extends StatelessWidget {
  final Himno himno;

  const DetalleScreen({super.key, required this.himno});

  void _compartirHimno(BuildContext context) {
    final String textoACompartir = 
        "🎵 *${himno.numero}. ${himno.titulo}*\n\n"
        "${himno.letra}\n\n"
        "_Enviado desde mi App de Himnario_";

    final box = context.findRenderObject() as RenderBox?;
    
    Share.share(
      textoACompartir,
      subject: "Himno: ${himno.titulo}",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();
    
    // Obtenemos la lista actual
    final himnosProvider = context.watch<HimnosProvider>(); 

    final listaActual = himnosProvider.himnos;
    final indiceActual = listaActual.indexOf(himno);
    
    final esFavorito = himnosProvider.esFavorito(himno.id);

    // --- LÓGICA DE NAVEGACIÓN ---
    final haySiguiente = indiceActual < listaActual.length - 1;
    final hayAnterior = indiceActual > 0; // ¿Es mayor a 0? Entonces hay uno antes.

    return Scaffold(
      backgroundColor: Colors.orange[50],
      
      appBar: AppBar(
        title: Text(
          "${himno.numero}. ${himno.titulo}",
          style: const TextStyle(fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [

          IconButton(
            icon: Icon(
              esFavorito ? Icons.favorite : Icons.favorite_border,
              color: esFavorito ? Colors.redAccent : null,
            ),
            onPressed: () {
              context.read<HimnosProvider>().toggleFavorito(himno.id);
            },
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir letra',
            onPressed: () => _compartirHimno(context),
          ),

          IconButton(
            icon: Icon(
              Icons.music_note, 
              color: uiProvider.mostrarAcordes ? Colors.orange : Colors.grey
            ),
            onPressed: () => context.read<UiProvider>().toggleAcordes(),
          ),
        ],
      ),
      
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TÍTULO
                    Text(
                      himno.titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: uiProvider.fuenteActual,
                        fontSize: uiProvider.tamanoLetra + 6,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ACORDES
                    if (uiProvider.mostrarAcordes && himno.acordes != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          "🎸 ${himno.acordes}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),

                    // LETRA
                    Text(
                      himno.letra,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: uiProvider.fuenteActual,
                        fontSize: uiProvider.tamanoLetra,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // --- BARRA DE NAVEGACIÓN (ANTERIOR / SIGUIENTE) ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 100.0), // Espacio para la barra flotante
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espaciados equitativamente
                        children: [
                          
                          // 1. BOTÓN ANTERIOR
                          if (hayAnterior)
                            ElevatedButton.icon(
                              onPressed: () {
                                final anteriorHimno = listaActual[indiceActual - 1];
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleScreen(himno: anteriorHimno),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.skip_previous),
                              label: const Text("Anterior"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.indigo,
                              ),
                            )
                          else
                            // Espacio invisible para mantener el diseño si no hay botón
                            const SizedBox(width: 100), 

                          // 2. BOTÓN SIGUIENTE
                          if (haySiguiente)
                            ElevatedButton.icon(
                              onPressed: () {
                                final siguienteHimno = listaActual[indiceActual + 1];
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleScreen(himno: siguienteHimno),
                                  ),
                                );
                              },
                              // Invertimos el orden (Texto - Icono) para que la flecha apunte a la derecha
                              icon: const Icon(Icons.skip_next), 
                              label: const Text("Siguiente"),
                              // Un truco para poner el icono a la derecha del texto:
                              // Flutter por defecto pone el icono a la izquierda.
                              // No te preocupes, se entiende bien así, o puedes usar Directionality.
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo, // Color destacado para "Siguiente"
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                             const SizedBox(width: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BARRA FLOTANTE DE UI (Igual que siempre)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black45)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.font_download, color: Colors.white),
                      onPressed: () => context.read<UiProvider>().cambiarFuente(),
                    ),
                    Container(height: 20, width: 1, color: Colors.white30),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => context.read<UiProvider>().disminuirLetra(),
                    ),
                    Text(
                      "${uiProvider.tamanoLetra.toInt()}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => context.read<UiProvider>().aumentarLetra(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}