# Review 24 soal Diagnostic English

**Tanggal:** 23 Nov 2026
**Peninjau:** Claude (model AI), atas keputusan tim karena belum ada tim akademik.
**Penulis soal:** Claude (model yang sama). Peninjauan oleh penulis yang sama punya titik buta yang sama, jadi ini **bukan pengganti** tinjauan manusia. Lihat "Tindak lanjut".
**Berkas:** `supabase/seed/diagnostic_english.sql`

## Yang diperiksa
1. Kunci jawaban benar dan satu-satunya yang benar.
2. Pengecoh salah dengan jelas (tidak ada jawaban ganda yang bisa dibenarkan).
3. Level sesuai deskriptor CEFR yang dituju.
4. Soal reading bisa dijawab dari teks saja.
5. Sebaran kunci jawaban dan kemungkinan menebak.

## Hasil per soal

| # | Level | Keahlian | Kunci | Hasil | Catatan |
|---|---|---|---|---|---|
| 1 | A1 | grammar | is | OK | "she" + is |
| 2 | A1 | grammar | have | OK | satu-satunya bentuk yang tepat untuk "I" |
| 3 | A1 | vocab | teacher | OK | |
| 4 | A1 | vocab | pen | OK | |
| 5 | A1 | reading | Sunday | OK | tertulis "Closed on Sunday" |
| 6 | A1 | reading | Rp25,000 | OK | |
| 7 | A2 | grammar | went | OK | penanda "Yesterday" |
| 8 | A2 | grammar | than | OK | |
| 9 | A2 | vocab | finish | OK | kolokasi "finish homework" |
| 10 | A2 | vocab | delayed | OK | konteks "arrived late" |
| 11 | A2 | reading | He is sick. | OK | "I have a fever" |
| 12 | A2 | reading | Send him the class notes | OK | |
| 13 | B1 | grammar | had | OK | second conditional |
| 14 | B1 | grammar | was finished | OK | pasif lampau, ada "by the team" |
| 15 | B1 | vocab | satisfied | OK, catatan | bentuk kata (adjektiva perasaan). Sedikit di bawah B1 murni (A2/B1). |
| 16 | B1 | reading | afraid students would not listen | OK | |
| 17 | B1 | reading | students became more active | OK | |
| 18 | B1 | reading | wants to keep tutoring after graduating | OK | ada di teks, bukan inferensi dalam |
| 19 | B2 | grammar | had she started | OK | inversi setelah "Hardly" |
| 20 | B2 | grammar | will have been waiting | OK | "By the time ... almost two months" |
| 21 | B2 | vocab | significant | OK, catatan | pengecoh ("sympathetic", "sensitive") cukup mudah disingkirkan |
| 22 | B2 | reading | support, not replace | OK, catatan | gagasan utama; B2 sebenarnya menuntut inferensi lebih dalam |
| 23 | B2 | reading | hard to stay motivated | OK | |
| 24 | B2 | reading | an addition | OK | kata "supplement" dibandingkan dengan "substitute" di teks |

**Kesimpulan:** tidak ada kunci yang salah dan tidak ada soal dengan dua jawaban benar. Tiga catatan (15, 21, 22) soal kesulitan, bukan kebenaran, jadi soal tidak diubah.

## Sebaran dan peluang menebak
- Kunci jawaban: tiap indeks 0 sampai 3 dipakai tepat 6 kali (diuji otomatis).
- Peluang menebak acak lolos satu level (minimal 4 dari 6 benar) sekitar 3,8%. Lolos A1 sekadar menebak ±3,8%, sampai B2 sekitar 2 dalam sejuta. Tingkat ini wajar untuk tes penempatan tanpa taruhan.
- Soal reading berbagi teks (2 teks di A1/A2, 3 soal per teks di B1/B2), jadi kesalahan memahami satu teks mengena 2 sampai 3 soal sekaligus. Ini sengaja; dampaknya terbatas pada satu level.

## Keterbatasan
- Tingkat kesulitan sebenarnya belum diukur terhadap murid sungguhan.
- Kemungkinan salah kalibrasi level (misalnya soal 15, 21, 22) baru kelihatan dari data pemakaian.

## Tindak lanjut (disarankan)
1. Setelah soal aktif, setelah sekitar 30 tes, jalankan kueri persentase benar per soal (di bawah). Tanda curiga: persen benar di bawah 20% atau di atas 95%, atau urutan tidak menurun dari A1 ke B2.
2. Bila ada anggota tim yang nyaman berbahasa Inggris (mis. Rai atau Hilmy), minta membaca ke-24 soal ±15 menit dan menjawab sendiri; selisih dengan kunci patut dicek.
3. Bila nanti ada tutor English, minta satu tinjauan formal dan catat hasilnya di berkas ini.

```sql
select q.position, q.level, left(q.stem, 45) as soal, count(*) as dijawab,
       round(100.0 * count(*) filter (where (a.answers ->> q.id::text)::int = q.correct_index) / count(*)) as persen_benar
from public.diagnostic_questions q
join public.diagnostic_attempts a on a.test_code = q.test_code
where q.test_code = 'english'
group by q.position, q.level, q.stem
order by q.position;
```
