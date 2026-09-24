import { Link } from 'react-router-dom';

export function NotFoundPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA] p-4">
      <div className="text-center">
        <div className="text-7xl mb-4">🔍</div>
        <h1 className="text-3xl font-bold text-[#1A1F3C] mb-2">404</h1>
        <p className="text-[#6B7280] mb-6">
          Halaman yang kamu cari tidak ditemukan
        </p>
        <Link
          to="/dashboard"
          className="inline-block bg-[#1A5EAA] hover:bg-[#154A87] text-white font-semibold px-6 py-3 rounded-xl transition-colors"
        >
          Kembali ke Dashboard
        </Link>
      </div>
    </div>
  );
}