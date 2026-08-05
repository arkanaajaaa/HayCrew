class CalendarEventModel {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final bool hasNotification;
  final String? googleEventId; // ID dari Google Calendar
  final String? role; // kandang/gudang/reseller (dari backend Laravel)
  final int? jumlah;
  final String? status; // pending/acc/reject (dari backend Laravel)

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.hasNotification = false,
    this.googleEventId,
    this.role,
    this.jumlah,
    this.status,
  });

  /// From JSON, hasil respons endpoint /api/event (tabel `events` di database).
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id']?.toString() ?? '',
      title: json['nama_kegiatan'] ?? json['title'] ?? '',
      date: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : (json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now()),
      description: json['deskripsi'] ?? json['description'],
      hasNotification: json['has_notification'] ?? false,
      googleEventId: json['google_event_id'],
      role: json['role'],
      jumlah: json['jumlah'],
      status: json['status'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'has_notification': hasNotification,
      'google_event_id': googleEventId,
    };
  }

  /// From Google Calendar Event
  factory CalendarEventModel.fromGoogleEvent(dynamic event) {
    return CalendarEventModel(
      id: event.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.summary ?? 'No Title',
      date: event.start?.dateTime ?? event.start?.date ?? DateTime.now(),
      description: event.description,
      hasNotification: event.reminders?.useDefault ?? false,
      googleEventId: event.id,
    );
  }
  /// Copy with method
  CalendarEventModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? description,
    bool? hasNotification,
    String? googleEventId,
    String? role,
    int? jumlah,
    String? status,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      hasNotification: hasNotification ?? this.hasNotification,
      googleEventId: googleEventId ?? this.googleEventId,
      role: role ?? this.role,
      jumlah: jumlah ?? this.jumlah,
      status: status ?? this.status,
    );
  }
}