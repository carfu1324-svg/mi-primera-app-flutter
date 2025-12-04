import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necesario
// Imports de tus archivos
import 'providers/himnos_provider.dart';
import 'screens/home_screen.dart'; 

void main() {
  runApp(const EstadoDeLaApp());
}

// 1. Widget intermedio para manejar los Providers
class EstadoDeLaApp extends StatelessWidget {
  const EstadoDeLaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Aquí registramos nuestro cerebro de Himnos
        ChangeNotifierProvider(create: (_) => HimnosProvider()),
        
        // (Próximamente aquí pondremos el UiProvider)
      ],
      child: const MiHimnarioApp(),
    );
  }
}

// 2. Tu App real
class MiHimnarioApp extends StatelessWidget {
  const MiHimnarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Himnario App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      // 3. Definimos la pantalla de inicio (que crearemos en el sig. paso)
      home: const HomeScreen(), 
    );
  }
}