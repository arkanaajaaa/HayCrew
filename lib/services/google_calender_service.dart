import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:http/http.dart' as http;
import '../models/calender_event_model.dart';

class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _currentUser;
  cal.CalendarApi? _calendarApi;

  Future<void> _setupApi(GoogleSignInAccount account) async {
    _currentUser = account;
    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    _calendarApi = cal.CalendarApi(authenticateClient);
  }

  /// Coba nyambung otomatis pakai sesi Google yang sudah pernah dipilih
  /// sebelumnya, tanpa munculin picker akun. Dipanggil duluan sebelum
  /// signIn() supaya user nggak perlu pilih akun/login ulang tiap kali
  /// halaman di-refresh atau dibuka lagi — google_sign_in yang nyimpen
  /// sesinya, bukan kita.
  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;

      await _setupApi(account);
      return true;
    } catch (e) {
      print('Error silent sign-in: $e');
      return false;
    }
  }

  /// Sign in dengan Google (munculin picker akun)
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      await _setupApi(account);
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
  }

  bool get isSignedIn => _currentUser != null;

  GoogleSignInAccount? get currentUser => _currentUser;

  /// True kalau email akun Google yang lagi nyambung sama persis dengan
  /// email yang terdaftar di HayCrew (case-insensitive) — dipakai buat
  /// nunjukin kalender ini otomatis "kedetect" punya akun yang sama,
  /// tanpa perlu verifikasi manual lagi.
  bool emailMatches(String? registeredEmail) {
    if (_currentUser == null ||
        registeredEmail == null ||
        registeredEmail.isEmpty) {
      return false;
    }
    return _currentUser!.email.toLowerCase() == registeredEmail.toLowerCase();
  }

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