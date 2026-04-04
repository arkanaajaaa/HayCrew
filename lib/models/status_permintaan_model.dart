class StatusPermintaanModel {
  final String id;
  final int day;
  final String month;
  final String title;
  final String? subtitle;
  final StatusType status;
  final DateTime createdAt;
  final String? description;

  StatusPermintaanModel({
    required this.id,
    required this.day,
    required this.month,
    required this.title,
    this.subtitle,
    required this.status,
    required this.createdAt,
    this.description,
  });

  /// From JSON (untuk data dari API)
  factory StatusPermintaanModel.fromJson(Map<String, dynamic> json) {
    return StatusPermintaanModel(
      id: json['id']?.toString() ?? '',
      day: json['day'] ?? 0,
      month: json['month'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      status: _parseStatus(json['status']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      description: json['description'],
    );
  }

  /// To JSON (untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'month': month,
      'title': title,
      'subtitle': subtitle,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  /// Parse status dari string
  static StatusType _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
      case 'diterima':
        return StatusType.accepted;
      case 'pending':
        return StatusType.pending;
      case 'rejected':
      case 'ditolak':
        return StatusType.rejected;
      default:
        return StatusType.pending;
    }
  }

  /// Copy with method
  StatusPermintaanModel copyWith({
    String? id,
    int? day,
    String? month,
    String? title,
    String? subtitle,
    StatusType? status,
    DateTime? createdAt,
    String? description,
  }) {
    return StatusPermintaanModel(
      id: id ?? this.id,
      day: day ?? this.day,
      month: month ?? this.month,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}

/// Enum untuk status
enum StatusType { 
  accepted,  // Diterima (hijau)
  pending,   // Pending (kuning/orange)
  rejected   // Ditolak (merah)
}