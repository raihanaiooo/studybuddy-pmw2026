-- Seed: 24 soal English orisinal (6 per level A1-B2) + aturan level -> paket.
-- Semua soal ditulis sendiri oleh tim; acuan tingkat kesulitan: deskriptor CEFR Companion Volume (Council of Europe).
-- Soal masuk NONAKTIF. Aktifkan hanya setelah tutor English meninjau kunci dan tingkat kesulitan:
--   update diagnostic_questions set is_active = true where test_code = 'english';
-- Aman dijalankan ulang (on conflict do nothing).

insert into diagnostic_passages (id, text) values
  ('00000000-0000-0000-0000-00000000e001',
   E'Mia''s Café\nOpen: Monday to Saturday, 8 a.m. to 5 p.m.\nClosed on Sunday.\nToday''s special: chicken rice, Rp25,000.'),
  ('00000000-0000-0000-0000-00000000e002',
   E'Hi Dina, I can''t come to the study group today because I have a fever. I''ll go to the doctor this afternoon. Can you send me the notes from today''s class? Thanks! — Rafi'),
  ('00000000-0000-0000-0000-00000000e003',
   E'Last year, Sinta started tutoring junior high students on weekends. At first she felt nervous because she was afraid the students would not listen to her. However, after she began preparing short games for each lesson, the students became more active. Now she says tutoring has taught her to be patient, and she plans to continue even after she graduates.'),
  ('00000000-0000-0000-0000-00000000e004',
   E'Some people argue that online learning will eventually replace classrooms entirely. Supporters point to its flexibility and lower cost. Critics, however, note that many students struggle to stay motivated without face-to-face interaction, and that not every household has a reliable internet connection. A more balanced view is that online tools work best as a supplement to, rather than a substitute for, in-person teaching.')
on conflict (id) do nothing;

insert into diagnostic_questions
  (test_code, position, skill, level, stem, passage_id, options, correct_index, explanation, is_active)
values
-- ===== A1 =====
('english',  1, 'grammar',    'A1', 'She ___ a student.', null,
  '["am","is","are","be"]', 1,
  'Subjek tunggal orang ketiga (she) memakai "is".', false),
('english',  2, 'grammar',    'A1', 'I ___ breakfast at 7 o''clock every day.', null,
  '["has","having","am have","have"]', 3,
  'Subjek "I" memakai "have" untuk kebiasaan sehari-hari (present simple).', false),
('english',  3, 'vocabulary', 'A1', 'A person who teaches students at school is a ___.', null,
  '["teacher","doctor","driver","farmer"]', 0,
  'Orang yang mengajar murid di sekolah disebut teacher (guru).', false),
('english',  4, 'vocabulary', 'A1', 'We use a ___ to write on paper.', null,
  '["shoe","window","pen","chair"]', 2,
  'Pen (pulpen) dipakai untuk menulis di kertas.', false),
('english',  5, 'reading',    'A1', 'On which day is Mia''s Café closed?', '00000000-0000-0000-0000-00000000e001',
  '["Monday","Saturday","Sunday","Friday"]', 2,
  'Teks menyebut "Closed on Sunday".', false),
('english',  6, 'reading',    'A1', 'How much is today''s special?', '00000000-0000-0000-0000-00000000e001',
  '["Rp25,000","Rp15,000","Rp52,000","Rp250,000"]', 0,
  'Teks menyebut "chicken rice, Rp25,000".', false),
-- ===== A2 =====
('english',  7, 'grammar',    'A2', 'Yesterday we ___ to the library after school.', null,
  '["go","goes","going","went"]', 3,
  '"Yesterday" menandakan masa lampau, jadi memakai bentuk lampau "went".', false),
('english',  8, 'grammar',    'A2', 'My brother is taller ___ me.', null,
  '["that","than","then","as"]', 1,
  'Perbandingan dengan adjektiva + -er memakai "than".', false),
('english',  9, 'vocabulary', 'A2', 'I need to ___ my homework before I can play games.', null,
  '["borrow","finish","wear","catch"]', 1,
  'Kolokasi yang wajar: finish my homework (menyelesaikan PR).', false),
('english', 10, 'vocabulary', 'A2', 'The train was ___ because of the heavy rain, so we arrived late.', null,
  '["careful","generous","delayed","empty"]', 2,
  'Delayed berarti terlambat/tertunda, sesuai konteks "arrived late".', false),
('english', 11, 'reading',    'A2', 'Why can''t Rafi come to the study group?', '00000000-0000-0000-0000-00000000e002',
  '["He is sick.","He has an exam.","He lost his notes.","He is meeting Dina later."]', 0,
  'Rafi menulis bahwa ia demam ("I have a fever").', false),
('english', 12, 'reading',    'A2', 'What does Rafi want Dina to do?', '00000000-0000-0000-0000-00000000e002',
  '["Visit him at the doctor","Cancel the study group","Call him this afternoon","Send him the class notes"]', 3,
  'Rafi meminta Dina mengirim catatan kelas.', false),
-- ===== B1 =====
('english', 13, 'grammar',    'B1', 'If I ___ more time, I would join the English club.', null,
  '["have","will have","would have","had"]', 3,
  'Kalimat pengandaian (second conditional): if + past simple, would + verb.', false),
('english', 14, 'grammar',    'B1', 'The report ___ by the team before the deadline last week.', null,
  '["was finished","finished","has finishing","is finish"]', 0,
  'Kalimat pasif lampau: was/were + past participle.', false),
('english', 15, 'vocabulary', 'B1', 'She felt ___ about her exam results because she had studied very hard.', null,
  '["satisfy","satisfaction","satisfied","satisfying"]', 2,
  'Setelah "felt" dibutuhkan adjektiva perasaan: satisfied (puas).', false),
('english', 16, 'reading',    'B1', 'Why did Sinta feel nervous at first?', '00000000-0000-0000-0000-00000000e003',
  '["She did not know the lesson material.","She was afraid the students would not listen to her.","She was late for her first class.","She disliked teaching on weekends."]', 1,
  'Teks: "she was afraid the students would not listen to her".', false),
('english', 17, 'reading',    'B1', 'What happened after Sinta prepared short games?', '00000000-0000-0000-0000-00000000e003',
  '["The students became more active.","The students stopped coming.","Sinta stopped tutoring.","Sinta felt more nervous."]', 0,
  'Teks: "the students became more active".', false),
('english', 18, 'reading',    'B1', 'What can we conclude about Sinta?', '00000000-0000-0000-0000-00000000e003',
  '["She will stop tutoring soon.","She prefers working with adults.","She wants to keep tutoring after she graduates.","She thinks patience is unnecessary."]', 2,
  'Teks: "she plans to continue even after she graduates".', false),
-- ===== B2 =====
('english', 19, 'grammar',    'B2', 'Hardly ___ the presentation when the projector stopped working.', null,
  '["she had started","had she started","did she start","she started"]', 1,
  'Setelah "Hardly" di awal kalimat terjadi inversi: Hardly + had + subjek + past participle.', false),
('english', 20, 'grammar',    'B2', 'By the time the results are announced, the candidates ___ for almost two months.', null,
  '["will wait","are waiting","have waited","will have been waiting"]', 3,
  '"By the time" + durasi ke titik di masa depan memakai future perfect continuous.', false),
('english', 21, 'vocabulary', 'B2', 'The new policy has had a ___ effect on student attendance, raising it by nearly 20%.', null,
  '["sensitive","sufficient","significant","sympathetic"]', 2,
  'Significant effect berarti dampak yang berarti/besar, sesuai kenaikan hampir 20%.', false),
('english', 22, 'reading',    'B2', 'What is the author''s main position?', '00000000-0000-0000-0000-00000000e004',
  '["Online tools should support, not replace, in-person teaching.","Online learning should replace classrooms completely.","Classrooms are always better than online tools.","Internet access is no longer a problem."]', 0,
  'Penulis menyimpulkan online tools paling baik sebagai pelengkap, bukan pengganti.', false),
('english', 23, 'reading',    'B2', 'According to critics, which is a problem with fully online learning?', '00000000-0000-0000-0000-00000000e004',
  '["It is more expensive than classroom teaching.","It offers too little flexibility.","Teachers refuse to use technology.","Some students find it hard to stay motivated without face-to-face contact."]', 3,
  'Para pengkritik menyebut siswa sulit menjaga motivasi tanpa interaksi tatap muka.', false),
('english', 24, 'reading',    'B2', 'In the passage, the word "supplement" is closest in meaning to ___.', '00000000-0000-0000-0000-00000000e004',
  '["a replacement","an addition","a competitor","a limitation"]', 1,
  '"A supplement to, rather than a substitute for" berarti tambahan, bukan pengganti.', false)
on conflict (test_code, position) do nothing;

-- Aturan level -> paket. package_id sengaja kosong: Aul/Dhimas memetakan paket nyata.
insert into diagnostic_rules (test_code, level, package_id, reason) values
  ('english', 'PRE_A1', null, 'Kamu baru mulai belajar bahasa Inggris, jadi cocok dengan kelas dasar dengan pendamping yang sabar.'),
  ('english', 'A1',     null, 'Kamu sudah paham kalimat dan kosakata dasar, saatnya memperkuat tata bahasa sehari-hari.'),
  ('english', 'A2',     null, 'Kamu bisa memakai bahasa Inggris dalam situasi sederhana, lanjutkan dengan latihan berbicara dan membaca.'),
  ('english', 'B1',     null, 'Kamu sudah cukup lancar, tinggal mematangkan kalimat kompleks dan membaca teks yang lebih panjang.'),
  ('english', 'B2',     null, 'Kemampuanmu sudah tinggi, cocok untuk persiapan tes seperti TOEFL/IELTS dan presentasi akademik.')
on conflict (test_code, level) do nothing;
