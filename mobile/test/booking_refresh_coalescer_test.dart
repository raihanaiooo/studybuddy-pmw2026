import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/domain/booking_refresh_coalescer.dart';

/// Jam dan penundaan palsu — waktu nyata tidak boleh memengaruhi test.
/// Dimulai dari waktu realistis (bukan epoch) agar kondisi awal sama
/// dengan produksi, di mana jam sistem selalu jauh dari epoch.
class _FakeClock {
  _FakeClock() : now = DateTime(2026, 1, 1);

  DateTime now;
  final List<Duration> requestedDelays = [];

  Future<void> delay(Duration duration) async {
    requestedDelays.add(duration);
    now = now.add(duration);
  }
}

void main() {
  test('menjalankan refresh pertama langsung tanpa throttle', () async {
    final clock = _FakeClock();
    final coalescer = BookingRefreshCoalescer(
      minInterval: const Duration(milliseconds: 500),
      clock: () => clock.now,
      delay: clock.delay,
    );

    var runs = 0;
    await coalescer.request(() async => runs++);

    expect(runs, 1);
    expect(clock.requestedDelays, isEmpty);
  });

  test(
    'paksaan saat refresh berjalan hanya menghasilkan SATU eksekusi susulan',
    () async {
      final clock = _FakeClock();
      final coalescer = BookingRefreshCoalescer(
        minInterval: const Duration(milliseconds: 500),
        clock: () => clock.now,
        delay: clock.delay,
      );

      final first = Completer<void>();
      var runs = 0;
      final firstRun = coalescer.request(() async {
        runs++;
        await first.future;
      });

      // Paksaan datang saat refresh pertama masih berjalan.
      final second = coalescer.request(() async => runs++);
      final third = coalescer.request(() async => runs++);

      first.complete();
      await firstRun;
      await second;
      await third;

      // Dua paksaan menumpuk → hanya satu eksekusi susulan (total 2).
      expect(runs, 2);
      expect(coalescer.hasQueuedRefresh, isFalse);
    },
  );

  test('refresh yang dipaksa lebih cepat dari minInterval ditahan', () async {
    final clock = _FakeClock();
    final coalescer = BookingRefreshCoalescer(
      minInterval: const Duration(milliseconds: 500),
      clock: () => clock.now,
      delay: clock.delay,
    );

    var runs = 0;
    await coalescer.request(() async => runs++);
    expect(runs, 1);

    // Paksaan kedua datang sebelum interval — ditahan (throttle).
    final second = coalescer.request(() async => runs++);
    expect(runs, 1);
    expect(clock.requestedDelays, isNotEmpty);
    await second;
    expect(runs, 2);
  });

  test('kegagalan refresh tidak merusak koalescer (percuobaan berikutnya tetap bisa)',
      () async {
    final clock = _FakeClock();
    final coalescer = BookingRefreshCoalescer(
      minInterval: const Duration(milliseconds: 500),
      clock: () => clock.now,
      delay: clock.delay,
    );

    var runs = 0;
    await coalescer.request(() async {
      runs++;
      throw StateError('jaringan putus');
    });
    await coalescer.request(() async => runs++);

    expect(runs, 2);
    expect(coalescer.isRefreshInFlight, isFalse);
  });

  test('eksekusi susulan yang gagal tidak diretlempar ke pemanggil', () async {
    final clock = _FakeClock();
    final coalescer = BookingRefreshCoalescer(
      minInterval: const Duration(milliseconds: 500),
      clock: () => clock.now,
      delay: clock.delay,
    );

    final first = Completer<void>();
    var runs = 0;
    final firstRun = coalescer.request(() async {
      runs++;
      await first.future;
    });
    final second = coalescer.request(() async {
      runs++;
      throw StateError('refresh susulan gagal');
    });

    first.complete();
    await firstRun;
    await second; // Tidak boleh melempar.

    expect(runs, 2);
    expect(coalescer.isRefreshInFlight, isFalse);
  });

  test('refresh yang berjalan lama tidak overlap dengan paksaan setelahnya',
      () async {
    final clock = _FakeClock();
    final coalescer = BookingRefreshCoalescer(
      minInterval: const Duration(milliseconds: 500),
      clock: () => clock.now,
      delay: clock.delay,
    );

    final slow = Completer<void>();
    var runs = 0;
    final firstRun = coalescer.request(() async {
      runs++;
      await slow.future;
    });

    // Paksaan selama refresh berjalan → hanya eksekusi susulan.
    final queued = coalescer.request(() async => runs++);
    slow.complete();

    await firstRun;
    await queued;

    expect(runs, 2);
    expect(coalescer.isRefreshInFlight, isFalse);
    expect(coalescer.hasQueuedRefresh, isFalse);
  });
}
