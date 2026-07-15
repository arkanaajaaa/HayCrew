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
      version: 3,
      onCreate: (db, version) async {
        await _createLaporanKandangTable(db);
        await _createTambahStokTable(db);
        await _createLaporanGudangTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // User lama yang sudah install versi 1 akan lewat sini,
        // supaya tabel baru tetap kebuat tanpa harus uninstall app.
        if (oldVersion < 2) {
          await _createTambahStokTable(db);
          await _createLaporanGudangTable(db);
        }
        
        if (oldVersion < 3) {
          await _migrateToSingularDate(db);
        }
      },
    );
  }


  Future<void> _migrateToSingularDate(Database db) async {
    // --- laporan_kandang ---
    await db.execute('ALTER TABLE laporan_kandang RENAME TO laporan_kandang_old');
    await _createLaporanKandangTable(db);
    await db.execute('''
      INSERT INTO laporan_kandang
        (id, siklus_id, jumlah_ayam_awal, jumlah_ayam_mati, rata_rata_bobot,
         catatan, foto, tanggal, is_synced, created_at)
      SELECT
        id, NULL, jumlah_ayam_awal, jumlah_ayam_mati, rata_rata_bobot,
        catatan, foto, tanggal_mulai, is_synced, created_at
      FROM laporan_kandang_old
    ''');
    await db.execute('DROP TABLE laporan_kandang_old');

    // --- laporan_gudang ---
    await db.execute('ALTER TABLE laporan_gudang RENAME TO laporan_gudang_old');
    await _createLaporanGudangTable(db);
    await db.execute('''
      INSERT INTO laporan_gudang
        (id, jumlah_daging_jual, tempat_pendistribusian, catatan, foto, tanggal, is_synced, created_at)
      SELECT
        id, jumlah_daging_jual, tempat_pendistribusian, catatan, foto, tanggal_mulai, is_synced, created_at
      FROM laporan_gudang_old
    ''');
    await db.execute('DROP TABLE laporan_gudang_old');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CREATE TABLE
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _createLaporanKandangTable(Database db) async {
    await db.execute('''
      CREATE TABLE laporan_kandang(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        siklus_id INTEGER,
        jumlah_ayam_awal INTEGER,
        jumlah_ayam_mati INTEGER NOT NULL,
        rata_rata_bobot REAL NOT NULL,
        catatan TEXT,
        foto TEXT,
        tanggal TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTambahStokTable(Database db) async {
    await db.execute('''
      CREATE TABLE tambah_stok(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stok_masuk INTEGER NOT NULL,
        tempat_pendistribusian TEXT NOT NULL,
        catatan TEXT,
        foto TEXT,
        tanggal_mulai TEXT NOT NULL,
        tanggal_selesai TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createLaporanGudangTable(Database db) async {
    await db.execute('''
      CREATE TABLE laporan_gudang(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jumlah_daging_jual INTEGER NOT NULL,
        tempat_pendistribusian TEXT NOT NULL,
        catatan TEXT,
        foto TEXT,
        tanggal TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAPORAN KANDANG
  // ═══════════════════════════════════════════════════════════════════════

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
    return client.delete("laporan_kandang", where: "id = ?", whereArgs: [id]);
  }

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

  // ═══════════════════════════════════════════════════════════════════════
  // TAMBAH STOK
  // ═══════════════════════════════════════════════════════════════════════

  Future<int> addTambahStok(Map<String, dynamic> data) async {
    final client = await db;
    return client.insert("tambah_stok", data);
  }

  Future<List<Map<String, dynamic>>> getAllTambahStok() async {
    final client = await db;
    return client.query("tambah_stok", orderBy: "created_at DESC");
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTambahStok() async {
    final client = await db;
    return client.query(
      "tambah_stok",
      where: "is_synced = ?",
      whereArgs: [0],
    );
  }

  Future<int> markTambahStokSynced(int id) async {
    final client = await db;
    return client.update(
      "tambah_stok",
      {'is_synced': 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteTambahStok(int id) async {
    final client = await db;
    return client.delete("tambah_stok", where: "id = ?", whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAPORAN GUDANG
  // ═══════════════════════════════════════════════════════════════════════

  Future<int> addLaporanGudang(Map<String, dynamic> data) async {
    final client = await db;
    return client.insert("laporan_gudang", data);
  }

  Future<List<Map<String, dynamic>>> getAllLaporanGudang() async {
    final client = await db;
    return client.query("laporan_gudang", orderBy: "created_at DESC");
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLaporanGudang() async {
    final client = await db;
    return client.query(
      "laporan_gudang",
      where: "is_synced = ?",
      whereArgs: [0],
    );
  }

  Future<int> markLaporanGudangSynced(int id) async {
    final client = await db;
    return client.update(
      "laporan_gudang",
      {'is_synced': 1},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteLaporanGudang(int id) async {
    final client = await db;
    return client.delete("laporan_gudang", where: "id = ?", whereArgs: [id]);
  }
}