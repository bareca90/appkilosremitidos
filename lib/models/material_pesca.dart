class MaterialPesca {
  final String tipoPesca;
  final String nroPesca;
  final String nroGuia;
  final DateTime fechaGuia;
  final String camaronera;
  final String codPiscina;
  final String piscina;
  final String? ciclo;
  final int? anioSiembra;
  final int? lote;
  final String? ingresoCompra;
  final String? tipoMaterial;
  final int? cantidadMaterial;
  final String? unidadMedida;
  final double? cantidadRemitida;
  final double? gramaje;
  final String? proceso;
  final int tieneRegistro;

  MaterialPesca({
    required this.tipoPesca,
    required this.nroPesca,
    required this.nroGuia,
    required this.fechaGuia,
    required this.camaronera,
    required this.codPiscina,
    required this.piscina,
    this.ciclo,
    this.anioSiembra,
    this.lote,
    this.ingresoCompra,
    this.tipoMaterial,
    this.cantidadMaterial,
    this.unidadMedida,
    this.cantidadRemitida,
    this.gramaje,
    this.proceso,
    this.tieneRegistro = 0,
  });

  factory MaterialPesca.fromJson(Map<String, dynamic> json) {
    return MaterialPesca(
      tipoPesca: json['tipoPesca'] ?? '',
      nroPesca: json['nroPesca'] ?? '',
      nroGuia: json['nroGuia'] ?? '',
      fechaGuia: DateTime.parse(
        json['fechaGuia'] ?? DateTime.now().toIso8601String(),
      ),
      camaronera: (json['camaronera']?.toString().trim() ?? ''),
      codPiscina: (json['codPiscina']?.toString().trim() ?? ''),
      piscina: (json['piscina']?.toString().trim() ?? ''),
      ciclo: json['ciclo'],
      anioSiembra: json['anioSiembra'] != null
          ? int.tryParse(json['anioSiembra'].toString())
          : null,
      lote: json['lote'] != null ? int.tryParse(json['lote'].toString()) : null,
      ingresoCompra: json['ingresoCompra'],
      tipoMaterial: json['tipoMaterial'],
      cantidadMaterial: json['cantidadMaterial'] != null
          ? int.tryParse(json['cantidadMaterial'].toString())
          : null,
      unidadMedida: json['unidadMedida'],
      cantidadRemitida: json['cantidadRemitida'] != null
          ? double.tryParse(json['cantidadRemitida'].toString())
          : null,
      gramaje: json['gramaje'] != null
          ? double.tryParse(json['gramaje'].toString())
          : null,
      proceso: json['proceso'],
      tieneRegistro: json['tieneRegistro'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nroGuia': nroGuia,
      'tipoPesca': tipoPesca,
      'nroPesca': nroPesca,
      'fechaGuia': fechaGuia.toIso8601String(),
      'camaronera': camaronera,
      'codPiscina': codPiscina,
      'piscina': piscina,
      'ciclo': ciclo,
      'anioSiembra': anioSiembra,
      'lote': lote,
      'ingresoCompra': ingresoCompra,
      'tipoMaterial': tipoMaterial,
      'cantidadMaterial': cantidadMaterial,
      'unidadMedida': unidadMedida,
      'cantidadRemitida': cantidadRemitida,
      'gramaje': gramaje,
      'proceso': proceso,
      'tieneRegistro': tieneRegistro,
    };
  }

  MaterialPesca copyWith({
    String? tipoPesca,
    String? nroPesca,
    String? nroGuia,
    DateTime? fechaGuia,
    String? camaronera,
    String? codPiscina,
    String? piscina,
    String? ciclo,
    int? anioSiembra,
    int? lote,
    String? ingresoCompra,
    String? tipoMaterial,
    int? cantidadMaterial,
    String? unidadMedida,
    double? cantidadRemitida,
    double? gramaje,
    String? proceso,
    int? tieneRegistro,
  }) {
    return MaterialPesca(
      tipoPesca: tipoPesca ?? this.tipoPesca,
      nroPesca: nroPesca ?? this.nroPesca,
      nroGuia: nroGuia ?? this.nroGuia,
      fechaGuia: fechaGuia ?? this.fechaGuia,
      camaronera: camaronera ?? this.camaronera,
      codPiscina: codPiscina ?? this.codPiscina,
      piscina: piscina ?? this.piscina,
      ciclo: ciclo ?? this.ciclo,
      anioSiembra: anioSiembra ?? this.anioSiembra,
      lote: lote ?? this.lote,
      ingresoCompra: ingresoCompra ?? this.ingresoCompra,
      tipoMaterial: tipoMaterial ?? this.tipoMaterial,
      cantidadMaterial: cantidadMaterial ?? this.cantidadMaterial,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      cantidadRemitida: cantidadRemitida ?? this.cantidadRemitida,
      gramaje: gramaje ?? this.gramaje,
      proceso: proceso ?? this.proceso,
      tieneRegistro: tieneRegistro ?? this.tieneRegistro,
    );
  }
}
