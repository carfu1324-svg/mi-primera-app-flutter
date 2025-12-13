import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer'; 
import '../models/himno.dart';

class HimnosProvider extends ChangeNotifier {
  List<Himno> _himnosOriginales = []; 
  List<Himno> _himnosFiltrados = [];  
  
  // 1. NUEVA VARIABLE: LISTA DE CATEGORÍAS ÚNICAS
  List<String> _categorias = ["Todos"]; 
  String _categoriaSeleccionada = "Todos"; // Cuál botón está activo

  bool _cargando = true;

  // Getters
  List<Himno> get himnos => _himnosFiltrados;
  bool get cargando => _cargando;
  List<String> get categorias => _categorias;
  String get categoriaSeleccionada => _categoriaSeleccionada;

  HimnosProvider() {
    log("Inicializando Provider...", name: 'HimnosProvider');
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final String respuesta = await rootBundle.loadString('assets/himnos.json');
      final List<dynamic> datosList = json.decode(respuesta);

      _himnosOriginales = datosList.map((item) => Himno.fromJson(item)).toList();
      _himnosFiltrados = List.from(_himnosOriginales);
      
      // 2. MAGIA: EXTRAER CATEGORÍAS AUTOMÁTICAMENTE
      // Mapeamos todas las categorías, las convertimos en un Set (para borrar duplicados) y luego a lista
      final categoriasUnicas = _himnosOriginales.map((h) => h.categoria).toSet().toList();
      _categorias = ["Todos", ...categoriasUnicas]; // Agregamos "Todos" al principio
      
      _cargando = false;
      log("Datos cargados: ${_himnosOriginales.length} himnos", name: 'HimnosProvider');
      notifyListeners();
    
    } catch (e) {
      log("Error cargando himnos", name: 'HimnosProvider', error: e);
      _cargando = false;
      notifyListeners();
    }
  }

  // --- LÓGICA DE FILTRADO POR CATEGORÍA ---
  void seleccionarCategoria(String categoria) {
    _categoriaSeleccionada = categoria;
    
    if (categoria == "Todos") {
      _himnosFiltrados = List.from(_himnosOriginales);
    } else {
      _himnosFiltrados = _himnosOriginales.where((h) => h.categoria == categoria).toList();
    }
    notifyListeners();
  }

  // --- BUSCADOR (Modificado para respetar la categoría actual) ---
  void buscar(String query) {
    // Primero filtramos por la categoría que esté seleccionada
    List<Himno> baseDeBusqueda;
    if (_categoriaSeleccionada == "Todos") {
      baseDeBusqueda = _himnosOriginales;
    } else {
      baseDeBusqueda = _himnosOriginales.where((h) => h.categoria == _categoriaSeleccionada).toList();
    }

    if (query.isEmpty) {
      _himnosFiltrados = baseDeBusqueda;
      notifyListeners();
      return;
    }

    final consulta = query.toLowerCase();
    final esNumero = int.tryParse(query) != null;

    if (esNumero) {
      _himnosFiltrados = baseDeBusqueda.where((himno) {
        return himno.numero.toString().startsWith(query);
      }).toList();
    } else {
      _himnosFiltrados = baseDeBusqueda.where((himno) {
        return himno.titulo.toLowerCase().contains(consulta);
      }).toList();
    }

    notifyListeners();
  }
}