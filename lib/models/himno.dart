class Himno {
  final String id;          // Un identificador único (ej: "rojo_001")
  final int numero;         // El número del himno (ej: 14)
  final String titulo;      // "Santo, Santo, Santo"
  final String letra;       // El texto completo
  final String categoria;   // "Libro Rojo", "Libro Verde", "Especial"
  final String? acordes;    // (Opcional) Las notas para los músicos
  bool esFavorito;          // Estado para el corazón (se guarda localmente)

  Himno({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.letra,
    required this.categoria,
    this.acordes,
    this.esFavorito = false,
  });

  factory Himno.fromJson(Map<String, dynamic> json){
    return Himno(
      id: json['id'],
      numero: json['numero'],
      titulo: json['titulo'],
      letra: json['letra'],
      categoria: json['categoria'],
      acordes: json['acordes'],
      esFavorito: false,
    );
  }
}