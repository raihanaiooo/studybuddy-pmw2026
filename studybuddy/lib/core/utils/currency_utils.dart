/// Utility fungsi untuk format nilai mata uang
class CurrencyUtils {
  CurrencyUtils._();

  /// Format angka jadi format ribuan ala Rupiah: "1.240.000" (tanpa
  /// prefix "Rp", tinggal ditambahkan sendiri di UI)
  static String formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
