import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AdminLayout } from './components/layout/AdminLayout';
import { TutorListPage } from './pages/TutorListPage';
import { TutorDetailPage } from './pages/TutorDetailPage';
import { BookingListPage } from './pages/BookingListPage';
import { BookingDetailPage } from './pages/BookingDetailPage';
import { PaymentListPage } from './pages/PaymentListPage';
import { PaymentDetailPage } from './pages/PaymentDetailPage';
import { ComplaintListPage } from './pages/ComplaintListPage';
import { ComplaintDetailPage } from './pages/ComplaintDetailPage';
import { RescheduleListPage } from './pages/RescheduleListPage';
import { RescheduleDetailPage } from './pages/RescheduleDetailPage';
import { PayrollListPage } from './pages/PayrollListPage';
import { PayrollDetailPage } from './pages/PayrollDetailPage';

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
            element={<TutorListPage />}
          />
          <Route path="/tutors/:id" element={<TutorDetailPage />} />
          <Route path="/bookings" element={<BookingListPage />} />
          <Route path="/bookings/:id" element={<BookingDetailPage />} />
          <Route path="/payments" element={<PaymentListPage />} />
          <Route path="/payments/:id" element={<PaymentDetailPage />} />
          <Route path="/reschedules" element={<RescheduleListPage />} />
          <Route path="/reschedules/:id" element={<RescheduleDetailPage />} />
          <Route path="/complaints" element={<ComplaintListPage />} />
          <Route path="/complaints/:id" element={<ComplaintDetailPage />} />
          <Route path="/payroll" element={<PayrollListPage />} />
          <Route path="/payroll/:id" element={<PayrollDetailPage />} />
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