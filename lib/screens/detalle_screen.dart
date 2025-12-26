import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/himno.dart';
import '../providers/ui_provider.dart';
import '../providers/himnos_provider.dart';

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
    final himnosProvider = context.watch<HimnosProvider>(); 

    final listaActual = himnosProvider.himnos;
    final indiceActual = listaActual.indexOf(himno);
    final esFavorito = himnosProvider.esFavorito(himno.id);

    // --- LÓGICA DE NAVEGACIÓN ---
    final haySiguiente = indiceActual < listaActual.length - 1;
    final hayAnterior = indiceActual > 0;

    return Scaffold(
      backgroundColor: Color(0xFFF7F0F0), // Fondo suave
      // 1. ELIMINAMOS EL APPBAR DEL SCAFFOLD
      // Esto quita la barra superior y el título duplicado.
      
      body: Stack(
        children: [
          // USAMOS SAFEAREA PARA RESPETAR LA BATERÍA/HORA DEL CELULAR
          SafeArea(
            child: Column(
              children: [
                
                // ===============================================
                // 2. CABECERA PERSONALIZADA (BOTONES)
                // ===============================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- BOTÓN ATRÁS (IZQUIERDA) ---
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // --- BOTONES DE ACCIÓN (DERECHA) ---
                      Row(
                        children: [
                          // Compartir
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.black87),
                            tooltip: 'Compartir letra',
                            onPressed: () => _compartirHimno(context),
                          ),
                          
                          // Notas (Solo visual por ahora)
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.black87),
                            tooltip: 'Notas personalizadas',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Próximamente: Notas personales"))
                              );
                            },
                          ),

                          // Acordes (Toggle)
                          IconButton(
                             icon: Icon(
                               Icons.music_note, 
                               color: uiProvider.mostrarAcordes ? Colors.orange[800] : Colors.grey
                             ),
                             onPressed: () => context.read<UiProvider>().toggleAcordes(),
                          ),

                          // Favorito
                          IconButton(
                            icon: Icon(
                              esFavorito ? Icons.star : Icons.star_border,
                              color: esFavorito ? Colors.red[400] : Colors.black87,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<HimnosProvider>().toggleFavorito(himno.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===============================================
                // 3. CONTENIDO CON SCROLL (EXPANDED)
                // ===============================================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        
                        // TÍTULO GRANDE (El único título visible)
                        Text(
                          "${himno.numero}. ${himno.titulo}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: uiProvider.fuenteActual,
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 50),

                        // CAJA DE ACORDES
                        if (uiProvider.mostrarAcordes && himno.acordes != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Text(
                              "♫  ${himno.acordes}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),

                        // LETRA (TEXTO NORMAL, NO MARKDOWN)
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

                        // --- BOTONES ANTERIOR / SIGUIENTE ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ANTERIOR
                            if (hayAnterior)
                              ElevatedButton.icon(
                                onPressed: () {
                                  final anterior = listaActual[indiceActual - 1];
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => DetalleScreen(himno: anterior),
                                      transitionDuration: Duration.zero, // Transición instantánea
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_back_ios, size: 16),
                                label: const Text("Anterior"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA96565),
                                  foregroundColor: Colors.white,
                                ),
                              )
                            else
                              const SizedBox(width: 100), // Espacio vacío

                            // SIGUIENTE
                            if (haySiguiente)
                              Directionality( // Truco para poner icono a la derecha
                                textDirection: TextDirection.rtl,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final siguiente = listaActual[indiceActual + 1];
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => DetalleScreen(himno: siguiente),
                                        transitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_back_ios, size: 16), // La flecha apunta a la izq en RTL, parece derecha
                                  label: const Text("Siguiente"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA96565),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 100),
                          ],
                        ),

                        // Espacio extra para que la barra flotante no tape el texto final
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===============================================
          // 4. BARRA FLOTANTE (FONT CONTROLS) - SIN CAMBIOS
          // ===============================================
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFA96565),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black26)],
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