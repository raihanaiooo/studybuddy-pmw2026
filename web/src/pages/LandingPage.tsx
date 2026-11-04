import { useEffect, useState } from 'react';
import { PublicLayout } from '../components/layout/PublicLayout';
import { Navbar } from '../components/landing/Navbar';
import { Hero } from '../components/landing/Hero';
import { TutorFinder } from '../components/landing/TutorFinder';
import { UniversityMarquee } from '../components/landing/UniversityMarquee';
import { Oprec } from '../components/landing/Oprec';
import { Testimonials } from '../components/landing/Testimonials';
import { OrderForm } from '../components/landing/OrderForm';
import { Footer } from '../components/landing/Footer';

export function LandingPage() {
  const [previewHero, setPreviewHero] = useState<any>(null);
  const [previewOprec, setPreviewOprec] = useState<any>(null);

  useEffect(() => {
    // Fungsi buat baca localStorage
    const checkPreview = () => {
      const saved = localStorage.getItem('preview_data');
      if (saved) {
        const parsed = JSON.parse(saved);
        if (parsed.type === 'hero') setPreviewHero(parsed.data);
        if (parsed.type === 'oprec') setPreviewOprec(parsed.data);
      }
    };

    checkPreview(); // Cek pertama kali
    const interval = setInterval(checkPreview, 500); // Cek tiap 0.5 detik (live update)
    return () => clearInterval(interval);
  }, []);

  return (
    <PublicLayout>
      <Navbar />
      <main>
        <Hero previewData={previewHero} />
        <TutorFinder />
        <UniversityMarquee />
        <Oprec previewData={previewOprec} />
        <Testimonials />
        <OrderForm />
      </main>
      <Footer />
    </PublicLayout>
  );
}