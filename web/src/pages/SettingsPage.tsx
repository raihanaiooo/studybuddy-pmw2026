import { PageHeader } from '../components/ui/PageHeader';
import { ServicesPanel } from '../components/settings/ServicesPanel';

export function SettingsPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Pengaturan" subtitle="Atur layanan, harga, dan hal lain yang dipakai tim." />
      <ServicesPanel />
    </div>
  );
}
