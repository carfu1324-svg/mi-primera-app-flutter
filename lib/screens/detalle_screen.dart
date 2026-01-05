import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/himno.dart';
import '../providers/ui_provider.dart';
import '../providers/himnos_provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

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

    // Detectamos tema oscuro/claro
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    // Colores dinámicos
    final colorFondoAcordes = esOscuro ? Colors.grey[850] : Colors.white;
    final colorTextoAcordes = esOscuro ? Colors.orangeAccent : Colors.brown;
    final colorTextoPrincipal = Theme.of(context).textTheme.bodyLarge?.color;

    // Lógica de navegación (usa la lista completa, no la filtrada)
    final listaActual = himnosProvider.listaParaNavegacion;
    final indiceActual = listaActual.indexOf(himno);
    final esFavorito = himnosProvider.esFavorito(himno.id);
    final haySiguiente = indiceActual < listaActual.length - 1;
    final hayAnterior = indiceActual > 0;

    return Scaffold(
      // CUERPO DE LA PANTALLA (SOLO TEXTO)
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. CABECERA SUPERIOR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Atrás
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24), 
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Botones de Acción (Compartir, Notas, Favorito)
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
                      IconButton(
                         icon: Icon(
                           Icons.music_note, 
                           color: uiProvider.mostrarAcordes 
                              ? Colors.orange[800] 
                              : (esOscuro ? Colors.white38 : Colors.grey)
                         ),
                         onPressed: () => context.read<UiProvider>().toggleAcordes(),
                      ),
                      IconButton(
                        icon: Icon(
                          esFavorito ? Icons.star : Icons.star_border,
                          color: esFavorito ? Colors.red[400] : null,
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

            // --- 2. CONTENIDO (TITULO Y LETRA) ---
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
                          color: colorFondoAcordes,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                          boxShadow: esOscuro ? [] : [
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
                            color: colorTextoAcordes,
                          ),
                        ),
                      ),

                    // LETRA DEL HIMNO
                    /*Text(
                      himno.letra,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: uiProvider.fuenteActual,
                        fontSize: uiProvider.tamanoLetra,
                        height: 1.6,
                        color: colorTextoPrincipal, 
                      ),
                    ),
                    */
                    
                    HtmlWidget( // Ahora entiende <b>, <i> y <br>

                      //himno.letra.replaceAll('\n', '<br>'),
                      '<div style="text-align: center">${himno.letra.replaceAll('\n', '<br>')}</div>',
                      
                      // Estilos globales (Fuente, Color, Tamaño)
                      textStyle: TextStyle(
                        fontFamily: uiProvider.fuenteActual,
                        fontSize: uiProvider.tamanoLetra,
                        height: 1.6,
                        color: colorTextoPrincipal, 
                      ),

                      // Truco para centrar el texto HTML
                      customStylesBuilder: (element) {
                        return {'text-align': 'center'};
                      },
                    ),

                    // Espacio final para que el texto no choque con la barra de abajo
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- 3. BARRA INFERIOR DE CONTROLES (FIJA) ---
      bottomNavigationBar: Container(
        color: esOscuro ? Colors.grey[900] : Colors.white,
        child: SafeArea(
          top: false, 
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                // BOTÓN ANTERIOR (IZQUIERDA)
                if (hayAnterior)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: const Color(0xFFA96565),
                    tooltip: "Himno anterior",
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
                  )
                else
                  const SizedBox(width: 48), // Espacio para mantener centro

                // CONTROLES DE FUENTE (CENTRO - PÍLDORA ROJA)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA96565),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.font_download, color: Colors.white, size: 20),
                        onPressed: () => context.read<UiProvider>().cambiarFuente(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                        onPressed: () => context.read<UiProvider>().disminuirLetra(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "${uiProvider.tamanoLetra.toInt()}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        onPressed: () => context.read<UiProvider>().aumentarLetra(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // BOTÓN SIGUIENTE (DERECHA)
                if (haySiguiente)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: const Color(0xFFA96565),
                    tooltip: "Himno siguiente",
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
                  )
                else
                  const SizedBox(width: 48), // Espacio para mantener centro
              ],
            ),
          ),
        ),
      ),
    );
  }
}