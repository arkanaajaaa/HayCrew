import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/models/calender_event_model.dart';

/// Ambil event kalender dari backend Laravel per bulan,
/// menggantikan sumber Google Calendar.
class CalendarService {
  static Future<Map<DateTime, List<CalendarEventModel>>> fetchEvents({
    required String token,
    required DateTime month,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${ApiConstant.baseUrl}/api/events?month=${month.month}&year=${month.year}',
            ),
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