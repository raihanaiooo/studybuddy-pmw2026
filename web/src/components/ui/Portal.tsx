import type { ReactNode } from 'react';
import { createPortal } from 'react-dom';

/** Memasang isi langsung di body: lapisan penuh layar (modal) tidak terjebak di kontainer halaman yang beranimasi. */
export function Portal({ children }: { children: ReactNode }) {
  return createPortal(children, document.body);
}
