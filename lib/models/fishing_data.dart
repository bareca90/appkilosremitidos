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
  final int tieneInicioPesca;
  final int tieneFinPesca;
  final int tieneSalidaCamaronera;
  final int tieneLlegadaCamaronera;
  final int tieneKilosRemitidos;

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
    this.tieneInicioPesca = 0,
    this.tieneFinPesca = 0,
    this.tieneSalidaCamaronera = 0,
    this.tieneLlegadaCamaronera = 0,
    this.tieneKilosRemitidos = 0,
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
      tieneInicioPesca: json['tieneInicioPesca'] ?? 0,
      tieneFinPesca: json['tieneFinPesca'] ?? 0,
      tieneSalidaCamaronera: json['tieneSalidaCamaronera'] ?? 0,
      tieneLlegadaCamaronera: json['tieneLlegadaCamaronera'] ?? 0,
      tieneKilosRemitidos: json['tieneKilosRemitidos'] ?? 0,
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
      'tieneInicioPesca': tieneInicioPesca,
      'tieneFinPesca': tieneFinPesca,
      'tieneSalidaCamaronera': tieneSalidaCamaronera,
      'tieneLlegadaCamaronera': tieneLlegadaCamaronera,
      'tieneKilosRemitidos': tieneKilosRemitidos,
    };
  }

  FishingData copyWith({
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
    int? tieneInicioPesca,
    int? tieneFinPesca,
    int? tieneSalidaCamaronera,
    int? tieneLlegadaCamaronera,
    int? tieneKilosRemitidos,
  }) {
    return FishingData(
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
      tieneInicioPesca: tieneInicioPesca ?? this.tieneInicioPesca,
      tieneFinPesca: tieneFinPesca ?? this.tieneFinPesca,
      tieneSalidaCamaronera:
          tieneSalidaCamaronera ?? this.tieneSalidaCamaronera,
      tieneLlegadaCamaronera:
          tieneLlegadaCamaronera ?? this.tieneLlegadaCamaronera,
      tieneKilosRemitidos: tieneKilosRemitidos ?? this.tieneKilosRemitidos,
    );
  }
}
