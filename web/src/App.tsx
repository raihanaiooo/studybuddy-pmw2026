import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AdminLayout } from './components/layout/AdminLayout';
import { TutorListPage } from './pages/tutor/TutorListPage';
import { TutorDetailPage } from './pages/tutor/TutorDetailPage';
import { BookingListPage } from './pages/booking/BookingListPage';
import { BookingDetailPage } from './pages/booking/BookingDetailPage';
import { PaymentListPage } from './pages/payment/PaymentListPage';
import { PaymentDetailPage } from './pages/payment/PaymentDetailPage';
import { ComplaintListPage } from './pages/complaint/ComplaintListPage';
import { ComplaintDetailPage } from './pages/complaint/ComplaintDetailPage';
import { RescheduleListPage } from './pages/reschedule/RescheduleListPage';
import { RescheduleDetailPage } from './pages/reschedule/RescheduleDetailPage';
import { PayrollListPage } from './pages/payroll/PayrollListPage';
import { PayrollDetailPage } from './pages/payroll/PayrollDetailPage';
import { PackageListPage } from './pages/PackageListPage';
import { TokenListPage } from './pages/TokenListPage';
import { PerformancePage } from './pages/PerformancePage';
import { OrderListPage } from './pages/OrderListPage';
import { ContentManagementPage } from './pages/ContentManagementPage';
import { LandingPage } from './pages/LandingPage';
import { LandingPreviewPage } from './pages/LandingPagePreview';
import { GlobalUIManager } from './components/ui/GlobalUiManager';

function App() {
  return (
    <BrowserRouter>
          <GlobalUIManager />

      <Routes>
        {/* PUBLIC ROUTES (Tanpa Sidebar Admin) */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/preview" element={<LandingPreviewPage />} /> {/* <--- Pindah ke sini */}
        <Route path="/login" element={<LoginPage />} />

        {/* ADMIN ROUTES (Pakai Sidebar Admin) */}
        <Route
          element={
            <ProtectedRoute>
              <AdminLayout />
            </ProtectedRoute>
          }
        >
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/tutors" element={<TutorListPage />} />
          <Route path="/tutors/:id" element={<TutorDetailPage />} />
          <Route path="/performance" element={<PerformancePage />} />
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
          <Route path="/packages" element={<PackageListPage />} />
          <Route path="/tokens" element={<TokenListPage />} />
          <Route path="/orders" element={<OrderListPage />} />
          <Route path="/content" element={<ContentManagementPage />} />
        </Route>

        {/* Fallback */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;