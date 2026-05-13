import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'haycrew.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE laporan_kandang(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jumlah_ayam_awal INTEGER NOT NULL,
            jumlah_ayam_mati INTEGER NOT NULL,
            umur_ayam INTEGER NOT NULL,
            rata_rata_bobot REAL NOT NULL,
            catatan TEXT,
            foto TEXT,
            tanggal_mulai TEXT NOT NULL,
            tanggal_selesai TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> addLaporan(Map<String, dynamic> data) async {
    final client = await db;
    return client.insert("laporan_kandang", data);
  }

  Future<List<Map<String, dynamic>>> getAllLaporan() async {
    final client = await db;
    return client.query("laporan_kandang", orderBy: "created_at DESC");
  }

  Future<Map<String, dynamic>?> getLaporanById(int id) async {
    final client = await db;
    final result = await client.query(
      "laporan_kandang",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateLaporan(int id, Map<String, dynamic> data) async {
    final client = await db;
    return client.update(
      "laporan_kandang",
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteLaporan(int id) async {
    final client = await db;
    return client.delete(
      "laporan_kandang",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Ambil semua laporan yang belum disync ke server
  Future<List<Map<String, dynamic>>> getUnsyncedLaporan() async {
    final client = await db;
    return client.query(
      "laporan_kandang",
      where: "is_synced = ?",
      whereArgs: [0],
    );
  }

  Future<int> markAsSynced(int id) async {
    final client = await db;
    return client.update(
      "laporan_kandang",
      {'is_synced': 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }
}