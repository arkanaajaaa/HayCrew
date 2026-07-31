/// Ambil nama panggilan (kata pertama) dari nama lengkap, dipakai supaya
/// tampilan nama di seluruh app (greeting, profil) konsisten pakai nama
/// pendek, bukan nama lengkap dari database.
String nicknameFrom(String? fullName) {
  final trimmed = (fullName ?? '').trim();
  if (trimmed.isEmpty) return 'User';
  return trimmed.split(RegExp(r'\s+')).first;
}
