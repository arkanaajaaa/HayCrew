import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Ubah exception mentah (SocketException, TimeoutException, dll) jadi pesan
/// yang bisa dimengerti user, bukan dump raw Dart exception ke snackbar.
String friendlyErrorMessage(Object e) {
  if (e is TimeoutException) return 'Koneksi timeout. Coba lagi.';
  if (e is SocketException || e is http.ClientException) {
    return 'Gagal terhubung ke server. Cek koneksi internet kamu.';
  }
  return 'Terjadi kesalahan. Coba lagi.';
}
