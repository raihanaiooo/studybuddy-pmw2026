import 'dart:async';

/// Koalesensi paksaan refresh booking (Wave 2.2).
///
/// Peristiwa realtime booking hanya memberi tahu "ada perubahan" — kontrak
/// isi event (C-BOOK-06 / D-52) belum disepakati pemilik Back-End, sehingga
/// isi payload TIDAK boleh dipakai untuk mengubah state secara langsung.
/// Satu-satunya reaksi yang aman adalah membaca ulang lewat jalur baca yang
/// sudah terverifikasi. Karena Supabase Realtime dapat mengirim beberapa
/// event untuk satu perubahan yang sama (INSERT + UPDATE, event replay,
/// dsb.), paksaan refresh dikoaleskan agar tidak menembak Supabase berulang:
///
///  * saat satu refresh sedang berjalan, paksaan berikutnya tidak menjalankan
///    refresh paralel — hanya satu eksekusi susulan yang mewakili SEMUA
///    paksaan yang datang selama refresh itu berjalan;
///  * paksaan yang datang lebih cepat dari [minInterval] sejak refresh
///    terakhir selesai ditahan dulu (throttle ringan) sebelum dijalankan.
///
/// Murni Dart tanpa Flutter/Supabase — ini utilitas koordinasi murni, bukan
/// aturan bisnis — sehingga dapat diuji independen dengan jam palsu.
class BookingRefreshCoalescer {
  BookingRefreshCoalescer({
    this.minInterval = const Duration(milliseconds: 500),
    DateTime Function()? clock,
    Future<void> Function(Duration duration)? delay,
  }) : _clock = clock ?? DateTime.now,
       _delay = delay ?? _defaultDelay;

  /// Jeda minimum antara dua refresh yang mulai dijalankan.
  final Duration minInterval;

  final DateTime Function() _clock;

  /// Penundaan sebelum refresh dijalankan. Implementasi bawaan
  /// (`Future.delayed`) memajukan waktu nyata, sehingga throttle selalu
  /// berakhir. Pengganti (di test) wajib memajukan jam palsu sebesar durasi
  /// yang diminta agar loop throttle tetap berakhir.
  final Future<void> Function(Duration duration) _delay;

  static Future<void> _defaultDelay(Duration duration) =>
      Future<void>.delayed(duration);

  bool _inFlight = false;
  bool _trailingQueued = false;
  DateTime _lastStarted = DateTime.fromMillisecondsSinceEpoch(0);

  /// True saat satu refresh sedang berjalan.
  bool get isRefreshInFlight => _inFlight;

  /// True bila satu eksekusi susulan sudah diantrekan.
  bool get hasQueuedRefresh => _trailingQueued;

  /// Meminta [refresh] dijalankan dengan koalesensi.
  ///
  /// Bila refresh sudah berjalan, panggilan ini hanya menandai SATU eksekusi
  /// susulan (yang mewakili semua paksaan yang menumpuk) lalu selesai tanpa
  /// menunggu. Bila belum, panggilan menunggu [minInterval] sejak refresh
  /// terakhir mulai dijalankan, lalu menjalankan [refresh] dan menungguinya
  /// (termasuk eksekusi susulannya).
  ///
  /// Kegagalan [refresh] ditelan di sini: event realtime berikutnya akan
  /// memicu percobaan ulang, dan state yang sudah ada tidak boleh rusak
  /// hanya karena satu refresh latar gagal.
  Future<void> request(Future<void> Function() refresh) async {
    if (_inFlight) {
      // Refresh sudah berjalan: cukup satu eksekusi susulan.
      _trailingQueued = true;
      return;
    }
    while (true) {
      // Refresh lain baru mulai berjalan (mis. pemanggil paralel lebih dulu
      // melewati throttle) — jangan tumpang tindih; cukup eksekusi susulan.
      if (_inFlight) {
        _trailingQueued = true;
        return;
      }
      final sinceLast = _clock().difference(_lastStarted);
      if (sinceLast >= minInterval) break;
      await _delay(minInterval - sinceLast);
    }
    await _run(refresh);
  }

  Future<void> _run(Future<void> Function() refresh) async {
    // Satu titik gerbang terakhir: dua pemanggil bisa lolos throttle pada
    // mikrotask yang sama — hanya satu yang boleh menjalankan refresh.
    if (_inFlight) {
      _trailingQueued = true;
      return;
    }
    _inFlight = true;
    _lastStarted = _clock();
    try {
      await refresh();
    } catch (_) {
      // Refresh latar gagal (mis. jaringan) — tidak diretlempar.
    } finally {
      _inFlight = false;
    }
    if (_trailingQueued) {
      _trailingQueued = false;
      await _run(refresh);
    }
  }
}
