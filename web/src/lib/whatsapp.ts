/** Nomor WhatsApp admin Study Buddy, format internasional tanpa tanda "+". */
export const ADMIN_WA_NUMBER = '628999303251';

interface OrderSummary {
  nama: string;
  mapel: string;
  jenjang: string;
}

export type TestOrigin = 'english' | 'utbk' | null;

const ORIGIN_NOTE: Record<'english' | 'utbk', string> = {
  english: ' Saya baru menyelesaikan tes level English di website dan ingin konsultasi paket yang disarankan.',
  utbk: ' Saya baru mengerjakan try out UTBK di website dan ingin konsultasi paket SNBT yang disarankan.',
};

/** Tautan wa.me ke admin dengan pesan template; `tes` menambahkan konteks tes asal order. */
export function buildAdminWaUrl(order: OrderSummary, tes: TestOrigin): string {
  const text =
    `Halo admin Study Buddy, saya ${order.nama} ingin les ${order.mapel} jenjang ${order.jenjang}.` +
    (tes ? ORIGIN_NOTE[tes] : '') +
    ' Mohon info langkah selanjutnya, ya. Terima kasih!';
  return `https://wa.me/${ADMIN_WA_NUMBER}?text=${encodeURIComponent(text)}`;
}
