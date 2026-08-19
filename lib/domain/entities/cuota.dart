enum EstadoCuota { pagado, pendiente, vencido }

class Cuota {
  final int? id;
  final int? prestamoId;
  final int numero;
  final DateTime fechaLimite;
  final double capitalCuota;
  final double interesCuota;
  final double totalCuota;
  final double saldoRestanteCuota; // saldo tras descontar abonos parciales
  final double saldoCapitalRestante;
  final bool pagado;

  Cuota({
    this.id,
    this.prestamoId,
    required this.numero,
    required this.fechaLimite,
    required this.capitalCuota,
    required this.interesCuota,
    required this.totalCuota,
    double? saldoRestanteCuota,
    required this.saldoCapitalRestante,
    this.pagado = false,
  }) : saldoRestanteCuota = saldoRestanteCuota ?? totalCuota;

  factory Cuota.fromMap(Map<String, dynamic> map) {
    final total = (map['total_cuota'] as num).toDouble();
    return Cuota(
      id: map['id'] as int?,
      prestamoId: map['prestamo_id'] as int?,
      numero: map['numero'] as int,
      fechaLimite: DateTime.parse(map['fecha_limite'] as String),
      capitalCuota: (map['capital_cuota'] as num).toDouble(),
      interesCuota: (map['interes_cuota'] as num).toDouble(),
      totalCuota: total,
      saldoRestanteCuota: map['saldo_restante_cuota'] != null
          ? (map['saldo_restante_cuota'] as num).toDouble()
          : total,
      saldoCapitalRestante: (map['saldo_capital_restante'] as num).toDouble(),
      pagado: (map['pagado'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prestamo_id': prestamoId,
      'numero': numero,
      'fecha_limite': fechaLimite.toIso8601String(),
      'capital_cuota': capitalCuota,
      'interes_cuota': interesCuota,
      'total_cuota': totalCuota,
      'saldo_capital_restante': saldoCapitalRestante,
      'pagado': pagado ? 1 : 0,
    };
  }

  Cuota copyWith({
    int? id,
    int? prestamoId,
    int? numero,
    DateTime? fechaLimite,
    double? capitalCuota,
    double? interesCuota,
    double? totalCuota,
    double? saldoRestanteCuota,
    double? saldoCapitalRestante,
    bool? pagado,
  }) {
    return Cuota(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      numero: numero ?? this.numero,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      capitalCuota: capitalCuota ?? this.capitalCuota,
      interesCuota: interesCuota ?? this.interesCuota,
      totalCuota: totalCuota ?? this.totalCuota,
      saldoRestanteCuota: saldoRestanteCuota ?? this.saldoRestanteCuota,
      saldoCapitalRestante: saldoCapitalRestante ?? this.saldoCapitalRestante,
      pagado: pagado ?? this.pagado,
    );
  }
}
