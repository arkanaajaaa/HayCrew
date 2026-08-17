class ApiConstant {
  static const String baseUrl = 'https://api.haycrew.id';

  // Interval polling bersama dipakai semua layar yang auto-refresh, biar
  // "kesegaran" data selaras di semua role (kandang, gudang, dst) dan gak
  // ada satu layar yang lebih lambat dari yang lain buat data sejenis.
  static const pollInterval = Duration(seconds: 10);
}