import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer'; // Para logs profesionales
import '../models/himno.dart';

class HimnosProvider extends ChangeNotifier {
  // 1. DOS LISTAS
  List<Himno> _himnosOriginales = []; // La "Bodega" maestra
  List<Himno> _himnosFiltrados = [];  // Lo que mostramos en pantalla
  
  bool _cargando = true;

  // Getters
  List<Himno> get himnos => _himnosFiltrados; // ¡La pantalla solo ve la filtrada!
  bool get cargando => _cargando;

  HimnosProvider() {
    log("Inicializando Provider...", name: 'HimnosProvider');
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final String respuesta = await rootBundle.loadString('assets/himnos.json');
      final List<dynamic> datosList = json.decode(respuesta);

      _himnosOriginales = datosList.map((item) => Himno.fromJson(item)).toList();
      
      // Al principio, la lista filtrada es IGUAL a la original (mostramos todo)
      _himnosFiltrados = List.from(_himnosOriginales);
      
      _cargando = false;
      log("Datos cargados: ${_himnosOriginales.length} himnos", name: 'HimnosProvider');
      notifyListeners();
    
    } catch (e) {
      log("Error cargando himnos", name: 'HimnosProvider', error: e);
      _cargando = false;
      notifyListeners();
    }
  }

  // --- LÓGICA DEL BUSCADOR HÍBRIDO ---
  void buscar(String query) {
    // Si la búsqueda está vacía, restablecemos la lista completa
    if (query.isEmpty) {
      _himnosFiltrados = List.from(_himnosOriginales);
      notifyListeners();
      return;
    }

    final consulta = query.toLowerCase(); // Convertimos a minúsculas para ignorar mayúsculas

    // ¿Es un número? Intentamos convertirlo
    final esNumero = int.tryParse(query) != null;

    if (esNumero) {
      // BÚSQUEDA POR NÚMERO
      // Buscamos himnos que empiecen con ese número (ej: "1" encuentra 1, 10, 100...)
      _himnosFiltrados = _himnosOriginales.where((himno) {
        return himno.numero.toString().startsWith(query);
      }).toList();
    } else {
      // BÚSQUEDA POR TEXTO (Título o Letra)
      _himnosFiltrados = _himnosOriginales.where((himno) {
        final tituloMatch = himno.titulo.toLowerCase().contains(consulta);
        // Opcional: Descomenta la siguiente línea si quieres buscar también en la letra
        // final letraMatch = himno.letra.toLowerCase().contains(consulta);
        
        return tituloMatch; // || letraMatch; // (Usa || para buscar en ambos)
      }).toList();
    }

    notifyListeners(); // ¡Avisamos a la pantalla que la lista cambió!
  }
}