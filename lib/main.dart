import 'package:flutter/material.dart';

// 1. Iniciamos la app
void main() {
  runApp(const MyApp());
}

// 2. El widget raíz (Stateless)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la cinta de "DEBUG"
      home: Scaffold( // El lienzo de la app
        appBar: AppBar(
          title: Text('Mi Perfil'),
        ),
        // 3. El body será nuestro layout
        body: MiPaginaPerfilPrueba1(),
      ),
    );
  }
}

// Mi widget Personalizado
class MiPaginaPerfilPrueba1 extends StatelessWidget{
  const MiPaginaPerfilPrueba1({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.green[100],
      width: double.infinity,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          SizedBox(height: 40),
          Icon(Icons.person, size: 100),
          SizedBox(height: 20),
          Text(
            'Beto Lara', 
            style: TextStyle(fontSize: 18, color: Colors.grey [600]),
            ),
          SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.phone),
              SizedBox(width: 10),
              Text(
                "+51 999 555 222", 
                style: TextStyle(fontSize: 18, color: Colors.grey [600]),
                ), 
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.email),
              SizedBox(width: 10),
              Text(
                'beto.lara@email.com', 
                style: TextStyle(fontSize: 18, color: Colors.grey [600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}