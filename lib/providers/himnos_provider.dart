import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer'; // <--- 1. IMPORTANTE: La herramienta de logging profesional
import '../models/himno.dart';

class HimnosProvider extends ChangeNotifier {
  List<Himno> _himnos = [];
  bool _cargando = true;

  List<Himno> get himnos => _himnos;
  bool get cargando => _cargando;

  HimnosProvider() {
    // 2. Usamos log() en lugar de print()
    // 'name' nos ayuda a identificar de dónde viene el mensaje en la consola
    log("Inicializando Provider...", name: 'HimnosProvider'); 
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final String respuesta = await rootBundle.loadString('assets/himnos.json');
      final List<dynamic> datosList = json.decode(respuesta);

      _himnos = datosList.map((item) => Himno.fromJson(item)).toList();
      
      _cargando = false;
      
      // Mensaje de éxito profesional
      log("Datos cargados: ${_himnos.length} himnos", name: 'HimnosProvider');
      
      notifyListeners();
    
    } catch (e) {
      // Para errores, log tiene un parámetro 'error' especial
      log("Error cargando himnos", name: 'HimnosProvider', error: e);
    }
  }
}