class CalendarEventModel {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final bool hasNotification;
  final String? googleEventId; // ID dari Google Calendar

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.hasNotification = false,
    this.googleEventId,
  });

  /// From JSON (untuk data dari API lokal)
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      description: json['description'],
      hasNotification: json['has_notification'] ?? false,
      googleEventId: json['google_event_id'],
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
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      hasNotification: hasNotification ?? this.hasNotification,
      googleEventId: googleEventId ?? this.googleEventId,
    );
  }
}