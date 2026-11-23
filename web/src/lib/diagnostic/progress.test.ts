import { describe, expect, it } from 'vitest';
import { answeredCount, firstUnansweredIndex, isComplete, pruneAnswers } from './progress';
import type { DiagnosticQuestion } from '../../types/diagnostic';

function q(id: string, position: number, optionCount = 4): DiagnosticQuestion {
  return {
    id,
    position,
    skill: 'grammar',
    level: 'A1',
    stem: `Soal ${position}`,
    passage: null,
    options: Array.from({ length: optionCount }, (_, i) => `opsi ${i}`),
  };
}

const questions = [q('a', 1), q('b', 2), q('c', 3)];

describe('answeredCount', () => {
  it('menghitung hanya jawaban untuk soal yang ada', () => {
    expect(answeredCount(questions, { a: 0, b: 2, zzz: 1 })).toBe(2);
  });
  it('nol bila belum ada jawaban', () => {
    expect(answeredCount(questions, {})).toBe(0);
  });
});

describe('isComplete', () => {
  it('benar hanya bila semua soal terjawab', () => {
    expect(isComplete(questions, { a: 0, b: 1 })).toBe(false);
    expect(isComplete(questions, { a: 0, b: 1, c: 3 })).toBe(true);
  });
  it('jawaban 0 dihitung terjawab', () => {
    expect(isComplete([q('a', 1)], { a: 0 })).toBe(true);
  });
  it('daftar soal kosong tidak pernah lengkap', () => {
    expect(isComplete([], {})).toBe(false);
  });
});

describe('firstUnansweredIndex', () => {
  it('mengembalikan indeks soal pertama yang belum dijawab', () => {
    expect(firstUnansweredIndex(questions, { a: 0, c: 1 })).toBe(1);
  });
  it('mengembalikan indeks terakhir bila semua terjawab', () => {
    expect(firstUnansweredIndex(questions, { a: 0, b: 0, c: 0 })).toBe(2);
  });
});

describe('pruneAnswers (draft usang)', () => {
  it('membuang jawaban untuk soal yang tidak ada lagi atau indeks di luar jumlah opsi', () => {
    const qs = [q('a', 1, 4), q('b', 2, 2)];
    expect(pruneAnswers(qs, { a: 3, b: 5, hilang: 0 })).toEqual({ a: 3 });
  });
});
