class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String descricao;
  final int categoriaId;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.descricao = '',
  });

  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria']['nome'] ?? json['categoria']["nome"],
      categoriaId: json['categoriaId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      descricao: json['descricao'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'categoriaId': categoriaId,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
    };
  }
}