/** Nomor WhatsApp admin Study Buddy, format internasional tanpa tanda "+". */
export const ADMIN_WA_NUMBER = '628999303251';

interface OrderSummary {
  nama: string;
  mapel: string;
  jenjang: string;
}

/** Tautan wa.me ke admin dengan pesan template; `dariTes` menambahkan konteks tes level English. */
export function buildAdminWaUrl(order: OrderSummary, dariTes: boolean): string {
  const text =
    `Halo admin Study Buddy, saya ${order.nama} ingin les ${order.mapel} jenjang ${order.jenjang}.` +
    (dariTes ? ' Saya baru menyelesaikan tes level English di website dan ingin konsultasi paket yang disarankan.' : '') +
    ' Mohon info langkah selanjutnya, ya. Terima kasih!';
  return `https://wa.me/${ADMIN_WA_NUMBER}?text=${encodeURIComponent(text)}`;
}
