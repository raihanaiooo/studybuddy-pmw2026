import type { DiagnosticLevel } from '../../types/diagnostic';

export const LEVEL_INFO: Record<DiagnosticLevel, { title: string; can: string }> = {
  PRE_A1: {
    title: 'Pemula',
    can: 'Kamu baru mulai mengenal bahasa Inggris. Mulai dari kata dan kalimat paling dasar bersama pendamping.',
  },
  A1: {
    title: 'Dasar',
    can: 'Kamu bisa memahami dan memakai kalimat sederhana tentang diri sendiri dan hal sehari-hari.',
  },
  A2: {
    title: 'Pra-menengah',
    can: 'Kamu bisa berkomunikasi dalam situasi sederhana dan membaca pesan atau pengumuman singkat.',
  },
  B1: {
    title: 'Menengah',
    can: 'Kamu bisa mengikuti teks dan percakapan yang jelas tentang topik yang familier, dan menyampaikan pendapat.',
  },
  B2: {
    title: 'Menengah atas',
    can: 'Kamu bisa memahami teks yang lebih kompleks dan berargumen dengan cukup lancar dan akurat.',
  },
};
