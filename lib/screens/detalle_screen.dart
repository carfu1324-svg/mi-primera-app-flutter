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
    // ... (Tu lógica de compartir queda igual) ...
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

    // Detectamos si el tema actual es oscuro automáticamente
    // gracias a tu configuración en main.dart
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    // Colores dinámicos para los acordes (que no son parte del tema estándar)
    final colorFondoAcordes = esOscuro ? Colors.grey[850] : Colors.white;
    final colorTextoAcordes = esOscuro ? Colors.orangeAccent : Colors.brown;
    
    // El color de texto principal lo tomamos del Tema
    final colorTextoPrincipal = Theme.of(context).textTheme.bodyLarge?.color;

    // ANTES: final listaActual = himnosProvider.himnos; (Esto usaba la búsqueda)
    // AHORA: Usamos la lista completa de la categoría para respetar el orden 121, 122, 123...
    final listaActual = himnosProvider.listaParaNavegacion;
    final indiceActual = listaActual.indexOf(himno);
    final esFavorito = himnosProvider.esFavorito(himno.id);
    final haySiguiente = indiceActual < listaActual.length - 1;
    final hayAnterior = indiceActual > 0;

    return Scaffold(
      // 1. IMPORTANTE: Al quitar backgroundColor, Flutter usa el de tu main.dart 
      // (Negro suave en oscuro, F7F0F0 en claro).
      
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                
                // --- CABECERA ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BOTÓN ATRÁS
                      IconButton(
                        // Quitamos color fijo, usamos el del tema o null para automático
                        icon: const Icon(Icons.arrow_back_ios_new, size: 24), 
                        onPressed: () => Navigator.pop(context),
                      ),

                      // BOTONES DE ACCIÓN
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined),
                            onPressed: () => _compartirHimno(context),
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Próximamente..."))
                               );
                            },
                          ),

                          // Acordes (Toggle)
                          IconButton(
                             icon: Icon(
                               Icons.music_note, 
                               // Ajustamos color inactivo según el tema
                               color: uiProvider.mostrarAcordes 
                                  ? Colors.orange[800] 
                                  : (esOscuro ? Colors.white38 : Colors.grey)
                             ),
                             onPressed: () => context.read<UiProvider>().toggleAcordes(),
                          ),

                          // Favorito
                          IconButton(
                            icon: Icon(
                              esFavorito ? Icons.star : Icons.star_border,
                              color: esFavorito ? Colors.red[400] : null, // Si es null, usa el color del tema (blanco/negro)
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

                // --- CONTENIDO ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        
                        // TÍTULO
                        Text(
                          "${himno.numero}. ${himno.titulo}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: uiProvider.fuenteActual,
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                            // NO ponemos color fijo, heredará blanco o negro del tema
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
                              color: colorFondoAcordes, // Usamos la variable dinámica
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              boxShadow: esOscuro ? [] : [ // Sin sombra en modo oscuro
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorTextoAcordes, // Color naranja/marrón
                              ),
                            ),
                          ),

                        // LETRA DEL HIMNO
                        Text(
                          himno.letra,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: uiProvider.fuenteActual,
                            fontSize: uiProvider.tamanoLetra,
                            height: 1.6,
                            // Color dinámico o null para que use el por defecto
                            color: colorTextoPrincipal, 
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // BOTONES NAVEGACIÓN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hayAnterior)
                              ElevatedButton.icon(
                                onPressed: () {
                                  final anterior = listaActual[indiceActual - 1];
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => DetalleScreen(himno: anterior),
                                      transitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_back_ios, size: 16),
                                label: const Text("Anterior"),
                                style: ElevatedButton.styleFrom(
                                  // Color rojo oscuro, se ve bien en ambos temas
                                  backgroundColor: const Color(0xFFA96565), 
                                  foregroundColor: Colors.white,
                                ),
                              )
                            else
                              const SizedBox(width: 100),

                            if (haySiguiente)
                              Directionality(
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
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
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
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BARRA FLOTANTE (Sin cambios necesarios, el rojo funciona en ambos)
          Positioned(
            bottom: 30, left: 20, right: 20,
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