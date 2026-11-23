"""Uji validator seed UTBK. Jalankan: python -I -m unittest discover -s supabase/seed -p "test_*.py" """
import copy
import os
import sys
import unittest

# `python -I` tidak menaruh direktori ini di sys.path.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import build_utbk_seed as b  # noqa: E402


def make_valid():
    """24 soal sahih: pu 1-8, pk 9-16, lbi 17-24; kunci berputar 0..4."""
    questions = []
    for pos in range(1, 25):
        skill = 'pu' if pos <= 8 else 'pk' if pos <= 16 else 'lbi'
        correct = pos % 5
        options = [f'opsi {pos}-{i}' for i in range(5)]
        q = {
            'position': pos, 'skill': skill, 'stem': f'Soal {pos}', 'passage_id': None,
            'options': options, 'correct_index': correct, 'explanation': f'Karena {pos}.', 'verify': None,
        }
        if skill == 'pk':
            q['options'][correct] = '12'
            q['verify'] = 'str(Fraction(24, 2))'
        if skill == 'lbi':
            q['passage_id'] = 'p1'
        questions.append(q)
    return {'passages': [{'id': 'p1', 'text': 'Teks bacaan.'}], 'questions': questions}


class ValidateTest(unittest.TestCase):
    def violations(self, mutate):
        data = make_valid()
        mutate(data)
        return b.validate(data)

    def test_data_sahih_lolos(self):
        self.assertEqual(b.validate(make_valid()), [])

    def test_jumlah_soal_salah(self):
        v = self.violations(lambda d: d['questions'].pop())
        self.assertTrue(any('24 soal' in m for m in v), v)

    def test_subtes_tak_seimbang(self):
        def mutate(d):
            d['questions'][0]['skill'] = 'pk'
        v = self.violations(mutate)
        self.assertTrue(any('8 soal' in m for m in v), v)

    def test_opsi_kembar(self):
        def mutate(d):
            d['questions'][0]['options'][1] = d['questions'][0]['options'][2]
        v = self.violations(mutate)
        self.assertTrue(any('opsi kembar' in m for m in v), v)

    def test_opsi_bukan_lima(self):
        def mutate(d):
            d['questions'][0]['options'].pop()
        v = self.violations(mutate)
        self.assertTrue(any('5 opsi' in m for m in v), v)

    def test_correct_index_di_luar_rentang(self):
        def mutate(d):
            d['questions'][0]['correct_index'] = 5
        v = self.violations(mutate)
        self.assertTrue(any('correct_index' in m for m in v), v)

    def test_sebaran_kunci_timpang(self):
        def mutate(d):
            for q in d['questions']:
                if q['skill'] == 'pu':
                    q['correct_index'] = 0
        v = self.violations(mutate)
        self.assertTrue(any('sebaran kunci' in m for m in v), v)

    def test_pk_tanpa_verify(self):
        def mutate(d):
            d['questions'][8]['verify'] = None
        v = self.violations(mutate)
        self.assertTrue(any('verify' in m and 'wajib' in m for m in v), v)

    def test_verify_tidak_cocok_kunci(self):
        def mutate(d):
            d['questions'][8]['verify'] = 'str(Fraction(99, 3))'
        v = self.violations(mutate)
        self.assertTrue(any('tidak sama dengan kunci' in m for m in v), v)

    def test_verify_berbahaya_ditolak(self):
        def mutate(d):
            d['questions'][8]['verify'] = "__import__('os').getcwd()"
        v = self.violations(mutate)
        self.assertTrue(any('verify' in m and 'tidak diizinkan' in m for m in v), v)

    def test_verify_open_ditolak(self):
        def mutate(d):
            d['questions'][8]['verify'] = "open('x')"
        v = self.violations(mutate)
        self.assertTrue(any('verify' in m for m in v), v)

    def test_lbi_tanpa_passage(self):
        def mutate(d):
            d['questions'][16]['passage_id'] = None
        v = self.violations(mutate)
        self.assertTrue(any('passage' in m for m in v), v)

    def test_lbi_passage_tak_ada(self):
        def mutate(d):
            d['questions'][16]['passage_id'] = 'tidak-ada'
        v = self.violations(mutate)
        self.assertTrue(any('passage' in m for m in v), v)

    def test_penjelasan_kosong(self):
        def mutate(d):
            d['questions'][0]['explanation'] = '  '
        v = self.violations(mutate)
        self.assertTrue(any('penjelasan' in m for m in v), v)


class GenerateTest(unittest.TestCase):
    def test_sql_nonaktif_dan_aman_ulang(self):
        sql = b.generate_sql(make_valid())
        self.assertIn('on conflict', sql)
        self.assertIn("'utbk'", sql)
        self.assertNotIn('true)', sql.split('insert into diagnostic_questions')[1].split('on conflict')[0])
        for level in ('UTBK_RENDAH', 'UTBK_SEDANG', 'UTBK_TINGGI'):
            self.assertIn(level, sql)

    def test_kutip_di_teks_di_escape(self):
        data = make_valid()
        data['questions'][0]['stem'] = "Dina's soal"
        self.assertIn("Dina''s soal", b.generate_sql(copy.deepcopy(data)))


if __name__ == '__main__':
    unittest.main()
