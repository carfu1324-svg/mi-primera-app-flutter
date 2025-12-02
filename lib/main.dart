import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: El paquete

// ---------------------------------------------------------
// PIEZA 1: LA ESTACIÓN DE RADIO (El Modelo)
// Aquí vive la lógica. No hay widgets, solo datos.
// ---------------------------------------------------------
class SemaforoModel extends ChangeNotifier {
  String _colorActual = "Rojo"; // Dato privado

  // Getter para que los demás puedan ver el color
  String get colorString => _colorActual;

  // Método para cambiar el color
  void cambiarColor() {
    if (_colorActual == "Rojo") {
      _colorActual = "Verde";
    } else {
      _colorActual = "Rojo";
    }
    
    // ¡EL GRITO! "¡Oigan todos, cambié de color!"
    // Sin esta línea, la pantalla nunca se enteraría.
    notifyListeners(); 
  }
}

// ---------------------------------------------------------
// PIEZA 2: LA ANTENA (El Main)
// Envolvemos la app para que la señal llegue a todos lados.
// ---------------------------------------------------------
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SemaforoModel(), // Encendemos la estación aquí
      child: const MaterialApp(
        home: PantallaSemaforo(),
      ),
    ),
  );
}

// ---------------------------------------------------------
// PIEZA 3: EL RADIOYENTE (La Pantalla)
// Fíjate que es un Stateless widget. ¡No necesita setState!
// ---------------------------------------------------------
class PantallaSemaforo extends StatelessWidget {
  const PantallaSemaforo({super.key});

  @override
  Widget build(BuildContext context) {
    
    // ESCUCHAMOS (WATCH):
    // "Dame el modelo del semáforo y avísame si algo cambia".
    // guardamos el modelo en una variable para usarlo fácil.
    final semaforo = context.watch<SemaforoModel>();

    // Lógica visual simple: Convertimos el texto a un Color real
    Color colorDeFondo;
    if (semaforo.colorString == "Rojo") {
      colorDeFondo = Colors.red;
    } else {
      colorDeFondo = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Semáforo con Provider')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Este contenedor cambiará de color automáticamente
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorDeFondo, // Usamos el color que calculamos arriba
                shape: BoxShape.circle, // Forma de círculo
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Color actual: ${semaforo.colorString}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ACCIÓN (READ):
          // Aquí usamos 'read' porque solo queremos dar la orden,
          // no necesitamos "escuchar" dentro del botón.
          context.read<SemaforoModel>().cambiarColor();
        },
        child: const Icon(Icons.traffic),
      ),
    );
  }
}