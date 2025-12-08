import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  double _tamanoLetra = 18.0;
  bool _mostrarAcordes = false;
  
  // 1. NUEVAS VARIABLES PARA FUENTE
  int _indiceFuente = 0; // Para saber en cuál de la lista vamos
  final List<String> _listaFuentes = ['Lato', 'Merriweather', 'Dancing Script'];
  // Lato: Moderna y limpia
  // Merriweather: Clásica de libro (con serifa)
  // Dancing Script: Elegante / Manuscrita

  // Getters
  double get tamanoLetra => _tamanoLetra;
  bool get mostrarAcordes => _mostrarAcordes;
  String get fuenteActual => _listaFuentes[_indiceFuente]; // Devuelve el nombre actual

  // ... (Tus funciones de aumentar/disminuir letra y acordes siguen aquí igual) ...

  void aumentarLetra() {
    if (_tamanoLetra < 40.0) { // Subí el límite a 40 para que se note más
      _tamanoLetra += 2.0;
      notifyListeners();
    }
  }

  void disminuirLetra() {
    if (_tamanoLetra > 12.0) {
      _tamanoLetra -= 2.0;
      notifyListeners();
    }
  }

  void toggleAcordes() {
    _mostrarAcordes = !_mostrarAcordes;
    notifyListeners();
  }

  // 2. NUEVA FUNCIÓN: CAMBIAR FUENTE
  void cambiarFuente() {
    // Ciclo: 0 -> 1 -> 2 -> 0 ...
    if (_indiceFuente < _listaFuentes.length - 1) {
      _indiceFuente++;
    } else {
      _indiceFuente = 0; // Vuelve al principio
    }
    notifyListeners();
  }
}