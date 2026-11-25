class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String descricao;
  final int categoriaId;
  final String? imagem;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.descricao = '',
    this.imagem,
  });

  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    String? nomeCategoria;
    if (json['categoria'] is Map) {
      nomeCategoria = json['categoria']['nome']?.toString();
    } else if (json['categoria'] != null) {
      nomeCategoria = json['categoria'].toString();
    }

    String? img = (json['imagem'] ??
            json['foto'] ??
            json['imagemUrl'] ??
            json['image'] ??
            json['url_imagem'])
        ?.toString();

    if (img != null && img.isNotEmpty && img.startsWith('/')) {
      img = 'https://guia.liliaborges.com.br$img';
    }

    return LugaresModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome']?.toString() ?? '',
      categoria: nomeCategoria,
      categoriaId: int.tryParse(
            (json['categoriaId'] ?? json['categoria_id'] ?? '0').toString(),
          ) ??
          0,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      descricao: json['descricao']?.toString() ?? '',
      imagem: (img != null && img.isNotEmpty) ? img : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'categoriaId': categoriaId,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
      if (imagem != null && imagem!.isNotEmpty) 'imagem': imagem,
    };
  }
}
