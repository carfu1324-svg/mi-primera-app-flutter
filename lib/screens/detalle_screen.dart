import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- IMPORTANTE
import '../models/himno.dart';
import '../providers/ui_provider.dart';

class DetalleScreen extends StatelessWidget {
  final Himno himno;

  const DetalleScreen({super.key, required this.himno});

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();

    return Scaffold(
      // Fondo un poco crema para que parezca papel (opcional, ayuda a la vista)
      backgroundColor: Colors.orange[50], 
      
      appBar: AppBar(
        title: Text("Himno #${himno.numero}"),
        actions: [
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
                width: double.infinity, // Ocupar todo el ancho para poder centrar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // 1. CENTRAR COLUMNA
                  children: [
                    // TÍTULO
                    Text(
                      himno.titulo,
                      textAlign: TextAlign.center, // 2. CENTRAR TEXTO
                      style: GoogleFonts.getFont(
                        uiProvider.fuenteActual, // 3. FUENTE DINÁMICA
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
                          style: GoogleFonts.robotoMono( // Los acordes siempre en letra monoespaciada
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),

                    // LETRA
                    Text(
                      himno.letra,
                      textAlign: TextAlign.center, // 2. CENTRAR TEXTO
                      style: GoogleFonts.getFont(
                        uiProvider.fuenteActual, // 3. FUENTE DINÁMICA
                        fontSize: uiProvider.tamanoLetra,
                        height: 1.6, // Altura de línea para elegancia
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 120), // Espacio final
                  ],
                ),
              ),
            ),
          ),

          // BARRA FLOTANTE MEJORADA
          Positioned(
            bottom: 30,
            left: 20, // Centramos la barra un poco mejor
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.indigo, // Barra oscura para contraste
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black45)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Que la barra se ajuste al contenido
                  children: [
                    // Botón Fuente
                    IconButton(
                      icon: const Icon(Icons.font_download, color: Colors.white),
                      tooltip: "Cambiar Fuente",
                      onPressed: () => context.read<UiProvider>().cambiarFuente(),
                    ),
                    
                    Container(height: 20, width: 1, color: Colors.white30), // Divisor

                    // Disminuir
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => context.read<UiProvider>().disminuirLetra(),
                    ),
                    
                    // Indicador numérico
                    Text(
                      "${uiProvider.tamanoLetra.toInt()}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),

                    // Aumentar
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