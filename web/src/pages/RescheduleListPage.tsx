import { useEffect, useState } from 'react';
import {
  BarChart3,
  Clock,
  CheckCircle2,
  XCircle,
  Search,
  LayoutGrid,
  List,
  CalendarClock,
  Eye,
  Loader2,
  AlertCircle,
  X,
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useReschedules } from '../hooks/useReschedules';
import { RescheduleCard } from '../components/reschedule/RescheduleCard';
import { StatCard } from '../components/ui/StatCard';
import { fetchRescheduleStats } from '../lib/api/reschedules';
import type { RescheduleStatus, RescheduleStats } from '../types/reschedule';

type FilterStatus = RescheduleStatus | 'all';
type ViewMode = 'grid' | 'table';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'menunggu_admin', label: 'Menunggu' },
  { key: 'disetujui', label: 'Disetujui' },
  { key: 'ditolak', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

const renderBadge = (status: RescheduleStatus) => {
  if (status === 'menunggu_admin')
    return <span className="badge b-pending"><i />Menunggu</span>;
  if (status === 'disetujui')
    return <span className="badge b-done"><i />Disetujui</span>;
  return <span className="badge b-no"><i />Ditolak</span>;
};

const formatDateShort = (iso: string) =>
  new Date(iso).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
  });

const formatDateLong = (iso: string) =>
  new Date(iso).toLocaleDateString('id-ID', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  });

export function RescheduleListPage() {
  const { reschedules, filter, setFilter, search, setSearch, loading, error } =
    useReschedules();

  const [stats, setStats] = useState<RescheduleStats>({
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
  });
  const [viewMode, setViewMode] = useState<ViewMode>('table');
  const [loadingId, setLoadingId] = useState<string | null>(null);
  const [selectedData, setSelectedData] = useState<any>(null);
  const [, setRefetchKey] = useState(0);

  useEffect(() => {
    fetchRescheduleStats()
      .then(setStats)
      .catch((e) => console.error('Stats error', e));
  }, [reschedules.length]);

  async function handleAction(
    reschedule: any,
    status: 'disetujui' | 'ditolak'
  ) {
    let note: string | null = null;
    if (status === 'ditolak') {
      const input = prompt('Masukkan alasan penolakan reschedule:');
      if (input === null) return;
      note = input.trim() || null;
    }

    setLoadingId(reschedule.id);
    try {
      const { error: updErr } = await supabase
        .from('reschedules')
        .update({ status, admin_note: note })
        .eq('id', reschedule.id);
      if (updErr) throw updErr;

      if (status === 'disetujui' && reschedule.booking?.id) {
        const { error: bookErr } = await supabase
          .from('bookings')
          .update({ session_time: reschedule.new_session_time })
          .eq('id', reschedule.booking.id);
        if (bookErr) throw bookErr;
      }

      setSelectedData(null);
      // Trigger refetch (lihat catatan). Sementara pakai reload:
      setRefetchKey((k) => k + 1);
      window.location.reload();
    } catch (err: any) {
      alert('Gagal memproses: ' + (err?.message ?? err));
    } finally {
      setLoadingId(null);
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">
          Reschedule
        </h1>
        <p className="text-sm text-[var(--mute)] mt-1">
          Tinjau pengajuan reschedule dari Buddy & Tutor
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <StatCard
          label="Total"
          value={stats.total}
          icon={<BarChart3 size={20} />}
          color="blue"
        />
        <StatCard
          label="Menunggu"
          value={stats.pending}
          icon={<Clock size={20} />}
          color="yellow"
        />
        <StatCard
          label="Disetujui"
          value={stats.approved}
          icon={<CheckCircle2 size={20} />}
          color="green"
        />
        <StatCard
          label="Ditolak"
          value={stats.rejected}
          icon={<XCircle size={20} />}
          color="red"
        />
      </div>

      {/* Filters + view toggle */}
      <div className="card p-4 space-y-3">
        <div className="flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
          <div className="relative w-full sm:max-w-xs">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mute)] pointer-events-none"
              size={18}
            />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Cari alasan, pengaju, atau mapel..."
              className="inp pl-10"
            />
          </div>

          <div className="flex items-center gap-1 p-1 bg-[var(--soft)] rounded-xl self-start sm:self-auto">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              aria-pressed={viewMode === 'table'}
              className="seg flex items-center gap-1.5"
            >
              <List size={16} />
              Tabel
            </button>
            <button
              type="button"
              onClick={() => setViewMode('grid')}
              aria-pressed={viewMode === 'grid'}
              className="seg flex items-center gap-1.5"
            >
              <LayoutGrid size={16} />
              Grid
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              type="button"
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-xl text-sm font-bold transition-colors ${
                filter === f.key
                  ? 'bg-[var(--blue)] text-white'
                  : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Loading */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="bg-[#FEE2E2] border border-[#FCA5A5] text-[#991B1B] text-sm rounded-xl p-4 flex items-start gap-2">
          <AlertCircle size={18} className="shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {/* Empty */}
      {!loading && !error && reschedules.length === 0 && (
        <div className="card p-12 text-center">
          <CalendarClock size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada reschedule</p>
          <p className="text-sm text-[var(--mute)] mt-1">
            {search
              ? 'Coba kata kunci lain'
              : 'Belum ada reschedule dengan filter ini'}
          </p>
        </div>
      )}

      {/* Grid view (baru) */}
      {!loading && !error && reschedules.length > 0 && viewMode === 'grid' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {reschedules.map((r) => (
            <RescheduleCard key={r.id} reschedule={r} />
          ))}
        </div>
      )}

      {/* Table view (lama, styling baru) */}
      {!loading &&
        !error &&
        reschedules.length > 0 &&
        viewMode === 'table' && (
          <div className="card overflow-hidden">
            <div className="overflow-x-auto">
              <table>
                <thead>
                  <tr>
                    <th>Pengaju</th>
                    <th>Mapel</th>
                    <th>Jadwal Baru</th>
                    <th>Status</th>
                    <th className="text-right">Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {reschedules.map((r: any) => (
                    <tr key={r.id}>
                      <td className="font-bold text-[var(--ink)]">
                        {r.requester?.full_name || '-'}
                      </td>
                      <td className="text-[var(--mute)]">
                        {r.booking?.subject || '-'}
                      </td>
                      <td className="text-[var(--blue)] font-bold text-sm">
                        {formatDateShort(r.new_session_time)}
                      </td>
                      <td>{renderBadge(r.status)}</td>
                      <td className="text-right">
                        <div className="flex justify-end gap-2 items-center">
                          <button
                            type="button"
                            onClick={() => setSelectedData(r)}
                            className="btn !py-1 !px-2 text-[var(--mute)] border-transparent hover:bg-[var(--hov)]"
                            title="Lihat Detail"
                          >
                            <Eye size={16} />
                            Detail
                          </button>

                          {r.status === 'menunggu_admin' && (
                            <>
                              <button
                                type="button"
                                onClick={() => handleAction(r, 'disetujui')}
                                disabled={loadingId === r.id}
                                className="btn !py-1 !px-2 text-[#166534] border-transparent hover:bg-[#DCFCE7] disabled:opacity-50"
                                title="Setujui"
                              >
                                {loadingId === r.id ? (
                                  <Loader2
                                    size={16}
                                    className="animate-spin"
                                  />
                                ) : (
                                  <CheckCircle2 size={16} />
                                )}
                                Setujui
                              </button>
                              <button
                                type="button"
                                onClick={() => handleAction(r, 'ditolak')}
                                disabled={loadingId === r.id}
                                className="btn !py-1 !px-2 text-[#991B1B] border-transparent hover:bg-[#FEE2E2] disabled:opacity-50"
                                title="Tolak"
                              >
                                <XCircle size={16} />
                                Tolak
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

      {/* Modal Detail */}
      {selectedData && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-center justify-center p-4">
          <div className="card w-full max-w-lg p-6 relative">
            <button
              type="button"
              onClick={() => setSelectedData(null)}
              className="absolute top-4 right-4 p-1.5 rounded-lg text-[var(--mute)] hover:bg-[var(--hov)] hover:text-[var(--ink)]"
              aria-label="Tutup"
            >
              <X size={20} />
            </button>

            <h2 className="text-lg font-bold text-[var(--ink)] mb-4">
              Detail Reschedule
            </h2>

            <div className="space-y-4 mb-6">
              <div>
                <p className="text-xs text-[var(--mute)] mb-1">
                  Alasan Pengajuan
                </p>
                <p className="text-sm font-semibold text-[var(--ink)] bg-[var(--soft)] p-3 rounded-lg border border-[var(--line)]">
                  "{selectedData.reason || 'Tidak ada alasan'}"
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <p className="text-xs text-[var(--mute)] mb-1">Jadwal Lama</p>
                  <p className="text-sm font-semibold text-[var(--ink)]">
                    {formatDateLong(selectedData.original_session_time)}
                  </p>
                </div>
                <div>
                  <p className="text-xs text-[var(--mute)] mb-1">Jadwal Baru</p>
                  <p className="text-sm font-semibold text-[var(--blue)]">
                    {formatDateLong(selectedData.new_session_time)}
                  </p>
                </div>
              </div>
            </div>

            {selectedData.status === 'menunggu_admin' && (
              <div className="flex justify-end gap-2 pt-4 border-t border-[var(--line)]">
                <button
                  type="button"
                  onClick={() => handleAction(selectedData, 'ditolak')}
                  disabled={loadingId === selectedData.id}
                  className="btn text-[#991B1B] border-[#FCA5A5] hover:bg-[#FEE2E2] disabled:opacity-50"
                >
                  <XCircle size={16} />
                  Tolak
                </button>
                <button
                  type="button"
                  onClick={() => handleAction(selectedData, 'disetujui')}
                  disabled={loadingId === selectedData.id}
                  className="btn btn-p disabled:opacity-50"
                >
                  <CheckCircle2 size={16} />
                  Setujui Reschedule
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}