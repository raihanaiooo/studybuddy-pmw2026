import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { LEGACY_REDIRECTS } from './lib/navigation';
import { SettingsPage } from './pages/SettingsPage';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { NotFoundPage } from './pages/NotFoundPage';
import { ProtectedRoute } from './components/ProtectedRoute';
import { AdminLayout } from './components/layout/AdminLayout';
import { TutorListPage } from './pages/tutor/TutorListPage';
import { TutorDetailPage } from './pages/tutor/TutorDetailPage';
import { OrderListPage } from './pages/OrderListPage';
import { ContentManagementPage } from './pages/ContentManagementPage';
import { LandingPage } from './pages/LandingPage';
import { LandingPreviewPage } from './pages/LandingPagePreview';
import { DiagnosticTestPage } from './pages/DiagnosticTestPage';
import { DiagnosticAdminPage } from './pages/DiagnosticAdminPage';
import { UtbkTestPage } from './pages/UtbkTestPage';
import { TutorApplyPage } from './pages/TutorApplyPage';
import { GlobalUIManager } from './components/ui/GlobalUiManager';

function App() {
  return (
    <BrowserRouter>
          <GlobalUIManager />

      <Routes>
        {/* PUBLIC ROUTES (Tanpa Sidebar Admin) */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/preview" element={<LandingPreviewPage />} /> {/* <--- Pindah ke sini */}
        <Route path="/tes-english" element={<DiagnosticTestPage />} />
        <Route path="/tes-utbk" element={<UtbkTestPage />} />
        <Route path="/daftar-tutor" element={<TutorApplyPage />} />
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
          <Route path="/orders" element={<OrderListPage />} />
          <Route path="/pengaturan" element={<SettingsPage />} />
          {Object.entries(LEGACY_REDIRECTS).map(([from, to]) => (
            <Route key={from} path={from} element={<Navigate to={to} replace />} />
          ))}
          <Route path="/content" element={<ContentManagementPage />} />
          <Route path="/diagnostics" element={<DiagnosticAdminPage />} />
        </Route>

        {/* Fallback */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;