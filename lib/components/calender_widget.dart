import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/calender_event_model.dart';
import '../services/google_calender_service.dart';

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
    _selectedWeekStart = _getStartOfWeek(DateTime.now());
    
    if (widget.enableGoogleCalendar) {
      _loadEvents();
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

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

  // 1. Ditingkatkan menjadi 14 hari (2 minggu) agar bisa di-scroll
  List<DateTime> _getWeekDates() {
    return List.generate(
      10, 
      (index) => _selectedWeekStart.add(Duration(days: index))
    );
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
    if (widget.enableGoogleCalendar) {
      _loadEvents();
    }
  }

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
      padding: const EdgeInsets.symmetric(vertical: 16), // Padding horizontal dihapus agar scroll mepet tepi
      decoration: BoxDecoration(
        color: AppColors.calendarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeader(),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            _buildLoadingState()
          else
            _buildCalendarGrid(weekDates),
        ],
      ),
    );
  }

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

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 2. Menggunakan SingleChildScrollView agar bisa digeser (swipe)
  Widget _buildCalendarGrid(List<DateTime> weekDates) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12), // Jarak awal scroll
      child: Row(
        children: weekDates.map((date) {
          return SizedBox(
            width: 80, // Ukuran lebar kartu yang konsisten
            child: _buildDateCard(date),
          );
        }).toList(),
      ),
    );
  }

  // 3. Update Card (Menghapus Expanded & Memastikan Center)
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    hasEvents 
                        ? '$eventsCount event'
                        : 'Tidak ada\nevent',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            if (hasEvents)
              Positioned(
                top: -2,
                right: 2,
                child: Container(
                  width: 7,
                  height: 7,
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  void _showEventsDialog(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final events = _events[dateKey] ?? [];
    if (events.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date)),
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
                subtitle: event.description != null ? Text(event.description!) : null,
                trailing: Text(DateFormat('HH:mm').format(event.date), style: const TextStyle(fontSize: 12)),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
        ],
      ),
    );
  }
}