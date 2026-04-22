import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/calender_event_model.dart';

/// Service untuk integrasi dengan Google Calendar
class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _currentUser;
  cal.CalendarApi? _calendarApi;

  /// Sign in dengan Google
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      _currentUser = account;
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      _calendarApi = cal.CalendarApi(authenticateClient);
      
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  /// Sign out dari Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
  }

  /// Check apakah sudah signed in
  bool get isSignedIn => _currentUser != null;

  /// Get current user
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Get events untuk tanggal tertentu
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date) async {
    if (_calendarApi == null) return [];

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startOfDay.toUtc(),
        timeMax: endOfDay.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items?.map((e) => CalendarEventModel.fromGoogleEvent(e)).toList() ?? [];
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  /// Get events untuk range tanggal (misal seminggu)
  Future<Map<DateTime, List<CalendarEventModel>>> getEventsForWeek(DateTime startDate) async {
    if (_calendarApi == null) return {};

    try {
      final endDate = startDate.add(const Duration(days: 7));

      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startDate.toUtc(),
        timeMax: endDate.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      final Map<DateTime, List<CalendarEventModel>> eventsByDate = {};

      for (var event in events.items ?? []) {
        final eventModel = CalendarEventModel.fromGoogleEvent(event);
        final dateKey = DateTime(
          eventModel.date.year,
          eventModel.date.month,
          eventModel.date.day,
        );

        if (eventsByDate.containsKey(dateKey)) {
          eventsByDate[dateKey]!.add(eventModel);
        } else {
          eventsByDate[dateKey] = [eventModel];
        }
      }

      return eventsByDate;
    } catch (e) {
      print('Error getting week events: $e');
      return {};
    }
  }

  /// Create new event di Google Calendar
  Future<bool> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) async {
    if (_calendarApi == null) return false;

    try {
      final event = cal.Event()
        ..summary = title
        ..description = description
        ..start = cal.EventDateTime(dateTime: startTime.toUtc())
        ..end = cal.EventDateTime(dateTime: endTime.toUtc());

      await _calendarApi!.events.insert(event, 'primary');
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  /// Update existing event
  Future<bool> updateEvent({
    required String eventId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
  }) async {
    if (_calendarApi == null) return false;

    try {
      final event = await _calendarApi!.events.get('primary', eventId);
      
      if (title != null) event.summary = title;
      if (description != null) event.description = description;
      if (startTime != null) {
        event.start = cal.EventDateTime(dateTime: startTime.toUtc());
      }
      if (endTime != null) {
        event.end = cal.EventDateTime(dateTime: endTime.toUtc());
      }

      await _calendarApi!.events.update(event, 'primary', eventId);
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  /// Delete event
  Future<bool> deleteEvent(String eventId) async {
    if (_calendarApi == null) return false;

    try {
      await _calendarApi!.events.delete('primary', eventId);
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }
}

/// HTTP Client untuk Google API
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}