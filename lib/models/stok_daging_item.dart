// lib/models/stok_daging_item.dart
class StokDagingItem {
  final String jenis;
  final double bobot;
  final int jumlah;

  const StokDagingItem({
    required this.jenis,
    required this.bobot,
    required this.jumlah,
  });

  double get totalBerat => bobot * jumlah;

  Map<String, dynamic> toJson() => {
        'jenis': jenis,
        'bobot': bobot,
        'jumlah': jumlah,
      };

  factory StokDagingItem.fromJson(Map<String, dynamic> json) => StokDagingItem(
        jenis: json['jenis'] ?? '',
        bobot: (json['bobot'] as num?)?.toDouble() ?? 0,
        jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
      );
}