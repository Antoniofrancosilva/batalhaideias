class Ideia {
  final String id;
  final String titulo;
  final String descricao;
  final String autor;
  final int votos;

  const Ideia({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.votos,
  });

  factory Ideia.fromMap(String id, Map<String, dynamic> dados) {
    return Ideia(
      id: id,
      titulo: dados['titulo']?.toString() ?? '',
      descricao: dados['descricao']?.toString() ?? '',
      autor: dados['autor']?.toString() ?? '',
      votos: dados['votos'] is num ? (dados['votos'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'autor': autor,
      'votos': votos,
    };
  }
}
