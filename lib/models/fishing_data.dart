class FishingData {
  final String tipoPesca;
  final String nroPesca;
  final String nroGuia;
  final DateTime fechaGuia;
  final String camaronera;
  final String piscina;
  final String? inicioPesca;
  final String? finPesca;
  final String? fechaCamaroneraPlanta;
  final String? fechaLlegadaCamaronera;
  final int? totalKilosRemitidos;

  FishingData({
    required this.tipoPesca,
    required this.nroPesca,
    required this.nroGuia,
    required this.fechaGuia,
    required this.camaronera,
    required this.piscina,
    this.inicioPesca,
    this.finPesca,
    this.fechaCamaroneraPlanta,
    this.fechaLlegadaCamaronera,
    this.totalKilosRemitidos,
  });

  factory FishingData.fromJson(Map<String, dynamic> json) {
    return FishingData(
      tipoPesca: json['tipoPesca'] ?? '', // Provee valor por defecto
      nroPesca: json['nroPesca'] ?? '',
      nroGuia: json['nroGuia'] ?? '',
      fechaGuia: DateTime.parse(
        json['fechaGuia'] ?? DateTime.now().toIso8601String(),
      ),
      camaronera: (json['camaronera']?.toString().trim() ?? ''),
      piscina: (json['piscina']?.toString().trim() ?? ''),
      inicioPesca: json['inicioPesca'],
      finPesca: json['finPesca'],
      fechaCamaroneraPlanta:
          json['fechaCamaroneraPlanta']?.toString().isEmpty ?? true
          ? null
          : json['fechaCamaroneraPlanta'],
      fechaLlegadaCamaronera:
          json['fechaLlegadaCamaronera']?.toString().isEmpty ?? true
          ? null
          : json['fechaLlegadaCamaronera'],
      totalKilosRemitidos: json['TotalKilosRemitidos'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nroGuia': nroGuia,
      'tipoPesca': tipoPesca,
      'nroPesca': nroPesca,
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
}
