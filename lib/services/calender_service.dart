import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/models/calender_event_model.dart';

/// Ambil event kalender dari tabel `events` di database (lewat backend
/// Laravel), menggantikan sumber Google Calendar. Backend sudah
/// menyaring datanya sesuai role user yang login (lihat EventController::index),
/// jadi di sini cukup ambil semua lalu dikelompokkan per tanggal.
class CalendarService {
  static Future<Map<DateTime, List<CalendarEventModel>>> fetchEvents({
    required String token,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('${ApiConstant.baseUrl}/api/event'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return {};

      final decoded = jsonDecode(res.body);
      final list = decoded is Map && decoded['data'] is List
          ? decoded['data'] as List
          : <dynamic>[];

      final events = list
          .map((item) => CalendarEventModel.fromJson(item))
          .toList();

      final Map<DateTime, List<CalendarEventModel>> grouped = {};
      for (final event in events) {
        final key = DateTime(event.date.year, event.date.month, event.date.day);
        grouped.putIfAbsent(key, () => []).add(event);
      }
      return grouped;
    } catch (_) {
      return {};
    }
  }
}