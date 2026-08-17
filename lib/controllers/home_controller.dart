import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/models/permintaan_model.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/routes/app_routes.dart';
import 'package:haycrew_app/utils/error_utils.dart';
import 'package:intl/intl.dart';
import '../models/status_permintaan_model.dart';

class HomeController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';
  String get token => _token;

  final RxList<StatusPermintaanModel> statusList =
      <StatusPermintaanModel>[].obs;
  final RxBool isLoading = false.obs;

  final userName = 'User'.obs;
  final userRole = 'Karyawan'.obs;
  final userId = ''.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    loadStatusPermintaan();
    // Polling-nya dijalankan satu timer bersama di HomePageKandang (biar
    // nyatu sama refresh CalendarWidget), bukan timer sendiri di sini.
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    userName.value = args['userName'] ?? 'User';
    userRole.value = args['userRole'] ?? 'Karyawan';
    userId.value = args['userId'] ?? '';
    userEmail.value = args['userEmail'] ?? '';
  }

  Future<void> loadStatusPermintaan({bool showLoading = true}) async {
  try {
    if (showLoading) isLoading.value = true;

    final response = await http
        .get(
          Uri.parse('${ApiConstant.baseUrl}/api/permintaan'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];

      final permintaanList = data
          .map((item) => PermintaanModel.fromJson(item))
          .toList();

      final mapped = permintaanList
          .map(
            (item) => StatusPermintaanModel.fromJson({
              'id': item.id.toString(),
              'day': item.tanggal.day,
              'month': _monthName(item.tanggal.month),
              'title': item.namaPermintaan,
              'status': _mapStatus(item.status),
              'description': item.tipe == 'dana'
                  ? 'Dana: Rp ${NumberFormat.decimalPattern('id_ID').format(num.tryParse(item.harga ?? '') ?? 0)}'
                  : 'Barang: ${item.jumlah ?? 0} pcs',
              'alasan_tolak': item.alasanTolak,
            }),
          )
          .toList();

      mapped.sort((a, b) => _statusPriority(a.status).compareTo(_statusPriority(b.status)));

      statusList.value = mapped;
    } else {
      Get.snackbar('Error', 'Gagal memuat data permintaan.');
    }
    } catch (e) {
      Get.snackbar('Error', friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  int _statusPriority(dynamic status) {
    final s = status.toString().split('.').last; // handle kalau status itu enum
    switch (s) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'rejected':
        return 2;
      default:
        return 3;
    }
  }

  Future<void> refreshData() async => await loadStatusPermintaan();

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month];
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'disetujui':
        return 'accepted';
      case 'ditolak':
        return 'rejected';
      default:
        return 'pending';
    }
  }

  void navigateToNotifications() {
    Get.snackbar(
      'Info',
      'Fitur Notifikasi akan segera tersedia',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[100],
      margin: const EdgeInsets.all(15),
    );
  }

  void navigateToLaporKandang() => Get.toNamed(AppRoutes.LAPOR_KANDANG);
  void navigateToKirimPermintaan() => Get.toNamed(AppRoutes.KIRIM_PERMINTAAN);

  void navigateToDetail(StatusPermintaanModel status) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(status.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_statusLabel(status.status)}'),
            const SizedBox(height: 8),
            Text(status.description ?? 'Tidak ada deskripsi'),
            if (status.status == StatusType.rejected &&
                (status.alasanTolak?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              const Text(
                'Alasan Penolakan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(status.alasanTolak!),
            ],
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Tutup'))],
      ),
    );
  }

  String _statusLabel(StatusType type) {
    switch (type) {
      case StatusType.accepted:
        return 'Diterima';
      case StatusType.pending:
        return 'Pending';
      case StatusType.rejected:
        return 'Ditolak';
    }
  }
}
