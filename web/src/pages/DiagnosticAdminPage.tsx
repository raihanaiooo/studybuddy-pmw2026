import { PageHeader } from '../components/ui/PageHeader';
import { EnglishStatsSection } from '../components/diagnostic/EnglishStatsSection';
import { UtbkStatsSection } from '../components/diagnostic/UtbkStatsSection';

/** Kegagalan satu bagian tidak menyembunyikan bagian lain: tiap bagian memuat datanya sendiri. */
export function DiagnosticAdminPage() {
  return (
    <div className="grid gap-10">
      <PageHeader
        title="Diagnostic"
        subtitle="Hasil tes yang dikerjakan calon murid dari landing page"
      />
      <EnglishStatsSection />
      <UtbkStatsSection />
    </div>
  );
}
