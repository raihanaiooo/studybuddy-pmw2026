"""Membuat SQL impor order Jul-Okt 2026 dari sheet "Database Transaksi" (satu kali jalan).

Pakai:  python -I supabase/seed/build_order_seed.py "<berkas.xlsx>" "<keluaran.sql>"
Skrip hanya membaca Excel dan menulis berkas SQL; tidak menyentuh database. Ringkasan pemetaan dan
pencocokan angka dicetak ke layar, dan angka yang sama diperiksa lagi oleh SQL sebelum commit.
"""
import re
import sys
import uuid
import collections
import datetime as dt

import openpyxl

NS = uuid.UUID('6f0c1d3e-5a7b-4c2d-9e1f-0a1b2c3d4e5f')   # tetap, supaya UUID sama tiap dijalankan
SHEET = 2                                                  # "Database Transaksi"
TUTOR_PCT = 70
BULAN = {'Juli': 7, 'Agustus': 8, 'September': 9, 'Oktober': 10}


def uid(*parts):
    return str(uuid.uuid5(NS, '|'.join(str(p) for p in parts)))


def q(v):
    """Literal SQL."""
    if v is None:
        return 'null'
    if isinstance(v, bool):
        return 'true' if v else 'false'
    if isinstance(v, (int, float)):
        return repr(round(v, 2)) if isinstance(v, float) else str(v)
    if isinstance(v, dt.datetime):
        v = v.date()
    return "'" + str(v).replace("'", "''") + "'"


def tutor_key(raw):
    """'tutor tiara (outsourcing)' -> ('tiara', True); 'KAS INTERNAL' -> ('KAS', False)."""
    s = str(raw).strip()
    if s.upper() == 'KAS INTERNAL':
        return 'KAS', False
    outs = bool(re.search(r'outsourc', s, re.I))
    s = re.sub(r'\(.*?\)', '', s)
    s = re.sub(r'^tutor\s+', '', s, flags=re.I).strip().lower()
    return s, outs


def parse_duration(k, m):
    """Kolom K + jumlah sesi M -> (menit per sesi, jumlah sesi dari K, M dipakai bila > 1).
    '45x14' -> (45, 14); 120 dengan M=2 -> (60, 2); 45 -> (45, 1)."""
    if isinstance(k, str):
        mt = re.fullmatch(r'\s*(\d+)\s*x\s*(\d+)\s*', k)
        if mt:
            return int(mt.group(1)), int(mt.group(2))
        return None, 1
    if isinstance(k, (int, float)) and k > 0:
        k = int(k)
        if m and m > 1 and k % int(m) == 0:
            return k // int(m), 1
        return k, 1
    return None, 1


def parse_date(v):
    """-> (date atau None, catatan teks atau None)."""
    if isinstance(v, dt.datetime):
        return v.date(), None
    if v is None or str(v).strip() in ('', '-'):
        return None, None
    return None, str(v).strip()


def total_sessions_from_name(name):
    mt = re.search(r'(\d+)\s*sesi\b', name or '', re.I)
    return int(mt.group(1)) if mt else None


def num(v):
    return float(v) if isinstance(v, (int, float)) else 0.0


def load(path):
    ws = openpyxl.load_workbook(path, data_only=True).worksheets[SHEET]
    rows = []
    for r in ws.iter_rows(min_row=2, values_only=True):
        if r[1]:
            rows.append(r[:19])
    return rows


def build(rows):
    orders = collections.OrderedDict()
    refunds = []
    tutors = {}            # key -> {'name', 'outs'}
    for r in rows:
        (bulan, fo, tutor, buddy, tgl_order, status, tgl, kategori, layanan, materi, k, harga, m, extend, total,
         _p, _q, bonus, _s) = r
        if fo == 'REFUND':
            refunds.append({'bulan': bulan, 'amount': num(total)})
            continue
        o = orders.setdefault(fo, {'fo': fo, 'bulan': bulan, 'rows': [], 'buddy': [], 'status': [],
                                   'ordered': tgl_order, 'kategori': kategori, 'layanan': layanan, 'materi': materi})
        o['rows'].append(r)
        if buddy and str(buddy).strip() not in ('', '-'):
            o['buddy'].append(str(buddy).strip())
        o['status'].append(status)
        key, outs = tutor_key(tutor)
        if key not in ('KAS', '-'):
            t = tutors.setdefault(key, {'name': key.title(), 'outs': False})
            t['outs'] = t['outs'] or outs
    return orders, refunds, tutors


def make_sql(orders, refunds, tutors, report):
    out = []
    w = out.append
    w('-- Impor data nyata Jul-Okt 2026 dari Excel. DIBUAT OTOMATIS oleh supabase/seed/build_order_seed.py.')
    w('-- Jalankan SETELAH operasional-1-apply.sql dan hapus-data-uji.sql. Satu transaksi: bila ada angka yang tidak cocok,')
    w('-- seluruhnya dibatalkan. Aman dijalankan ulang: berhenti bila order FO020-FO062 sudah ada.')
    w('begin;')
    w("do $$ begin if exists (select 1 from public.orders where form_no between 'FO020' and 'FO062') then")
    w("  raise exception 'impor sudah pernah dijalankan (order FO020-FO062 sudah ada)'; end if; end $$;")
    w('')
    w('-- Tutor tanpa akun (nama depan dari Excel; nama lengkap, WhatsApp, dan rekening diisi nanti di menu Tutor).')
    for key, t in sorted(tutors.items()):
        w("insert into public.tutors (id, full_name, verification_status, account_status, is_featured, is_outsourced) "
          "values (%s, %s, 'verified', 'active', false, %s);" % (q(uid('tutor', key)), q(t['name']), q(t['outs'])))
    w('')
    ses_rows = []
    for fo, o in orders.items():
        first = o['rows'][0]
        kat, layanan, materi = o['kategori'], o['layanan'], o['materi']
        counts = []
        for r in o['rows']:
            dur, cnt = parse_duration(r[10], num(r[12]))
            m = int(num(r[12])) or 1
            count = m if m > 1 else cnt
            counts.append((dur, count))
        name_total = total_sessions_from_name(layanan)
        sum_count = sum(c for _, c in counts)
        is_paket = bool(re.search(r'bundling', layanan or '', re.I)) or name_total is not None and name_total > 1 \
            and sum(1 for r in o['rows']) > 1 or (name_total or 0) >= 12
        all_done = all(s == 'done' for s in o['status'])
        sessions_total = name_total if (is_paket and name_total and name_total >= sum_count and not all_done) else sum_count
        if name_total and name_total != sum_count:
            report['catatan'].append('%s: nama layanan menyebut %d sesi, baris Excel berjumlah %d (dipakai %d)' % (fo, name_total, sum_count, sessions_total))
        base = sum(num(r[11]) * (int(num(r[12])) or 1) for r in o['rows'])
        buddy = collections.Counter(o['buddy']).most_common(1)
        buddy_name = max(set(o['buddy']), key=len) if o['buddy'] else '(belum tercatat)'
        status_row = 'selesai' if all_done else 'terjadwal'
        mat = None if isinstance(materi, (int, float)) or str(materi).strip() in ('', '-') else str(materi).strip()
        oid = uid('order', fo)
        ordered = o['ordered'].date() if isinstance(o['ordered'], dt.datetime) else None
        w("insert into public.orders (id, form_no, buddy_name, service_category, service_name, subject, kind, sessions_total, "
          "price_per_session, total_price, ordered_at, notes) values (%s, %s, %s, %s, %s, %s, %s, %d, %s, %s, %s, %s);" % (
              q(oid), q(fo), q(buddy_name), q(kat), q(layanan), q(mat), q('paket' if is_paket else 'lepas'), sessions_total,
              q(round(base / sessions_total, 2)), q(round(base, 2)), q(ordered),
              q('Diimpor dari Excel Jul-Okt 2026' + ('' if buddy_name != '(belum tercatat)' else '; nama buddy kosong di Excel'))))
        report['orders'][o['bulan']] += 1
        for i, r in enumerate(o['rows']):
            tkey, _ = tutor_key(r[2])
            dur, count = counts[i]
            m = int(num(r[12])) or 1
            share = num(r[11]) * m
            rate = round(share / count, 2)
            d, dnote = parse_date(r[6])
            sid = uid('ses', fo, i)
            recipient = 'kas' if tkey == 'KAS' else 'tutor'
            tutor_id = None if recipient == 'kas' else uid('tutor', tkey)
            if recipient == 'tutor' and tkey == '-':
                raise SystemExit('baris %s tanpa tutor: perlu diputuskan manual' % fo)
            w("insert into public.order_sessions (id, order_id, recipient, tutor_id, sessions_count, session_date, date_note, "
              "duration_minutes, rate, tutor_pct, status) values (%s, %s, %s, %s, %d, %s, %s, %s, %s, %d, %s);" % (
                  q(sid), q(oid), q(recipient), q(tutor_id), count, q(d), q(dnote), q(dur), q(rate), 0 if recipient == 'kas' else TUTOR_PCT, q(status_row)))
            amount = round(rate * count, 2)
            report['by_month'][o['bulan']]['revenue'] += amount
            report['by_month'][o['bulan']]['excel_base'] += share
            ses_rows.append((fo, i, share, amount))
            ext = num(r[13])
            if ext:
                w("insert into public.order_adjustments (id, order_id, session_id, tutor_id, kind, amount, tutor_pct, note, created_at) "
                  "values (%s, %s, %s, %s, 'extend', %s, %d, %s, %s);" % (
                      q(uid('adj-ext', fo, i)), q(oid), q(sid), q(tutor_id), q(ext), TUTOR_PCT, q('Extend/bonus pesanan dari Excel'),
                      q("%s 12:00+07" % (d or ordered))))
                report['by_month'][o['bulan']]['extend'] += ext
            bon = num(r[17])
            if bon:
                w("insert into public.order_adjustments (id, order_id, session_id, tutor_id, kind, amount, tutor_pct, note, created_at) "
                  "values (%s, %s, %s, %s, 'bonus_tutor', %s, 100, %s, %s);" % (
                      q(uid('adj-bon', fo, i)), q(oid), q(sid), q(tutor_id), q(bon), q('Bonus tutor dari Excel'),
                      q("%s 12:00+07" % (d or ordered))))
                report['by_month'][o['bulan']]['bonus'] += bon
        o['paid_by_excel'] = o['bulan'] in ('Juli', 'Agustus') and all_done
    w('')
    # refund: baris REFUND tanpa nomor formulir; 76.000 = 2 sesi x 38.000, cocok dengan FO030 (5 Agu, 2 sesi, 76.000)
    for i, rf in enumerate(refunds):
        w("insert into public.order_adjustments (id, order_id, kind, amount, note, created_at) values (%s, %s, 'refund', %s, %s, %s);" % (
            q(uid('adj-refund', i)), q(uid('order', 'FO030')), q(rf['amount']),
            q('Dari baris REFUND bulan %s di Excel; nomor formulir tidak tertulis, diduga FO030 (2 sesi x Rp38.000). Mohon cek.' % rf['bulan']),
            q('2026-08-31 12:00+07')))
        report['by_month'][rf['bulan']]['refund'] += rf['amount']
    w('')
    w('-- Pembayaran: rekap Excel menandai Juli dan Agustus "Done & Paid". Tanggal bayar = tanggal order (perkiraan).')
    w('-- Bila tidak mau, hapus bagian ini sampai baris "-- akhir pembayaran".')
    for fo, o in orders.items():
        if o.get('paid_by_excel'):
            base = sum(num(r[11]) * (int(num(r[12])) or 1) for r in o['rows']) + sum(num(r[13]) for r in o['rows'])
            ordered = o['ordered'].date() if isinstance(o['ordered'], dt.datetime) else None
            w("insert into public.order_payments (id, order_id, amount, paid_at, method, note) values (%s, %s, %s, %s, 'transfer', %s);" % (
                q(uid('pay', fo)), q(uid('order', fo)), q(round(base, 2)), q(ordered),
                q('Impor Excel: bulan %s berstatus Done & Paid; tanggal bayar = tanggal order (perkiraan)' % o['bulan'])))
            report['paid_orders'] += 1
    w('-- akhir pembayaran')
    w('')
    # bukti lulus: bandingkan dengan Rekap Eksekutif (nilai dari sheet 1, dicetak juga di skrip)
    for bulan, exp in report['expected'].items():
        w("do $$ declare v numeric; begin select coalesce(sum(s.amount) + (select coalesce(sum(a.amount), 0) from public.order_adjustments a "
          "join public.orders oo on oo.id = a.order_id where a.kind = 'extend' and a.deleted_at is null and extract(month from oo.ordered_at) = %d), 0) "
          "into v from public.order_sessions s join public.orders o on o.id = s.order_id where s.deleted_at is null and s.status <> 'batal' "
          "and extract(month from o.ordered_at) = %d; if abs(v - %s) > 1 then raise exception 'pendapatan %s tidak cocok: sistem %% vs Excel %s', v; end if; end $$;"
          % (BULAN[bulan], BULAN[bulan], exp, bulan, exp))
    w('commit;')
    return '\n'.join(out) + '\n'


def expected_from_rekap(path):
    ws = openpyxl.load_workbook(path, data_only=True).worksheets[0]
    exp = {}
    for r in ws.iter_rows(min_row=4, max_row=7, values_only=True):
        exp[r[0]] = {'aktif': num(r[6]), 'bonus': num(r[9]), 'extend': num(r[4]), 'refund': num(r[5])}
    return exp


def main(src, dest):
    rows = load(src)
    orders, refunds, tutors = build(rows)
    rekap = expected_from_rekap(src)
    report = {'catatan': [], 'orders': collections.Counter(), 'paid_orders': 0,
              'by_month': collections.defaultdict(lambda: collections.defaultdict(float)),
              'expected': {b: v['aktif'] for b, v in rekap.items()}}
    sql = make_sql(orders, refunds, tutors, report)
    open(dest, 'w', encoding='utf-8').write(sql)

    print('Tutor (%d):' % len(tutors))
    for k, t in sorted(tutors.items()):
        print('  %-14s -> %s%s' % (k, t['name'], ' (outsourcing)' if t['outs'] else ''))
    print('Order: %d, pembayaran Jul/Agu: %d' % (len(orders), report['paid_orders']))
    bad = 0
    print('%-10s %14s %14s %10s' % ('Bulan', 'Sistem', 'Rekap Excel', 'Selisih'))
    tot_s = tot_e = 0
    for b in ('Juli', 'Agustus', 'September', 'Oktober'):
        s = report['by_month'][b]['revenue'] + report['by_month'][b]['extend']
        e = rekap[b]['aktif']
        tot_s += s
        tot_e += e
        flag = '' if abs(s - e) <= 1 else '  <-- BEDA'
        bad += bool(flag)
        print('%-10s %14.2f %14.2f %10.2f%s' % (b, s, e, s - e, flag))
    print('%-10s %14.2f %14.2f %10.2f' % ('Total', tot_s, tot_e, tot_s - tot_e))
    bonus = sum(report['by_month'][b]['bonus'] for b in report['by_month'])
    print('Bonus tutor: %.0f (Excel 30000); extend: %.0f; refund: %.0f' % (
        bonus, sum(report['by_month'][b]['extend'] for b in report['by_month']),
        sum(report['by_month'][b]['refund'] for b in report['by_month'])))
    for c in report['catatan']:
        print('CATATAN', c)
    return bad


if __name__ == '__main__':
    sys.exit(1 if main(sys.argv[1], sys.argv[2]) else 0)
