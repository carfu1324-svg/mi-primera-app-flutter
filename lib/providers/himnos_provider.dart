import 'dart:convert';
import 'dart:io'; // Para guardar archivos en el celular
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Para leer el asset original
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Para descargar de internet
import 'package:path_provider/path_provider.dart'; // Para encontrar la ruta
import 'dart:developer'; 
import '../models/himno.dart';

class HimnosProvider extends ChangeNotifier {
  // --- VARIABLES DE DATOS ---
  List<Himno> _himnosOriginales = []; 
  List<Himno> _himnosFiltrados = [];
  List<String> _idsFavoritos = [];
  List<String> _categorias = ["Todos", "Favoritos"];
  String _categoriaSeleccionada = "Todos"; 
  bool _cargando = true;

  // --- CONFIGURACIÓN DE ACTUALIZACIÓN ---
  static const String _urlGist = "https://gist.githubusercontent.com/carfu1324-svg/5465e889e4ed18b75d29acf9c812c718/raw/himnos.json";
  static const String _nombreArchivoLocal = "himnos_local_v1.json";

  // Getters
  List<Himno> get himnos => _himnosFiltrados;
  bool get cargando => _cargando;
  List<String> get categorias => _categorias;
  String get categoriaSeleccionada => _categoriaSeleccionada;

  HimnosProvider() {
    log("Inicializando Provider Híbrido...", name: 'HimnosProvider');
    cargarDatosHibridos();
  }

  // ==========================================================
  //  NUEVO: FUNCIÓN PARA EL BOTÓN "ACTUALIZAR"
  // ==========================================================
  Future<bool> recargarLista() async {
    _cargando = true;
    notifyListeners(); // Muestra spinner si quieres

    // Llamamos a la nube forzando la actualización en memoria visual
    bool exito = await _buscarActualizacionesEnNube(aplicarCambiosVisuales: true);
    
    // Si falló la descarga, al menos volvemos a mostrar lo que ya teníamos
    if (!exito) {
      _cargando = false;
      notifyListeners();
    }
    
    return exito; // Retorna true o false para mostrar el SnackBar en la pantalla
  }
  // ==========================================================


  // 1. EL CEREBRO DE CARGA
  Future<void> cargarDatosHibridos() async {
    await _cargarFavoritosGuardados();
    try {
      final directorio = await getApplicationDocumentsDirectory();
      final archivoLocal = File('${directorio.path}/$_nombreArchivoLocal');

      String jsonString;

      // PASO A: ¿Existe una versión descargada en el celular?
      if (await archivoLocal.exists()) {
        log("Cargando desde almacenamiento local (Bolsillo Derecho)", name: 'HimnosProvider');
        jsonString = await archivoLocal.readAsString();
      } else {
        // PASO B: No existe, usamos la de fábrica
        log("Cargando desde Assets (Bolsillo Izquierdo)", name: 'HimnosProvider');
        jsonString = await rootBundle.loadString('assets/himnos.json');
      }

      // Procesamos los datos
      _procesarJson(jsonString);

      // PASO C: (Silencioso) Buscar actualizaciones en internet
      // Aquí NO aplicamos cambios visuales inmediatos para no asustar al usuario que acaba de entrar
      _buscarActualizacionesEnNube(aplicarCambiosVisuales: false);

    } catch (e) {
      log("Error crítico cargando datos", name: 'HimnosProvider', error: e);
      await _cargarDesdeAssetsEmergencia();
    }
  }

  // 2. PROCESAR JSON Y EXTRAER CATEGORÍAS
  void _procesarJson(String jsonString) {
    try {
      final List<dynamic> datosList = json.decode(jsonString);
      _himnosOriginales = datosList.map((item) => Himno.fromJson(item)).toList();
      
      // Filtrado inicial
      if (_categoriaSeleccionada == "Todos") {
        _himnosFiltrados = List.from(_himnosOriginales);
      } else {
        seleccionarCategoria(_categoriaSeleccionada);
      }

      // Extraer categorías únicas
      final categoriasUnicas = _himnosOriginales.map((h) => h.categoria).toSet().toList();
      _categorias = ["Todos", "Favoritos", ...categoriasUnicas];

      _cargando = false;
      notifyListeners();
    } catch (e) {
      log("Error procesando JSON", name: 'HimnosProvider', error: e);
    }
  }

  // 3. ACTUALIZACIÓN DESDE INTERNET (CON TRUCO ANTI-CACHÉ)
  Future<bool> _buscarActualizacionesEnNube({required bool aplicarCambiosVisuales}) async {
    try {
      log("Buscando actualizaciones en Gist...", name: 'HimnosProvider');
      
      // --- EL TRUCO DEL TIMESTAMP ---
      // Agregamos ?v=1234567 al final de la URL. 
      // El servidor ignora esto, pero el celular cree que es una página nueva y descarga de nuevo.
      final String urlSinCache = "$_urlGist?v=${DateTime.now().millisecondsSinceEpoch}";
      
      final respuesta = await http.get(Uri.parse(urlSinCache));

      if (respuesta.statusCode == 200) {
        final contenidoNube = respuesta.body;

        // VERIFICACIÓN DE SEGURIDAD
        json.decode(contenidoNube); 

        // Guardar en disco
        final directorio = await getApplicationDocumentsDirectory();
        final archivoLocal = File('${directorio.path}/$_nombreArchivoLocal');
        await archivoLocal.writeAsString(contenidoNube);
        log("¡Himnos actualizados y guardados!", name: 'HimnosProvider');
        
        // Si el usuario presionó el botón manual, actualizamos la lista YA MISMO.
        if (aplicarCambiosVisuales) {
           _procesarJson(contenidoNube);
        }
        
        return true; // Éxito
      } else {
        log("Error conectando con Gist: ${respuesta.statusCode}", name: 'HimnosProvider');
        return false; // Fallo
      }
    } catch (e) {
      log("No se pudo actualizar (sin internet)", name: 'HimnosProvider');
      return false; // Fallo
    }
  }

  // Auxiliar de emergencia
  Future<void> _cargarDesdeAssetsEmergencia() async {
    final jsonString = await rootBundle.loadString('assets/himnos.json');
    _procesarJson(jsonString);
  }

  // --- LÓGICA DE FILTRADO ---
  void seleccionarCategoria(String categoria) {
    _categoriaSeleccionada = categoria;
    if (categoria == "Todos") {
      _himnosFiltrados = List.from(_himnosOriginales);
    } 
    else if (categoria == "Favoritos") {
      _himnosFiltrados = _himnosOriginales
          .where((h) => _idsFavoritos.contains(h.id))
          .toList();
    }
    else {
      _himnosFiltrados = _himnosOriginales.where((h) => h.categoria == categoria).toList();
    }
    notifyListeners();
  }

  // --- BUSCADOR ---
  void buscar(String query) {
    List<Himno> baseDeBusqueda;
    if (_categoriaSeleccionada == "Todos") {
      baseDeBusqueda = _himnosOriginales;
    } 
    else if (_categoriaSeleccionada == "Favoritos") {
      baseDeBusqueda = _himnosOriginales
          .where((h) => _idsFavoritos.contains(h.id))
          .toList();
    }
    else {
      baseDeBusqueda = _himnosOriginales.where((h) => h.categoria == _categoriaSeleccionada).toList();
    }

    if (query.isEmpty) {
      _himnosFiltrados = baseDeBusqueda;
      notifyListeners();
      return;
    }

    final consulta = query.toLowerCase();
    
    _himnosFiltrados = baseDeBusqueda.where((himno) {
      final coincideNumero = himno.numero.toString().startsWith(consulta);
      final coincideTitulo = himno.titulo.toLowerCase().contains(consulta);
      final coincideLetra = himno.letra.toLowerCase().contains(consulta);
      return coincideNumero || coincideTitulo || coincideLetra;
    }).toList();

    notifyListeners();
  }

  // --- LÓGICA DE FAVORITOS ---
  bool esFavorito(String id) {
    return _idsFavoritos.contains(id);
  }

  Future<void> toggleFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (_idsFavoritos.contains(id)) {
      _idsFavoritos.remove(id);
    } else {
      _idsFavoritos.add(id);
    }
    
    await prefs.setStringList('lista_favoritos', _idsFavoritos);
    
    if (_categoriaSeleccionada == "Favoritos") {
      seleccionarCategoria("Favoritos");
    }
    notifyListeners();
  }

  Future<void> _cargarFavoritosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    _idsFavoritos = prefs.getStringList('lista_favoritos') ?? [];
    notifyListeners();
  }
}