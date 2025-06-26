class KilosRemitidos {
  final int? id; // Para la base de datos local
  final String tipoPesca;
  final String nroPesca;
  final String nroGuia;
  final DateTime fechaGuia;
  final String camaronera;
  final String piscina;
  final String inicioPesca;
  final String finPesca;
  final String fechaCamaroneraPlanta;
  final String fechaLlegadaCamaronera;
  final int totalKilosRemitidos;

  KilosRemitidos({
    this.id,
    required this.tipoPesca,
    required this.nroPesca,
    required this.nroGuia,
    required this.fechaGuia,
    required this.camaronera,
    required this.piscina,
    required this.inicioPesca,
    required this.finPesca,
    required this.fechaCamaroneraPlanta,
    required this.fechaLlegadaCamaronera,
    required this.totalKilosRemitidos,
  });

  factory KilosRemitidos.fromApiJson(Map<String, dynamic> json) {
    return KilosRemitidos(
      tipoPesca: json['TipoPesca'],
      nroPesca: json['NroPesca'],
      nroGuia: json['NroGuia'],
      fechaGuia: DateTime.parse(json['FechaGuia']),
      camaronera: json['camaronera'].toString().trim(),
      piscina: json['Piscina'].toString().trim(),
      inicioPesca: json['InicioPesca'],
      finPesca: json['FinPesca'],
      fechaCamaroneraPlanta: json['FechaCamaroneraPlanta'],
      fechaLlegadaCamaronera: json['FechaLlegadaCamaronera'],
      totalKilosRemitidos: json['TotalKilosRemitidos'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipoPesca': tipoPesca,
      'nroPesca': nroPesca,
      'nroGuia': nroGuia,
      'fechaGuia': fechaGuia.toIso8601String(),
      'camaronera': camaronera,
      'piscina': piscina,
      'inicioPesca': inicioPesca,
      'finPesca': finPesca,
      'fechaCamaroneraPlanta': fechaCamaroneraPlanta,
      'fechaLlegadaCamaronera': fechaLlegadaCamaronera,
      'totalKilosRemitidos': totalKilosRemitidos,
    };
  }

  KilosRemitidos copyWith({
    int? id,
    String? tipoPesca,
    String? nroPesca,
    String? nroGuia,
    DateTime? fechaGuia,
    String? camaronera,
    String? piscina,
    String? inicioPesca,
    String? finPesca,
    String? fechaCamaroneraPlanta,
    String? fechaLlegadaCamaronera,
    int? totalKilosRemitidos,
  }) {
    return KilosRemitidos(
      id: id ?? this.id,
      tipoPesca: tipoPesca ?? this.tipoPesca,
      nroPesca: nroPesca ?? this.nroPesca,
      nroGuia: nroGuia ?? this.nroGuia,
      fechaGuia: fechaGuia ?? this.fechaGuia,
      camaronera: camaronera ?? this.camaronera,
      piscina: piscina ?? this.piscina,
      inicioPesca: inicioPesca ?? this.inicioPesca,
      finPesca: finPesca ?? this.finPesca,
      fechaCamaroneraPlanta:
          fechaCamaroneraPlanta ?? this.fechaCamaroneraPlanta,
      fechaLlegadaCamaronera:
          fechaLlegadaCamaronera ?? this.fechaLlegadaCamaronera,
      totalKilosRemitidos: totalKilosRemitidos ?? this.totalKilosRemitidos,
    );
  }
}
