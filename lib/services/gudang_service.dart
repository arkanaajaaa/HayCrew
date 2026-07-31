import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:haycrew_app/constants/api_constant.dart';

/// Ambil daftar nama gudang/tempat pendistribusian dari backend, biar
/// listnya ikut nambah begitu admin nambah gudang baru lewat panel admin —
/// bukan lagi hardcode di app. Fallback ke 2 nama default kalau gagal
/// (offline dll), biar form tetap bisa dipakai.
class GudangService {
  static const List<String> fallback = ['Bogor', 'Depok'];

  static Future<List<String>> fetchGudangNames(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${ApiConstant.baseUrl}/api/gudang'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return fallback;

      final decoded = jsonDecode(res.body);
      final list = decoded is Map && decoded['data'] is List
          ? decoded['data'] as List
          : <dynamic>[];

      final names = list
          .map((item) => item is Map ? item['nama']?.toString() : null)
          .whereType<String>()
          .toList();

      return names.isEmpty ? fallback : names;
    } catch (_) {
      return fallback;
    }
  }
}
