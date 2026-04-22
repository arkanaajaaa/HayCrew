import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/calender_event_model.dart';
import '../services/google_calender_service.dart';

/// Widget calendar yang bisa tersambung dengan Google Calendar
class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final bool enableGoogleCalendar;
  
  const CalendarWidget({
    Key? key,
    this.onDateSelected,
    this.enableGoogleCalendar = true,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  Map<DateTime, List<CalendarEventModel>> _events = {};
  DateTime _selectedWeekStart = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set ke awal minggu (Senin)
    _selectedWeekStart = _getStartOfWeek(DateTime.now());
    
    if (widget.enableGoogleCalendar) {
      _loadEvents();
    }
  }

  /// Get start of week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  /// Load events dari Google Calendar
  Future<void> _loadEvents() async {
    if (!widget.enableGoogleCalendar) return;

    setState(() => _isLoading = true);

    try {
      if (!_calendarService.isSignedIn) {
        final signedIn = await _calendarService.signIn();
        if (!signedIn) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final events = await _calendarService.getEventsForWeek(_selectedWeekStart);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Get list tanggal untuk seminggu
  List<DateTime> _getWeekDates() {
    return List.generate(
      5, 
      (index) => _selectedWeekStart.add(Duration(days: index))
    );
  }

  /// Navigate ke minggu sebelumnya
  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
    if (widget.enableGoogleCalendar) {
      _loadEvents();
    }
  }

  /// Navigate ke minggu berikutnya
  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
    if (widget.enableGoogleCalendar) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.calendarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan bulan dan navigasi
          _buildHeader(),
          
          const SizedBox(height: 12),
          
          // Calendar grid
          if (_isLoading)
            _buildLoadingState()
          else
            _buildCalendarGrid(weekDates),
        ],
      ),
    );
  }

  /// Build header dengan nama bulan dan tombol navigasi
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'id_ID').format(_selectedWeekStart),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _previousWeek,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _nextWeek,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (widget.enableGoogleCalendar) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadEvents,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build calendar grid dengan tanggal-tanggal
  Widget _buildCalendarGrid(List<DateTime> weekDates) {
    return Row(
      children: weekDates.map((date) {
        return Expanded(
          child: _buildDateCard(date),
        );
      }).toList(),
    );
  }

  /// Build card untuk satu tanggal
  Widget _buildDateCard(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final hasEvents = _events.containsKey(dateKey) && _events[dateKey]!.isNotEmpty;
    final eventsCount = _events[dateKey]?.length ?? 0;
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: () {
        widget.onDateSelected?.call(date);
        _showEventsDialog(date);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isToday 
              ? AppColors.primaryGreen.withOpacity(0.8)
              : AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(8),
          border: isToday 
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEvents 
                      ? '$eventsCount event${eventsCount > 1 ? 's' : ''}'
                      : 'Tidak ada\nevent',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (hasEvents)
              Positioned(
                top: 0,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Check apakah tanggal adalah hari ini
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Show dialog dengan list events untuk tanggal tertentu
  void _showEventsDialog(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final events = _events[dateKey] ?? [];

    if (events.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryGreen),
                title: Text(event.title),
                subtitle: event.description != null 
                    ? Text(event.description!) 
                    : null,
                trailing: Text(
                  DateFormat('HH:mm').format(event.date),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}