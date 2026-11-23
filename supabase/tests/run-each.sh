#!/usr/bin/env bash
# Menjalankan tiap berkas uji SQL di database terpisah (lewat run.sh).
# Gagal (exit 1) bila ada berkas yang menghasilkan ERROR/GAGAL, exit non-nol, atau tanpa baris "OK".
# Pakai: PGHOST=localhost PGPORT=54329 PGUSER=postgres supabase/tests/run-each.sh a.test.sql b.test.sql
cd "$(dirname "$0")"
fail=0
for f in "$@"; do
  out=$(bash ./run.sh "$f" 2>&1); rc=$?
  echo "$out" | grep -E "OK|ERROR|GAGAL"
  if [ $rc -ne 0 ] || echo "$out" | grep -qE "ERROR|GAGAL" || ! echo "$out" | grep -q "OK"; then
    echo "GAGAL: $f" >&2
    fail=1
  fi
done
exit $fail
