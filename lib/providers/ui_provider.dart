import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- Importante

class UiProvider extends ChangeNotifier {
  // Valores por defecto
  double _tamanoLetra = 18.0;
  bool _mostrarAcordes = false;
  int _indiceFuente = 0;
  bool _modoOscuro = false;
  final List<String> _listaFuentes = ['Lato', 'Merriweather', 'Dancing Script'];

  // Getters
  double get tamanoLetra => _tamanoLetra;
  bool get mostrarAcordes => _mostrarAcordes;
  String get fuenteActual => _listaFuentes[_indiceFuente];
  bool get modoOscuro => _modoOscuro;

  // CONSTRUCTOR: Cargar memoria al iniciar
  UiProvider() {
    _cargarPreferencias();
  }

  // --- 1. FUNCIÓN PARA CARGAR (LEER) ---
  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Leemos o usamos el valor por defecto si no existe
    _tamanoLetra = prefs.getDouble('tamanoLetra') ?? 18.0;
    _mostrarAcordes = prefs.getBool('mostrarAcordes') ?? false;
    _indiceFuente = prefs.getInt('indiceFuente') ?? 0;
    _modoOscuro = prefs.getBool('modoOscuro') ?? false;
    notifyListeners(); // Actualizamos la UI con los datos guardados
  }

  // --- 2. FUNCIÓN PARA GUARDAR (ESCRIBIR) ---
  Future<void> _guardarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setDouble('tamanoLetra', _tamanoLetra);
    prefs.setBool('mostrarAcordes', _mostrarAcordes);
    prefs.setInt('indiceFuente', _indiceFuente);
    prefs.setBool('modoOscuro',_modoOscuro);
    // Nota: No necesitamos notifyListeners() aquí porque ya se llamó al cambiar el valor
  }

  // --- FUNCIONES LÓGICAS (Modificadas para guardar) ---

  void aumentarLetra() {
    if (_tamanoLetra < 40.0) {
      _tamanoLetra += 2.0;
      _guardarPreferencias(); // <--- Guardamos cada cambio
      notifyListeners();
    }
  }

  void disminuirLetra() {
    if (_tamanoLetra > 12.0) {
      _tamanoLetra -= 2.0;
      _guardarPreferencias(); // <--- Guardamos cada cambio
      notifyListeners();
    }
  }

  void toggleAcordes() {
    _mostrarAcordes = !_mostrarAcordes;
    _guardarPreferencias(); // <--- Guardamos cada cambio
    notifyListeners();
  }

  void cambiarFuente() {
    if (_indiceFuente < _listaFuentes.length - 1) {
      _indiceFuente++;
    } else {
      _indiceFuente = 0;
    }
    _guardarPreferencias(); // <--- Guardamos cada cambio
    notifyListeners();
  }

  void temaDispositivo() {
    _modoOscuro = !_modoOscuro;
    _guardarPreferencias();
    notifyListeners();
  }

 // bool _modoOscuro = false; // Empieza en modo claro
 // bool get modoOscuro => _modoOscuro;

  void alternarTema() {
    _modoOscuro = !_modoOscuro;
    _guardarPreferencias(); // Cambia de true a false y viceversa
    notifyListeners();
  }
}