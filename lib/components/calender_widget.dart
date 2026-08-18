import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/calender_event_model.dart';
import '../services/calender_service.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final String token;

  const CalendarWidget({
    super.key,
    this.onDateSelected,
    required this.token,
  });

  @override
  State<CalendarWidget> createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  Map<DateTime, List<CalendarEventModel>> _events = {};
  DateTime _selectedWeekStart = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getStartOfWeek(DateTime.now());
    _loadEvents();
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }


  Future<void> refresh() => _loadEvents(showLoading: false);

  Future<void> _loadEvents({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);

    final events = await CalendarService.fetchEvents(token: widget.token);

    if (!mounted) return;

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  List<DateTime> _getWeekDates() {
    return List.generate(
      10,
      (index) => _selectedWeekStart.add(Duration(days: index)),
    );
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
    _loadEvents();
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      // Disamain sama gaya card lain di halaman (StatusCardWidget,
      // CStokItemCard) — tint krem tipis + border + shadow halus — biar
      // nyatu, nggak nongol sebagai blok warna khaki solid sendirian.
      decoration: BoxDecoration(
        color: AppColors.textFieldBg.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textFieldBg.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
        InkWell(
          onTap: _showMonthPicker,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedWeekStart),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _previousWeek,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'Minggu sebelumnya',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _nextWeek,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'Minggu berikutnya',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadEvents,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'Muat ulang',
            ),
          ],
        ),
      ],
    );
  }

  /// Dialog pilih bulan/tahun langsung, biar nggak perlu klik panah
  /// minggu-per-minggu buat loncat ke bulan yang jauh.
  void _showMonthPicker() {
    int pickYear = _selectedWeekStart.year;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setDialogState(() => pickYear--),
                  ),
                  Text('$pickYear', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setDialogState(() => pickYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = pickYear == _selectedWeekStart.year &&
                        month == _selectedWeekStart.month;
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isSelected ? AppColors.primaryGreen.withOpacity(0.15) : null,
                        foregroundColor:
                            isSelected ? AppColors.primaryGreen : Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedWeekStart = _getStartOfWeek(DateTime(pickYear, month, 1));
                        });
                        Navigator.of(dialogContext).pop();
                        _loadEvents();
                      },
                      child: Text(DateFormat('MMM', 'id_ID').format(DateTime(pickYear, month))),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
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

  Widget _buildCalendarGrid(List<DateTime> weekDates) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: weekDates.map((date) {
          return SizedBox(
            width: 80,
            child: _buildDateCard(date),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateCard(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final hasEvents =
        _events.containsKey(dateKey) && _events[dateKey]!.isNotEmpty;
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
          border: isToday ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
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
                    hasEvents ? '$eventsCount event' : 'Tidak ada\nevent',
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
                subtitle: event.description != null
                    ? Text(event.description!)
                    : null,
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