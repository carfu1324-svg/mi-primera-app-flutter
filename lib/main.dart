import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/himnos_provider.dart';
import 'providers/ui_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HimnosProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al UiProvider para saber si cambiar el color
    final uiProvider = context.watch<UiProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Himnario App',
      
      // TEMA CLARO (LIGHT)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo, // Color base
        scaffoldBackgroundColor: Color(0xFFF7F0F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFA96565),
          foregroundColor: Colors.white, // Texto blanco en barra azul
          elevation: 2,
        ),
      ),

      // TEMA OSCURO (DARK)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo, // Mantenemos el toque azul
        scaffoldBackgroundColor: const Color(0xFF121212), // Negro suave
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Aquí decidimos cuál usar según el interruptor
      themeMode: uiProvider.modoOscuro ? ThemeMode.dark : ThemeMode.light,
      
      home: const HomeScreen(),
    );
  }
}