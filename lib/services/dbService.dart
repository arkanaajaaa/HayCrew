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
      version: 10, // naik dari 9 — buang kolom `items` legacy (NOT NULL) yang bikin semua insert gagal
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
        if (oldVersion >= 2 && oldVersion < 6) {
          // hanya device yang tabel tambah_stok-nya sudah ada dengan schema
          // lama (tanggal_mulai/tanggal_selesai) yang perlu dimigrasi.
          // Device yang baru dibuatkan tabelnya di cabang oldVersion<2 di atas
          // sudah otomatis pakai schema baru (kolom `tanggal` tunggal), makanya
          // di dalam fungsi migrasi tetap dicek dulu apakah kolom lama ada.
          await _migrateTambahStokSingularDate(db);
        }

        // Kolom-kolom laporan_gudang di bawah ini dulu digantung di belakang
        // "if (oldVersion < X)" tertentu, tapi ada device yang user_version-nya
        // udah kelewat angka X itu sebelum migrasinya sempet nambah kolom
        // (jadi kolom hilang selamanya). Supaya self-healing dan nggak
        // ketemu kasus serupa lagi ke depannya, migrasi-migrasi ini dijalanin
        // tiap kali onUpgrade ke-trigger, terlepas dari oldVersion-nya berapa.
        // Aman karena masing-masing sudah cek _columnExists sebelum ALTER.
        await _migrateLaporanGudangStokDaging(db);
        await _migrateLaporanGudangStokAwalMasuk(db);
        await _migrateLaporanGudangJumlahDagingJual(db);
        await _migrateLaporanGudangDropItemsColumn(db);
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

  /// Tambah kolom `jumlah_daging_jual` (REAL) ke tabel laporan_gudang.
  /// Kolom ini ada di _createLaporanGudangTable untuk device baru, tapi
  /// device lama yang tabelnya sudah lebih dulu ada (dibuat sebelum kolom
  /// ini ditambahkan ke fungsi create) nggak pernah dapet kolom ini lewat
  /// migrasi apa pun, jadi INSERT ke kolom itu gagal dengan error
  /// "table laporan_gudang has no column named jumlah_daging_jual".
  Future<void> _migrateLaporanGudangJumlahDagingJual(Database db) async {
    if (!await _columnExists(db, 'laporan_gudang', 'jumlah_daging_jual')) {
      await db.execute(
        "ALTER TABLE laporan_gudang ADD COLUMN jumlah_daging_jual REAL NOT NULL DEFAULT 0",
      );
    }
  }

  /// Buang kolom `items` legacy di laporan_gudang kalau masih ada.
  /// Kolom ini peninggalan skema lama, NOT NULL tanpa default, dan sudah
  /// nggak pernah diisi sama kode manapun (diganti `detail_stok`) — akibatnya
  /// SEMUA insert ke laporan_gudang gagal dengan
  /// "NOT NULL constraint failed: laporan_gudang.items".
  /// SQLite nggak bisa langsung drop/ubah NOT NULL lewat ALTER TABLE biasa,
  /// jadi tabelnya di-rebuild: rename ke _old, buat ulang pakai skema
  /// sekarang, copy data kolom yang relevan, baru drop tabel lama.
  Future<void> _migrateLaporanGudangDropItemsColumn(Database db) async {
    if (!await _columnExists(db, 'laporan_gudang', 'items')) return;

    await db.execute('ALTER TABLE laporan_gudang RENAME TO laporan_gudang_old');
    await _createLaporanGudangTable(db);
    await db.execute('''
      INSERT INTO laporan_gudang
        (id, stok_awal, stok_masuk, jumlah_daging_jual, detail_stok,
         tempat_pendistribusian, catatan, foto, tanggal, is_synced, created_at)
      SELECT
        id, stok_awal, stok_masuk, jumlah_daging_jual, detail_stok,
        tempat_pendistribusian, catatan, foto, tanggal, is_synced, created_at
      FROM laporan_gudang_old
    ''');
    await db.execute('DROP TABLE laporan_gudang_old');
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stok(
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        jumlah INTEGER NOT NULL,
        satuan TEXT,
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
          'nama': item['nama'] ?? '',
          'jumlah': item['jumlah'] is int
              ? item['jumlah']
              : int.tryParse(item['jumlah']?.toString() ?? '') ?? 0,
          'satuan': item['satuan'] ?? '',
          'status': item['status'] ?? 'aman',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAllStok() async {
    final client = await db;
    return client.query('stok', orderBy: 'nama ASC');
  }
}