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
      version: 8, // naik dari 7 — skema tabel stok disesuaikan sama kolom tabel `stoks` di backend
      onCreate: (db, version) async {
        await _createLaporanKandangTable(db);
        await _createTambahStokTable(db);
        await _createLaporanGudangTable(db);
        await _createStokTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTambahStokTable(db);
          await _createLaporanGudangTable(db);
        }
        if (oldVersion < 3) {
          await _migrateToSingularDate(db);
        }
        if (oldVersion < 4) {
          await _createStokTable(db);
        }
        if (oldVersion < 5) {
          await _migrateLaporanGudangStokDaging(db);
        }
        if (oldVersion >= 2 && oldVersion < 6) {
          // hanya device yang tabel tambah_stok-nya sudah ada dengan schema
          // lama (tanggal_mulai/tanggal_selesai) yang perlu dimigrasi.
          // Device yang baru dibuatkan tabelnya di cabang oldVersion<2 di atas
          // sudah otomatis pakai schema baru (kolom `tanggal` tunggal), makanya
          // di dalam fungsi migrasi tetap dicek dulu apakah kolom lama ada.
          await _migrateTambahStokSingularDate(db);
        }
        if (oldVersion < 7) {
          await _migrateLaporanGudangStokAwalMasuk(db);
        }
        if (oldVersion < 8) {
          await _migrateStokTable(db);
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER
  // ═══════════════════════════════════════════════════════════════════════

  /// Cek apakah sebuah kolom ada di tabel tertentu.
  /// Dipakai supaya fungsi migrasi nggak asal jalan kalau skema tabel
  /// ternyata sudah versi baru (misal karena baru dibuat fresh di
  /// cabang oldVersion<2, bukan hasil upgrade dari skema lama).
  Future<bool> _columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((col) => col['name'] == column);
  }

  Future<void> _migrateLaporanGudangStokDaging(Database db) async {
    if (await _columnExists(db, 'laporan_gudang', 'detail_stok')) return;
    await db.execute(
      "ALTER TABLE laporan_gudang ADD COLUMN detail_stok TEXT",
    );
  }

  /// Tambah kolom `stok_awal` & `stok_masuk` (integer) ke tabel laporan_gudang.
  /// Dua kolom ini wajib diisi oleh backend Laravel (lihat kolom NOT NULL di
  /// tabel MariaDB laporan_gudang), jadi harus ada juga di skema lokal
  /// supaya data yang disimpan offline punya struktur yang sama dengan yang
  /// dikirim ke server.
  Future<void> _migrateLaporanGudangStokAwalMasuk(Database db) async {
    if (!await _columnExists(db, 'laporan_gudang', 'stok_awal')) {
      await db.execute(
        "ALTER TABLE laporan_gudang ADD COLUMN stok_awal INTEGER DEFAULT 0",
      );
    }
    if (!await _columnExists(db, 'laporan_gudang', 'stok_masuk')) {
      await db.execute(
        "ALTER TABLE laporan_gudang ADD COLUMN stok_masuk INTEGER DEFAULT 0",
      );
    }
  }

  /// Tabel `stok` sebelumnya punya kolom nama/jumlah/satuan yang tidak
  /// pernah cocok dengan response API (lihat StokItemModel) — jadi cache
  /// lamanya dibuang lalu dibuat ulang dengan skema yang benar. Aman
  /// karena tabel ini murni cache read-through dari server, bukan data
  /// draft/offline milik user.
  Future<void> _migrateStokTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS stok');
    await _createStokTable(db);
  }

  Future<void> _migrateTambahStokSingularDate(Database db) async {
    if (!await _columnExists(db, 'tambah_stok', 'tanggal_mulai')) return;

    await db.execute('ALTER TABLE tambah_stok RENAME TO tambah_stok_old');
    await _createTambahStokTable(db);
    await db.execute('''
      INSERT INTO tambah_stok
        (id, stok_masuk, tempat_pendistribusian, catatan, foto, tanggal, is_synced, created_at)
      SELECT
        id, stok_masuk, tempat_pendistribusian, catatan, foto, tanggal_mulai, is_synced, created_at
      FROM tambah_stok_old
    ''');
    await db.execute('DROP TABLE tambah_stok_old');
  }

  Future<void> _migrateToSingularDate(Database db) async {
    // --- laporan_kandang ---
    if (await _columnExists(db, 'laporan_kandang', 'tanggal_mulai')) {
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
    }

    // --- laporan_gudang ---
    if (await _columnExists(db, 'laporan_gudang', 'tanggal_mulai')) {
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
        tanggal TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createLaporanGudangTable(Database db) async {
    await db.execute('''
      CREATE TABLE laporan_gudang(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stok_awal INTEGER NOT NULL DEFAULT 0,
        stok_masuk INTEGER NOT NULL DEFAULT 0,
        jumlah_daging_jual REAL NOT NULL,
        detail_stok TEXT,
        tempat_pendistribusian TEXT NOT NULL,
        catatan TEXT,
        foto TEXT,
        tanggal TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createStokTable(Database db) async {
    // id disimpan sebagai TEXT karena berasal dari server (bukan digenerate lokal),
    // jadi bukan INTEGER PRIMARY KEY AUTOINCREMENT seperti tabel-tabel lain di atas.
    // Kolom-kolomnya mengikuti tabel `stoks` di backend (lihat Stok model).
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stok(
        id TEXT PRIMARY KEY,
        jenis TEXT NOT NULL,
        berat_per_item REAL NOT NULL DEFAULT 0,
        jumlah_stok INTEGER NOT NULL DEFAULT 0,
        estimasi_total_berat REAL NOT NULL DEFAULT 0,
        tanggal_update TEXT,
        status TEXT NOT NULL
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

  // ═══════════════════════════════════════════════════════════════════════
  // STOK
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> replaceAllStok(List<Map<String, dynamic>> stokList) async {
    final client = await db;
    final batch = client.batch();
    batch.delete('stok'); // bersihin data lama biar nggak ada sisa item yang udah dihapus di server
    for (final item in stokList) {
      batch.insert(
        'stok',
        {
          'id': item['id']?.toString() ?? '',
          'jenis': item['jenis']?.toString() ?? '',
          'berat_per_item': item['berat_per_item'] is num
              ? (item['berat_per_item'] as num).toDouble()
              : double.tryParse(item['berat_per_item']?.toString() ?? '') ?? 0,
          'jumlah_stok': item['jumlah_stok'] is int
              ? item['jumlah_stok']
              : int.tryParse(item['jumlah_stok']?.toString() ?? '') ?? 0,
          'estimasi_total_berat': item['estimasi_total_berat'] is num
              ? (item['estimasi_total_berat'] as num).toDouble()
              : double.tryParse(item['estimasi_total_berat']?.toString() ?? '') ?? 0,
          'tanggal_update': item['tanggal_update']?.toString(),
          'status': item['status'] ?? 'aman',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAllStok() async {
    final client = await db;
    return client.query('stok', orderBy: 'tanggal_update DESC');
  }
}