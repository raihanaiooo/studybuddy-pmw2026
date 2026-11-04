import { useEffect, useState } from 'react';
import { useComplaints } from '../../hooks/useComplaints';
import { ComplaintCard } from '../../components/complaint/ComplaintCard';
import { StatCard } from '../../components/ui/StatCard';
import { fetchComplaintStats } from '../../lib/api/complaints';
import type { ComplaintStatus, ComplaintStats } from '../../types/complaint';
import { MessageSquare, Clock, Search as SearchIcon, CheckCircle, XCircle } from 'lucide-react';

type FilterStatus = ComplaintStatus | 'all';

const filters: { key: FilterStatus; label: string }[] = [
  { key: 'pending', label: 'Menunggu' },
  { key: 'in_review', label: 'Ditinjau' },
  { key: 'resolved', label: 'Selesai' },
  { key: 'rejected', label: 'Ditolak' },
  { key: 'all', label: 'Semua' },
];

export function ComplaintListPage() {
  const { complaints, filter, setFilter, search, setSearch, loading, error } = useComplaints();

  const [stats, setStats] = useState<ComplaintStats>({
    total: 0, pending: 0, in_review: 0, resolved: 0, rejected: 0,
  });

  useEffect(() => {
    fetchComplaintStats().then(setStats).catch((e) => console.error('Stats error', e));
  }, [complaints.length]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-[var(--ink)]">Komplain</h1>
        <p className="text-sm text-[var(--mute)] mt-1">Tindak lanjuti komplain dari Buddy & Tutor.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
        <StatCard label="Total" value={stats.total} icon={<MessageSquare size={20} strokeWidth={2.5} />} color="blue" />
        <StatCard label="Menunggu" value={stats.pending} icon={<Clock size={20} strokeWidth={2.5} />} color="yellow" />
        <StatCard label="Ditinjau" value={stats.in_review} icon={<SearchIcon size={20} strokeWidth={2.5} />} color="blue" />
        <StatCard label="Selesai" value={stats.resolved} icon={<CheckCircle size={20} strokeWidth={2.5} />} color="green" />
        <StatCard label="Ditolak" value={stats.rejected} icon={<XCircle size={20} strokeWidth={2.5} />} color="red" />
      </div>

      {/* Filters */}
      <div className="card p-4 space-y-3">
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Cari deskripsi, pelapor, atau mapel..."
          className="inp"
        />
        <div className="flex flex-wrap gap-2">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`px-4 py-2 rounded-lg text-sm font-bold transition-colors ${
                filter === f.key ? 'bg-[var(--blue)] text-white' : 'bg-[var(--soft)] text-[var(--mute)] hover:bg-[var(--hov)]'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      {loading && (
        <div className="flex justify-center py-20">
          <div className="w-10 h-10 border-4 border-[var(--blue)] border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {error && <div className="bg-red-50 border border-red-200 text-red-600 text-sm rounded-xl p-4">{error}</div>}

      {!loading && !error && complaints.length === 0 && (
        <div className="card p-12 text-center">
          <MessageSquare size={48} className="mx-auto text-[var(--mute)] mb-3" />
          <p className="font-bold text-[var(--ink)]">Tidak ada komplain</p>
          <p className="text-sm text-[var(--mute)] mt-1">{search ? 'Coba kata kunci lain' : 'Belum ada komplain dengan filter ini'}</p>
        </div>
      )}

      {!loading && !error && complaints.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {complaints.map((c) => <ComplaintCard key={c.id} complaint={c} />)}
        </div>
      )}
    </div>
  );
}