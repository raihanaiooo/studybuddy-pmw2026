#!/usr/bin/env bash
# Menjalankan uji SQL pada database baru (dibuat ulang tiap kali).
# Pakai: PGHOST=localhost PGPORT=54329 PGUSER=postgres supabase/tests/run.sh [--no-migration] test1.sql [test2.sql ...]
# Contoh: supabase/tests/run.sh diagnostic.test.sql diagnostic_seed.test.sql
set -euo pipefail
cd "$(dirname "$0")"

WITH_MIGRATION=1
if [[ "${1:-}" == "--no-migration" ]]; then WITH_MIGRATION=0; shift; fi
[[ $# -ge 1 ]] || { echo "sebutkan minimal satu berkas uji" >&2; exit 2; }

DB="diag_test_$$"
psql -d postgres -q -v ON_ERROR_STOP=1 -c "create database $DB"
trap 'psql -d postgres -q -c "drop database if exists $DB" >/dev/null' EXIT

ARGS=(-d "$DB" -q -v ON_ERROR_STOP=1 -f 00_stubs.sql)
if [[ $WITH_MIGRATION -eq 1 ]]; then ARGS+=(-f ../migration/002_diagnostic.sql -f ../migration/003_diagnostic_utbk.sql); fi
for f in "$@"; do ARGS+=(-f "$f"); done
psql "${ARGS[@]}"
