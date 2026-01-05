import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:audioplayers/audioplayers.dart'; 

import '../models/himno.dart';
import '../providers/ui_provider.dart';
import '../providers/himnos_provider.dart';

class DetalleScreen extends StatefulWidget {
  final Himno himno;

  const DetalleScreen({super.key, required this.himno});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  // CONTROLADOR DE AUDIO
  late AudioPlayer _player;
  bool _reproduciendo = false;
  bool _cargandoAudio = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Escuchar cambios de estado (Play/Pause)
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _reproduciendo = (state == PlayerState.playing);
        });
      }
    });

    // Escuchar cuando termina la canción
    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _reproduciendo = false;
          _player.stop(); 
        });
      }
    });
  }

  @override
  void dispose() {
    // IMPORTANTE: Detener y limpiar el audio al salir
    _player.dispose();
    super.dispose();
  }

  // FUNCIÓN PARA REPRODUCIR/PAUSAR SEGURA
  Future<void> _toggleAudio() async {
    if (widget.himno.audioUrl == null || widget.himno.audioUrl!.isEmpty) return;

    try {
      if (_reproduciendo) {
        await _player.pause();
      } else {
        setState(() => _cargandoAudio = true);
        
        await _player.play(UrlSource(widget.himno.audioUrl!));
        
        if (mounted) {
          setState(() => _cargandoAudio = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo reproducir el audio")),
        );
      }
    }
  }

  void _compartirHimno(BuildContext context) {
    final String textoACompartir = 
        "🎵 *${widget.himno.numero}. ${widget.himno.titulo}*\n\n"
        "${widget.himno.letra}\n\n"
        "_Enviado desde mi App de Himnario_";

    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      textoACompartir,
      subject: "Himno: ${widget.himno.titulo}",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiProvider = context.watch<UiProvider>();
    final himnosProvider = context.watch<HimnosProvider>(); 
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    final colorFondoAcordes = esOscuro ? Colors.grey[850] : Colors.white;
    final colorTextoAcordes = esOscuro ? Colors.orangeAccent : Colors.brown;
    final colorTextoPrincipal = Theme.of(context).textTheme.bodyLarge?.color;

    final listaActual = himnosProvider.listaParaNavegacion;
    final indiceActual = listaActual.indexOf(widget.himno);
    final esFavorito = himnosProvider.esFavorito(widget.himno.id);
    final haySiguiente = indiceActual < listaActual.length - 1;
    final hayAnterior = indiceActual > 0;

    // --- LÓGICA INTELIGENTE DE VISUALIZACIÓN ---
    
    // 1. ¿Existe realmente una letra especial con acordes?
    bool existeLetraConAcordes = widget.himno.letraAcordes != null && widget.himno.letraAcordes!.trim().isNotEmpty;
    
    // 2. ¿Debemos mostrar el modo acordes? (Solo si el usuario quiere Y existe la data)
    bool modoAcordesActivo = uiProvider.mostrarAcordes && existeLetraConAcordes;

    // 3. ¿Debemos mostrar la cajita de "Resumen"? (Si el usuario quiere acordes, pero solo tenemos los básicos, no la letra completa)
    bool mostrarResumenAcordes = uiProvider.mostrarAcordes && (widget.himno.acordes != null && !existeLetraConAcordes);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. CABECERA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24), 
                    onPressed: () => Navigator.pop(context),
                  ),
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
                           // El color indica si el botón está "presionado", aunque no haya acordes
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
                          context.read<HimnosProvider>().toggleFavorito(widget.himno.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 2. CONTENIDO ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "${widget.himno.numero}. ${widget.himno.titulo}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: uiProvider.fuenteActual,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // --- CAJA DE RESUMEN DE ACORDES (Solo informativo) ---
                    if (mostrarResumenAcordes)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorFondoAcordes,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: Text(
                          "♫  Tonalidad sugerida: ${widget.himno.acordes}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorTextoAcordes,
                          ),
                        ),
                      ),
                    
                    // --- WIDGET DE LA LETRA ---
                    HtmlWidget(
                      // HTML: Si el modo acordes está activo Y existen, usa <pre>, sino usa letra normal
                      modoAcordesActivo
                          ? '<pre style="text-align: left; overflow-x: auto; margin: 0; padding: 0;">${widget.himno.letraAcordes}</pre>'
                          : '<div style="text-align: center">${widget.himno.letra.replaceAll('\n', '<br>')}</div>',
                      
                      textStyle: TextStyle(
                        // FUENTE: Monospace para acordes, Fuente elegida para normal
                        fontFamily: modoAcordesActivo ? 'monospace' : uiProvider.fuenteActual,
                        
                        // TAMAÑO: Se reduce si hay acordes para que quepa en pantalla
                        fontSize: modoAcordesActivo 
                            ? (uiProvider.tamanoLetra > 14 ? uiProvider.tamanoLetra - 5 : 10) 
                            : uiProvider.tamanoLetra,
                        
                        // ESPACIADO: Pegadito para acordes, amplio para lectura
                        height: modoAcordesActivo ? 1.5 : 1.8, 
                        color: colorTextoPrincipal, 
                      ),
                      renderMode: RenderMode.column, 
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- 3. BARRA INFERIOR CON REPRODUCTOR INTEGRADO ---
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
                // BOTÓN ANTERIOR
                if (hayAnterior)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: const Color(0xFFA96565),
                    onPressed: () {
                      _player.stop(); // Detener audio al cambiar
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
                  const SizedBox(width: 48),

                // --- PASTILLA CENTRAL (AUDIO + CONFIG) ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA96565),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      // 1. REPRODUCTOR DE AUDIO (SIEMPRE VISIBLE)
                      // Definimos si tiene audio o no
                      Builder(
                        builder: (context) {
                          bool tieneAudio = widget.himno.audioUrl != null && widget.himno.audioUrl!.isNotEmpty;
                          
                          return Row(
                            children: [
                              _cargandoAudio
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : IconButton(
                                    icon: Icon(_reproduciendo ? Icons.pause : Icons.play_arrow),
                                    iconSize: 24,
                                    // Si NO tiene audio, ponemos null (esto deshabilita el botón)
                                    onPressed: tieneAudio ? _toggleAudio : null,
                                    // Si NO tiene audio, se ve medio transparente
                                    color: tieneAudio ? Colors.white : Colors.white.withOpacity(0.3),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              
                              // Separador
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                width: 1,
                                height: 20,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ],
                          );
                        }
                      ),

                      // 2. CONFIGURACIÓN DE TEXTO
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
                      
                      SizedBox(
                        width: 30,
                        child: Text(
                          "${uiProvider.tamanoLetra.toInt()}",
                          textAlign: TextAlign.center,
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

                // BOTÓN SIGUIENTE
                if (haySiguiente)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: const Color(0xFFA96565),
                    onPressed: () {
                      _player.stop(); // Detener audio al cambiar
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
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}