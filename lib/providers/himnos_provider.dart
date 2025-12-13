import 'dart:convert';
import 'dart:io'; // Para guardar archivos en el celular
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Para leer el asset original
import 'package:shared_preferences/shared_preferences.dart'; // <--- AGREGAR
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
  // PEGA AQUÍ TU ENLACE CORTO (El que termina en /raw/himnos.json)
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
      _buscarActualizacionesEnNube();

    } catch (e) {
      log("Error crítico cargando datos", name: 'HimnosProvider', error: e);
      // Si todo falla, intentamos emergencia con assets
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
      _categorias = ["Todos", "Favoritos", ...categoriasUnicas]; // Mantenemos "Todos" primero

      _cargando = false;
      notifyListeners();
    } catch (e) {
      log("Error procesando JSON", name: 'HimnosProvider', error: e);
    }
  }

  // 3. ACTUALIZACIÓN DESDE INTERNET (OTA)
  Future<void> _buscarActualizacionesEnNube() async {
    try {
      log("Buscando actualizaciones en Gist...", name: 'HimnosProvider');
      final respuesta = await http.get(Uri.parse(_urlGist));

      if (respuesta.statusCode == 200) {
        final contenidoNube = respuesta.body;

        // VERIFICACIÓN DE SEGURIDAD: ¿Es un JSON válido?
        // Intentamos decodificarlo solo para ver si no está roto
        json.decode(contenidoNube); 

        // Si llegó hasta aquí, el JSON es válido. Lo guardamos.
        final directorio = await getApplicationDocumentsDirectory();
        final archivoLocal = File('${directorio.path}/$_nombreArchivoLocal');
        
        // Comparamos si es diferente a lo que ya tenemos para no guardar por gusto
        // (Opcional, por ahora guardamos siempre para asegurar la última versión)
        await archivoLocal.writeAsString(contenidoNube);
        log("¡Himnos actualizados y guardados en el celular!", name: 'HimnosProvider');
        
        // OPCIONAL: Podríamos recargar la lista en vivo aquí llamando a _procesarJson(contenidoNube)
        // Pero mejor dejamos que se aplique la próxima vez que abra la app para no moverle la pantalla al usuario.
        
      } else {
        log("Error conectando con Gist: ${respuesta.statusCode}", name: 'HimnosProvider');
      }
    } catch (e) {
      // Si no hay internet o falla algo, no pasa nada. El usuario sigue feliz con su versión local.
      log("No se pudo actualizar (probablemente sin internet)", name: 'HimnosProvider');
    }
  }

  // Auxiliar de emergencia
  Future<void> _cargarDesdeAssetsEmergencia() async {
    final jsonString = await rootBundle.loadString('assets/himnos.json');
    _procesarJson(jsonString);
  }

  // --- LÓGICA DE FILTRADO (Igual que antes) ---
  void seleccionarCategoria(String categoria) {
    _categoriaSeleccionada = categoria;
    if (categoria == "Todos") {
      _himnosFiltrados = List.from(_himnosOriginales);
    } 
    else if (categoria == "Favoritos") {
      // NUEVO: Filtra solo los que están en la lista de favoritos
      _himnosFiltrados = _himnosOriginales
          .where((h) => _idsFavoritos.contains(h.id))
          .toList();
    }
    else {
      _himnosFiltrados = _himnosOriginales.where((h) => h.categoria == categoria).toList();
    }
    notifyListeners();
  }

  // --- BUSCADOR PROFUNDO (TÍTULO + NÚMERO + LETRA) ---
  void buscar(String query) {
    // 1. Definir dónde vamos a buscar (Todos o Categoría específica)
    List<Himno> baseDeBusqueda;
    if (_categoriaSeleccionada == "Todos") {
      baseDeBusqueda = _himnosOriginales;
    } 
    else if (_categoriaSeleccionada == "Favoritos") {
      // Si estamos en Favoritos, la base son solo los que tienen corazón
      baseDeBusqueda = _himnosOriginales
          .where((h) => _idsFavoritos.contains(h.id))
          .toList();
    }
    else {
      baseDeBusqueda = _himnosOriginales.where((h) => h.categoria == _categoriaSeleccionada).toList();
    }

    // 2. Si no escribe nada, mostramos todo lo de esa categoría
    if (query.isEmpty) {
      _himnosFiltrados = baseDeBusqueda;
      notifyListeners();
      return;
    }

    final consulta = query.toLowerCase();
    
    // 3. FILTRADO INTELIGENTE
    _himnosFiltrados = baseDeBusqueda.where((himno) {
      // A. ¿Coincide el número?
      final coincideNumero = himno.numero.toString().startsWith(consulta);
      
      // B. ¿Coincide el título?
      final coincideTitulo = himno.titulo.toLowerCase().contains(consulta);
      
      // C. ¿Coincide la letra? (NUEVO)
      // Quitamos saltos de línea para buscar mejor
      final coincideLetra = himno.letra.toLowerCase().contains(consulta);

      // Si cumple CUALQUIERA de las 3 condiciones, pasa el filtro
      return coincideNumero || coincideTitulo || coincideLetra;
    }).toList();

    notifyListeners();
  }

  // --- LÓGICA DE FAVORITOS (PEGAR AL FINAL) ---
  
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
    
    // Si estamos viendo la lista de favoritos, actualizamos la pantalla
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