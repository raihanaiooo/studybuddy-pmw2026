import type { ReactNode } from 'react';

export function PublicLayout({ children }: { children: ReactNode }) {
  // Cek apakah URL punya parameter ?layout=false
  const isPreview = new URLSearchParams(window.location.search).get('layout') === 'false';

  // Kalau preview, jangan render layout wrapper, cukup children-nya aja
  if (isPreview) return <>{children}</>;

  return (
    <div className="min-h-screen flex flex-col" style={{ background: 'var(--bg)', color: 'var(--ink)' }}>
      {children}
    </div>
  );
}