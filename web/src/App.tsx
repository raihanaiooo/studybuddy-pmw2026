import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AdminLayout } from './components/layout/AdminLayout';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route
          element={
            <ProtectedRoute>
              <AdminLayout />
            </ProtectedRoute>
          }
        >
          <Route path="/dashboard" element={<DashboardPage />} />

          {/* Placeholder untuk fase berikutnya */}
          <Route
            path="/tutors"
            element={<div className="text-[#6B7280]">Halaman Verifikasi Tutor (coming soon)</div>}
          />
          <Route
            path="/bookings"
            element={<div className="text-[#6B7280]">Halaman Bookings (coming soon)</div>}
          />
          <Route
            path="/payments"
            element={<div className="text-[#6B7280]">Halaman Transaksi (coming soon)</div>}
          />
          <Route
            path="/reschedules"
            element={<div className="text-[#6B7280]">Halaman Reschedule (coming soon)</div>}
          />
          <Route
            path="/complaints"
            element={<div className="text-[#6B7280]">Halaman Komplain (coming soon)</div>}
          />
          <Route
            path="/payroll"
            element={<div className="text-[#6B7280]">Halaman Payroll (coming soon)</div>}
          />
          <Route
            path="/packages"
            element={<div className="text-[#6B7280]">Halaman Paket & Token (coming soon)</div>}
          />
        </Route>

        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;