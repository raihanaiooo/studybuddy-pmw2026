/// Kumpulan fungsi validasi input form
class ValidatorUtils {
  ValidatorUtils._();

  /// Validasi email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  /// Validasi password minimal 8 karakter
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  /// Validasi field tidak kosong
  static String? required(String? value, [String label = 'Field']) {
    if (value == null || value.trim().isEmpty)
      return '$label tidak boleh kosong';
    return null;
  }
}
