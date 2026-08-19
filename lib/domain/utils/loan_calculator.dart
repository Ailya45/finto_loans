import '../entities/cuota.dart';
import '../entities/prestamo.dart';

DateTime calcularFechaCuota(
    DateTime fechaInicio, FrecuenciaPago frecuencia, int cuotaNum) {
  switch (frecuencia) {
    case FrecuenciaPago.semanal:
      return fechaInicio.add(Duration(days: 7 * cuotaNum));
    case FrecuenciaPago.quincenal:
      return fechaInicio.add(Duration(days: 15 * cuotaNum));
    case FrecuenciaPago.mensual:
      int year = fechaInicio.year;
      int month = fechaInicio.month + cuotaNum;
      while (month > 12) {
        month -= 12;
        year++;
      }
      int day = fechaInicio.day;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (day > daysInMonth) day = daysInMonth;
      return DateTime(year, month, day);
  }
}

List<Cuota> generarCuotas({
  required double valor,
  required int numCuotas,
  required double interesPct,
  required FrecuenciaPago frecuencia,
  required DateTime fechaInicio,
}) {
  final capitalPorCuota = valor / numCuotas;
  final interesPorCuota = valor * (interesPct / 100) / numCuotas;
  final totalPorCuota = capitalPorCuota + interesPorCuota;

  return List.generate(numCuotas, (i) {
    final cuotaNum = i + 1;
    final saldoRestante = valor - capitalPorCuota * cuotaNum;
    return Cuota(
      numero: cuotaNum,
      fechaLimite: calcularFechaCuota(fechaInicio, frecuencia, cuotaNum),
      capitalCuota: capitalPorCuota,
      interesCuota: interesPorCuota,
      totalCuota: totalPorCuota,
      saldoCapitalRestante: saldoRestante < 0 ? 0 : saldoRestante,
    );
  });
}

EstadoCuota calcularEstadoCuota(Cuota cuota) {
  if (cuota.pagado) return EstadoCuota.pagado;
  final now = DateTime.now();
  final hoy = DateTime(now.year, now.month, now.day);
  final limite = DateTime(
    cuota.fechaLimite.year,
    cuota.fechaLimite.month,
    cuota.fechaLimite.day,
  );
  if (limite.isBefore(hoy)) return EstadoCuota.vencido;
  return EstadoCuota.pendiente;
}
