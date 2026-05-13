class PermintaanModel {
  final int id;
  final int userId;
  final String namaPermintaan;
  final String tipe;
  final int? jumlah;
  final String? harga;
  final String status;
  final String? alasanTolak;
  final DateTime tanggal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? role;
  final UserSimple? user;

  PermintaanModel({
    required this.id,
    required this.userId,
    required this.namaPermintaan,
    required this.tipe,
    this.jumlah,
    this.harga,
    required this.status,
    this.alasanTolak,
    required this.tanggal,
    required this.createdAt,
    required this.updatedAt,
    this.role,
    this.user,
  });

  factory PermintaanModel.fromJson(Map<String, dynamic> json) => PermintaanModel(
    id             : json['id'],
    userId         : json['user_id'],
    namaPermintaan : json['nama_permintaan'] ?? '',
    tipe           : json['tipe'] ?? '',
    jumlah         : json['jumlah'],
    harga          : json['harga']?.toString(),
    status         : json['status'] ?? 'pending',
    alasanTolak    : json['alasan_tolak'],
    tanggal        : DateTime.parse(json['tanggal']),
    createdAt      : DateTime.parse(json['created_at']),
    updatedAt      : DateTime.parse(json['updated_at']),
    role           : json['role'],
    user           : json['user'] != null ? UserSimple.fromJson(json['user']) : null,
  );
}

class UserSimple {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? foto;

  UserSimple({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.foto,
  });

  factory UserSimple.fromJson(Map<String, dynamic> json) => UserSimple(
    id    : json['id'],
    name  : json['name'] ?? '',
    email : json['email'] ?? '',
    role  : json['role'] ?? '',
    foto  : json['foto'],
  );
}