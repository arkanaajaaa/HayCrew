import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:haycrew_app/constants/api_constant.dart';
import 'package:haycrew_app/models/permintaan_model.dart';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/routes/app_routes.dart';
import '../models/status_permintaan_model.dart';

class HomeController extends GetxController {
  final _storage = GetStorage();
  String get _token => _storage.read('token') ?? '';

  final RxList<StatusPermintaanModel> statusList =
      <StatusPermintaanModel>[].obs;
  final RxBool isLoading = false.obs;

  final userName = 'User'.obs;
  final userRole = 'Karyawan'.obs;
  final userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    loadStatusPermintaan();
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;
    userName.value = args['userName'] ?? 'User';
    userRole.value = args['userRole'] ?? 'Karyawan';
    userId.value = args['userId'] ?? '';
  }

  Future<void> loadStatusPermintaan() async {
    try {
      isLoading.value = true;

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

        statusList.value = permintaanList
            .map(
              (item) => StatusPermintaanModel.fromJson({
                'id': item.id.toString(),
                'day': item.tanggal.day,
                'month': _monthName(item.tanggal.month),
                'title': item.namaPermintaan,
                'status': _mapStatus(item.status),
                'description': item.tipe == 'dana'
                    ? 'Dana: Rp ${item.harga ?? 0}'
                    : 'Barang: ${item.jumlah ?? 0} pcs',
              }),
            )
            .toList();
      } else {
        Get.snackbar('Error', 'Gagal memuat data permintaan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
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
            Text('Status: ${status.status.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text(status.description ?? 'Tidak ada deskripsi'),
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
      ),
    );
  }
}
