"""Validasi utbk_questions.json dan hasilkan diagnostic_utbk.sql.

Pakai (dari akar repo): python -I supabase/seed/build_utbk_seed.py
Gagal dengan daftar pelanggaran bila data tidak lolos validasi; tidak menulis berkas dalam kasus itu.
"""
import ast
import json
import math
import os
import sys
from collections import Counter
from fractions import Fraction

HERE = os.path.dirname(os.path.abspath(__file__))
SOURCE = os.path.join(HERE, 'utbk_questions.json')
OUTPUT = os.path.join(HERE, 'diagnostic_utbk.sql')

SKILL_RANGES = {'pu': range(1, 9), 'pk': range(9, 17), 'lbi': range(17, 25)}
TOTAL = 24
OPTIONS_PER_QUESTION = 5
MIN_PER_INDEX, MAX_PER_INDEX = 3, 7

_ALLOWED_NODES = (
    ast.Expression, ast.BinOp, ast.UnaryOp, ast.Constant, ast.Call, ast.Name, ast.Load, ast.Attribute,
    ast.Add, ast.Sub, ast.Mult, ast.Div, ast.FloorDiv, ast.Mod, ast.Pow, ast.USub, ast.UAdd,
    ast.Tuple, ast.List, ast.Compare, ast.Eq, ast.IfExp, ast.keyword,
)
_ALLOWED_NAMES = {'Fraction', 'math', 'str', 'int', 'round', 'abs', 'sum', 'min', 'max', 'len', 'range'}


def _eval_verify(expr):
    """Evaluasi ekspresi `verify` dengan whitelist node dan nama; kembalikan str hasilnya."""
    tree = ast.parse(expr, mode='eval')
    for node in ast.walk(tree):
        if not isinstance(node, _ALLOWED_NODES):
            raise ValueError(f'node {type(node).__name__} tidak diizinkan')
        if isinstance(node, ast.Name) and node.id not in _ALLOWED_NAMES:
            raise ValueError(f'nama {node.id} tidak diizinkan')
        if isinstance(node, ast.Attribute) and (node.attr.startswith('_') or not isinstance(node.value, ast.Name)):
            raise ValueError(f'atribut {node.attr} tidak diizinkan')
    env = {'Fraction': Fraction, 'math': math, 'str': str, 'int': int, 'round': round, 'abs': abs,
           'sum': sum, 'min': min, 'max': max, 'len': len, 'range': range}
    return str(eval(compile(tree, '<verify>', 'eval'), {'__builtins__': {}}, env)).strip()


def validate(data):
    """Kembalikan daftar pelanggaran (kosong = lolos)."""
    problems = []
    questions = data.get('questions', [])
    passages = {p['id'] for p in data.get('passages', [])}

    if len(questions) != TOTAL:
        problems.append(f'harus {TOTAL} soal, ada {len(questions)}')

    positions = Counter(q.get('position') for q in questions)
    for pos, count in positions.items():
        if count > 1:
            problems.append(f'posisi {pos} dipakai {count} kali')

    for skill, rng in SKILL_RANGES.items():
        got = sorted(q['position'] for q in questions if q.get('skill') == skill)
        if got != list(rng):
            problems.append(f'subtes {skill} harus 8 soal di posisi {rng.start}-{rng.stop - 1}, ada posisi {got}')

    index_use = Counter()
    for q in questions:
        label = f"soal {q.get('position')}"
        options = q.get('options', [])
        if len(options) != OPTIONS_PER_QUESTION:
            problems.append(f'{label}: harus {OPTIONS_PER_QUESTION} opsi, ada {len(options)}')
        if len(set(options)) != len(options):
            problems.append(f'{label}: opsi kembar')
        correct = q.get('correct_index')
        if not isinstance(correct, int) or not 0 <= correct < len(options):
            problems.append(f'{label}: correct_index {correct} di luar rentang opsi')
        else:
            index_use[correct] += 1
        if not str(q.get('explanation', '')).strip():
            problems.append(f'{label}: penjelasan kosong')
        if not str(q.get('stem', '')).strip():
            problems.append(f'{label}: stem kosong')

        if q.get('skill') == 'lbi' and q.get('passage_id') not in passages:
            problems.append(f"{label}: soal lbi wajib passage_id yang ada (dapat {q.get('passage_id')})")

        verify = q.get('verify')
        if q.get('skill') == 'pk' and not verify:
            problems.append(f'{label}: soal pk wajib verify')
        if verify and isinstance(correct, int) and 0 <= correct < len(options):
            try:
                got = _eval_verify(verify)
            except Exception as exc:  # noqa: BLE001 - semua kegagalan evaluasi adalah pelanggaran
                problems.append(f'{label}: verify tidak diizinkan atau gagal ({exc})')
            else:
                if got != str(options[correct]).strip():
                    problems.append(f'{label}: verify menghasilkan "{got}", tidak sama dengan kunci "{options[correct]}"')

    for idx in range(OPTIONS_PER_QUESTION):
        if not MIN_PER_INDEX <= index_use[idx] <= MAX_PER_INDEX:
            problems.append(f'sebaran kunci timpang: indeks {idx} dipakai {index_use[idx]} kali (harus {MIN_PER_INDEX}-{MAX_PER_INDEX})')
    return problems


def _lit(text):
    return "'" + str(text).replace("'", "''") + "'"


def generate_sql(data):
    out = [
        '-- Seed: 24 soal UTBK mini orisinal (pu, pk, lbi) + aturan pita -> paket SNBT.',
        '-- DIHASILKAN oleh build_utbk_seed.py dari utbk_questions.json; jangan diedit tangan.',
        '-- Soal masuk NONAKTIF. Aktifkan hanya setelah soal lbi dibaca manusia yang pernah ikut UTBK:',
        "--   update diagnostic_questions set is_active = true where test_code = 'utbk';",
        '-- Aman dijalankan ulang (on conflict do nothing).',
        '',
    ]
    if data['passages']:
        out.append('insert into diagnostic_passages (id, text) values')
        out.append(',\n'.join(f"  ({_lit(p['id'])}, {_lit(p['text'])})" for p in data['passages']))
        out.append('on conflict (id) do nothing;\n')
    out.append('insert into diagnostic_questions')
    out.append('  (test_code, position, skill, level, stem, passage_id, options, correct_index, explanation, is_active)')
    out.append('values')
    rows = []
    for q in sorted(data['questions'], key=lambda x: x['position']):
        passage = _lit(q['passage_id']) + '::uuid' if q.get('passage_id') else 'null'
        options = _lit(json.dumps(q['options'], ensure_ascii=False))
        rows.append(f"  ('utbk', {q['position']}, {_lit(q['skill'])}, null, {_lit(q['stem'])}, {passage}, "
                    f"{options}, {q['correct_index']}, {_lit(q['explanation'])}, false)")
    out.append(',\n'.join(rows))
    out.append('on conflict (test_code, position) do nothing;\n')
    out.append('-- Aturan pita -> paket. package_id diisi lewat nama paket di katalog; null bila tidak ditemukan.')
    out.append('insert into diagnostic_rules (test_code, level, package_id, reason) values')
    out.append("  ('utbk', 'UTBK_RENDAH', null, 'Kamu masih perlu membangun dasar di beberapa subtes, jadi paket dengan banyak sesi memberi ruang latihan yang cukup.'),")
    out.append("  ('utbk', 'UTBK_SEDANG', null, 'Dasarmu sudah cukup, tinggal diperdalam dan dilatih dengan soal bertahap, cocok dengan paket sesi menengah.'),")
    out.append("  ('utbk', 'UTBK_TINGGI', null, 'Kemampuanmu sudah kuat, tinggal dipoles dan dilatih strategi, cocok dengan paket singkat.')")
    out.append('on conflict (test_code, level) do nothing;\n')
    for level, pattern in (('UTBK_RENDAH', '%SNBT%SKS'), ('UTBK_SEDANG', '%SNBT%Juara'), ('UTBK_TINGGI', '%SNBT%Satset')):
        out.append('update diagnostic_rules set package_id = (')
        out.append(f"  select id from packages where package_name ilike {_lit(pattern)} order by package_name limit 1")
        out.append(f") where test_code = 'utbk' and level = '{level}' and package_id is null;")
    return '\n'.join(out) + '\n'


def main():
    with open(SOURCE, encoding='utf-8') as fh:
        data = json.load(fh)
    problems = validate(data)
    if problems:
        print('Validasi gagal:', file=sys.stderr)
        for p in problems:
            print(f'  - {p}', file=sys.stderr)
        return 1
    with open(OUTPUT, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(generate_sql(data))
    print(f'OK: {OUTPUT}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
