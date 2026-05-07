/// lib/services/mock_auth_service.dart
///
/// Mock authentication service untuk development.
/// Ganti seluruh class ini dengan actual HTTP call ke backend saat production.
///
/// Cara kerja:
/// 1. LoginController memanggil MockAuthService.login(email, password)
/// 2. Service mencari user di _mockUsers berdasarkan email + password
/// 3. Jika cocok, return MockUser yang berisi name, role, userId
/// 4. LoginController membaca role lalu navigasi ke dashboard yang sesuai

class MockUser {
  final String userId;
  final String name;
  final String email;

  /// role: 'kandang' | 'storage' | 'reseller'
  final String role;

  const MockUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });
}

class MockAuthService {
  MockAuthService._(); // tidak bisa di-instantiate

  /// Daftar user mock untuk development.
  /// Format: { 'email': '...', 'password': '...', user data }
  static const List<Map<String, String>> _mockUsers = [
    {
      'email'   : 'kandang@gmail.com',
      'password': 'ayam123',
      'userId'  : 'user_001',
      'name'    : 'Karyawan Kandang',
      'role'    : 'kandang',
    },
    {
      'email'   : 'storage@gmail.com',
      'password': 'ikan123',
      'userId'  : 'user_002',
      'name'    : 'Karyawan Storage',
      'role'    : 'storage',
    },
    // TODO: Tambahkan mock reseller jika sudah ada dashboardnya
    // {
    //   'email'   : 'reseller@gmail.com',
    //   'password': 'reseller123',
    //   'userId'  : 'user_003',
    //   'name'    : 'Karyawan Reseller',
    //   'role'    : 'reseller',
    // },
  ];

  /// Simulasi login dengan delay seperti network request.
  /// Return [MockUser] jika berhasil, null jika email/password salah.
  static Future<MockUser?> login(String email, String password) async {
    // Simulasi network delay
    await Future.delayed(const Duration(seconds: 1));

    final found = _mockUsers.where(
      (u) =>
          u['email']?.toLowerCase() == email.toLowerCase().trim() &&
          u['password'] == password,
    );

    if (found.isEmpty) return null;

    final data = found.first;
    return MockUser(
      userId: data['userId']!,
      name  : data['name']!,
      email : data['email']!,
      role  : data['role']!,
    );
  }
}