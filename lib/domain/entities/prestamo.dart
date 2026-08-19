import 'cuota.dart';

enum FrecuenciaPago { semanal, quincenal, mensual }

extension FrecuenciaPagoLabel on FrecuenciaPago {
  String get label {
    switch (this) {
      case FrecuenciaPago.semanal:
        return 'Semanal';
      case FrecuenciaPago.quincenal:
        return 'Quincenal';
      case FrecuenciaPago.mensual:
        return 'Mensual';
    }
  }
}

class Prestamo {
  final int? id;
  final int? clientId;
  final double valor;
  final int numCuotas;
  final double interesPct;
  final double cuotaDeseada;
  final FrecuenciaPago frecuencia;
  final DateTime fechaInicio;
  final List<Cuota> cuotas;

  Prestamo({
    this.id,
    this.clientId,
    required this.valor,
    required this.numCuotas,
    required this.interesPct,
    required this.cuotaDeseada,
    required this.frecuencia,
    required this.fechaInicio,
    required this.cuotas,
  });

  factory Prestamo.fromMap(Map<String, dynamic> map, {List<Cuota> cuotas = const []}) {
    return Prestamo(
      id: map['id'] as int?,
      clientId: map['client_id'] as int?,
      valor: (map['valor'] as num).toDouble(),
      numCuotas: map['num_cuotas'] as int,
      interesPct: (map['interes_pct'] as num).toDouble(),
      cuotaDeseada: (map['cuota_deseada'] as num).toDouble(),
      frecuencia: FrecuenciaPago.values.firstWhere(
        (e) => e.name == map['frecuencia'],
        orElse: () => FrecuenciaPago.mensual,
      ),
      fechaInicio: DateTime.parse(map['fecha_inicio'] as String),
      cuotas: cuotas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'valor': valor,
      'num_cuotas': numCuotas,
      'interes_pct': interesPct,
      'cuota_deseada': cuotaDeseada,
      'frecuencia': frecuencia.name,
      'fecha_inicio': fechaInicio.toIso8601String(),
    };
  }

  Prestamo copyWith({
    int? id,
    int? clientId,
    double? valor,
    int? numCuotas,
    double? interesPct,
    double? cuotaDeseada,
    FrecuenciaPago? frecuencia,
    DateTime? fechaInicio,
    List<Cuota>? cuotas,
  }) {
    return Prestamo(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      valor: valor ?? this.valor,
      numCuotas: numCuotas ?? this.numCuotas,
      interesPct: interesPct ?? this.interesPct,
      cuotaDeseada: cuotaDeseada ?? this.cuotaDeseada,
      frecuencia: frecuencia ?? this.frecuencia,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      cuotas: cuotas ?? this.cuotas,
    );
  }
}
