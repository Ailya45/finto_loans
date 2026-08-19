import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/client.dart';
import '../../domain/entities/cuota.dart';
import '../../domain/entities/prestamo.dart';

class LocalDbDatasource {
  static final LocalDbDatasource instance = LocalDbDatasource._init();
  static Database? _database;

  LocalDbDatasource._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finto_loans_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE clients (
  id $idType,
  name $textType,
  cedula $textType,
  phone $textNullable,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE loans (
  id $idType,
  client_id $intType,
  valor $realType,
  num_cuotas $intType,
  interes_pct $realType,
  cuota_deseada $realType,
  frecuencia $textType,
  fecha_inicio $textType,
  FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE installments (
  id $idType,
  prestamo_id $intType,
  numero $intType,
  fecha_limite $textType,
  capital_cuota $realType,
  interes_cuota $realType,
  total_cuota $realType,
  saldo_capital_restante $realType,
  pagado INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (prestamo_id) REFERENCES loans (id) ON DELETE CASCADE
)
''');

    await db.execute('''
    CREATE TABLE abonos (
      id $idType,
      cuota_id $intType,
      monto $realType,
      fecha $textType,
      FOREIGN KEY (cuota_id) REFERENCES installments (id) ON DELETE CASCADE
    )
 ''');
  }

  // --- Clients CRUD ---
  Future<Client> createClient(Client client) async {
    final db = await instance.database;
    final id = await db.insert('clients', client.toMap());
    return client.copyWith(id: id);
  }

  Future<List<Client>> readAllClients() async {
    final db = await instance.database;
    final result = await db.query('clients', orderBy: 'created_at DESC');
    return result.map((json) => Client.fromMap(json)).toList();
  }

  Future<int> deleteClient(int id) async {
    final db = await instance.database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // --- Loans & Installments CRUD ---
  Future<Prestamo> createPrestamo(Prestamo prestamo) async {
    final db = await instance.database;

    int prestamoId = 0;
    List<Cuota> savedCuotas = [];

    await db.transaction((txn) async {
      prestamoId = await txn.insert('loans', prestamo.toMap());

      for (var cuota in prestamo.cuotas) {
        final cuotaToInsert = cuota.copyWith(prestamoId: prestamoId);
        final cuotaId = await txn.insert('installments', cuotaToInsert.toMap());
        savedCuotas.add(cuotaToInsert.copyWith(id: cuotaId));
      }
    });

    return prestamo.copyWith(id: prestamoId, cuotas: savedCuotas);
  }

  Future<List<Prestamo>> readPrestamosByClient(int clientId) async {
    final db = await instance.database;
    final loansMaps = await db.query(
      'loans',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'fecha_inicio DESC',
    );

    List<Prestamo> prestamos = [];
    for (var map in loansMaps) {
      final prestamoId = map['id'] as int;
      final cuotasMaps = await db.query(
        'installments',
        where: 'prestamo_id = ?',
        whereArgs: [prestamoId],
        orderBy: 'numero ASC',
      );

      // Calcular saldoRestanteCuota para cada cuota sumando sus abonos
      final List<Cuota> cuotas = [];
      for (final cMap in cuotasMaps) {
        final cuotaId = cMap['id'] as int;
        final totalCuota = (cMap['total_cuota'] as num).toDouble();

        final abonosResult = await db.rawQuery(
          'SELECT COALESCE(SUM(monto), 0) as total FROM abonos WHERE cuota_id = ?',
          [cuotaId],
        );
        final totalAbonado = (abonosResult.first['total'] as num).toDouble();
        final saldoRestante = (totalCuota - totalAbonado).clamp(0.0, totalCuota);

        cuotas.add(Cuota.fromMap({
          ...cMap,
          'saldo_restante_cuota': saldoRestante,
        }));
      }

      prestamos.add(Prestamo.fromMap(map, cuotas: cuotas));
    }
    return prestamos;
  }

  Future<void> updateCuotaPagada(int cuotaId, bool pagado) async {
    final db = await instance.database;
    await db.update(
      'installments',
      {'pagado': pagado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [cuotaId],
    );
  }

  // Para el dashboard global
  Future<Map<String, double>> readDashboardStats() async {
    final db = await instance.database;

    final resultPagados = await db.rawQuery(
      'SELECT COUNT(id) as count FROM installments WHERE pagado = 1',
    );
    final resultPendientes = await db.rawQuery(
      'SELECT COUNT(id) as count FROM installments WHERE pagado = 0',
    );

    final pagados = (resultPagados.first['count'] as int).toDouble();
    final pendientes = (resultPendientes.first['count'] as int).toDouble();

    return {'pagados': pagados, 'pendientes': pendientes};
  }

  Future<void> registrarAbono(
    int cuotaId,
    double montoAbonado,
    double montoTotalCuota,
  ) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // Insertar el abono
      await txn.insert('abonos', {
        'cuota_id': cuotaId,
        'monto': montoAbonado,
        'fecha': DateTime.now().toIso8601String(),
      });

      final List<Map<String, dynamic>> result = await txn.query(
        'abonos',
        where: 'cuota_id = ?',
        whereArgs: [cuotaId],
      );
      double totalAbonado = 0.0;
      for (var row in result) {
        totalAbonado += row['monto'] as double;
      }

      int nuevoEstado = (totalAbonado >= montoTotalCuota) ? 1 : 0;
      await txn.update(
        'installments',
        {'pagado': nuevoEstado},
        where: 'id = ?',
        whereArgs: [cuotaId],
      );
    });
  }
}
