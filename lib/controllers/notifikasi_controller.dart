import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/models/calender_event_model.dart';
import 'package:haycrew_app/services/calender_service.dart';

class NotifikasiController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  static const _readIdsKey = 'notif_read_ids';

  final notifikasiList = <CalendarEventModel>[].obs;
  final isLoading = false.obs;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifikasi();
    _pollTimer = Timer.periodic(
      ApiConstant.pollInterval,
      (_) => fetchNotifikasi(showLoading: false),
    );
  }

  Set<String> get _readIds =>
      Set<String>.from(_storage.read<List>(_readIdsKey) ?? []);

  bool isRead(String id) => _readIds.contains(id);

  int get unreadCount => notifikasiList.where((e) => !_readIds.contains(e.id)).length;

  Future<void> fetchNotifikasi({bool showLoading = true}) async {
    if (_token.isEmpty) return;
    if (showLoading) isLoading.value = true;

    final grouped = await CalendarService.fetchEvents(token: _token);
    final all = grouped.values.expand((e) => e).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    notifikasiList.assignAll(all);
    isLoading.value = false;
  }

  void markAsRead(String id) {
    final ids = _readIds..add(id);
    _storage.write(_readIdsKey, ids.toList());
    notifikasiList.refresh();
  }

  void markAllAsRead() {
    final ids = notifikasiList.map((e) => e.id).toSet();
    _storage.write(_readIdsKey, ids.toList());
    notifikasiList.refresh();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}