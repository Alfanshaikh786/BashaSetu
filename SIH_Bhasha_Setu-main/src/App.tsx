import React, { Suspense, lazy, Component, ErrorInfo } from 'react';
import { Routes, Route } from 'react-router-dom';
import { Navbar } from './components/layout/Navbar';
import { ScrollToTop } from './components/common/ScrollToTop';
import { PWAInstallPrompt } from './components/common/PWAInstallPrompt';

// Eager load HomePage for instantaneous initial landing render
import { HomePage } from './pages/HomePage';

/** Helper to retry dynamic chunk imports if a stale hash or transient network drop occurs */
function lazyWithRetry<T extends React.ComponentType<any>>(
  factory: () => Promise<{ default: T }>
): React.LazyExoticComponent<T> {
  return lazy(async () => {
    try {
      return await factory();
    } catch (error) {
      console.warn('Lazy chunk load failed, retrying once...', error);
      const hasReloaded = sessionStorage.getItem('chunk_load_reload');
      if (!hasReloaded) {
        sessionStorage.setItem('chunk_load_reload', 'true');
        window.location.reload();
      }
      throw error;
    }
  });
}

// Lazy load feature and resource routes with automatic retry to prevent blank screens
const TextToTextPage = lazyWithRetry(() => import('./pages/features/TextToTextPage').then(m => ({ default: m.TextToTextPage })));
const OCRPage = lazyWithRetry(() => import('./pages/features/OCRPage').then(m => ({ default: m.OCRPage })));
const SpeechToTextPage = lazyWithRetry(() => import('./pages/features/SpeechToTextPage').then(m => ({ default: m.SpeechToTextPage })));
const SpeechToSpeechPage = lazyWithRetry(() => import('./pages/features/SpeechToSpeechPage').then(m => ({ default: m.SpeechToSpeechPage })));
const TextToSpeechPage = lazyWithRetry(() => import('./pages/features/TextToSpeechPage').then(m => ({ default: m.TextToSpeechPage })));
const VideoSubtitlePage = lazyWithRetry(() => import('./pages/features/VideoSubtitlePage').then(m => ({ default: m.VideoSubtitlePage })));
const LearningStudioPage = lazyWithRetry(() => import('./pages/features/LearningStudioPage').then(m => ({ default: m.LearningStudioPage })));
const DictionaryPage = lazyWithRetry(() => import('./pages/resources/DictionaryPage').then(m => ({ default: m.DictionaryPage })));
const FieldModePage = lazyWithRetry(() => import('./pages/features/FieldModePage').then(m => ({ default: m.FieldModePage })));
const TeacherModePage = lazyWithRetry(() => import('./pages/features/TeacherModePage').then(m => ({ default: m.TeacherModePage })));
const EmergencyModePage = lazyWithRetry(() => import('./pages/features/EmergencyModePage').then(m => ({ default: m.EmergencyModePage })));
const AboutPage = lazyWithRetry(() => import('./pages/AboutPage').then(m => ({ default: m.AboutPage })));
const ContactPage = lazyWithRetry(() => import('./pages/ContactPage').then(m => ({ default: m.ContactPage })));
const VaaniStreamPage = lazyWithRetry(() => import('./pages/VaaniStreamPage').then(m => ({ default: m.VaaniStreamPage })));
const PrivacyPolicyPage = lazyWithRetry(() => import('./pages/PrivacyPolicyPage').then(m => ({ default: m.PrivacyPolicyPage })));
const LoginPage = lazyWithRetry(() => import('./pages/LoginPage').then(m => ({ default: m.LoginPage })));

interface ErrorBoundaryState {
  hasError: boolean;
}

class AppErrorBoundary extends Component<{ children: React.ReactNode }, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Bhasha Setu loading error caught by AppErrorBoundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex flex-col items-center justify-center p-6 text-center bg-[#F8FBF7]">
          <div className="max-w-md bg-white p-8 rounded-2xl border border-[#D5E8D5] shadow-lg space-y-4">
            <h2 className="text-xl font-bold text-[#17212B]">Unable to load application</h2>
            <p className="text-sm text-[#667085]">
              A network glitch or cached update prevented this page from loading properly.
            </p>
            <button
              onClick={() => {
                sessionStorage.removeItem('chunk_load_reload');
                window.location.reload();
              }}
              className="px-6 py-2.5 bg-[#238B45] text-white rounded-xl font-semibold hover:bg-[#1b6b35] transition cursor-pointer"
            >
              Refresh Application
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

const PageLoadingFallback: React.FC = () => (
  <div className="min-h-[60vh] flex flex-col items-center justify-center p-8 text-center" aria-live="polite">
    <div className="w-9 h-9 border-3 border-[#238B45] border-t-transparent rounded-full animate-spin mb-3" />
    <p className="text-sm font-semibold text-[#17212B]">Loading Bhasha Setu Module...</p>
    <p className="text-xs text-[#667085] mt-1">Zero Network Dependency • Offline Ready</p>
  </div>
);

/** Layout wrapper for all pages that use the standard floating top Navbar */
const WithNavbar: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="min-h-screen flex flex-col bg-[#F8FBF7] text-[#17212B]">
    <Navbar />
    <div className="flex-1 flex flex-col">
      {children}
    </div>
  </div>
);

export const App: React.FC = () => {
  React.useEffect(() => {
    // Clear chunk reload guard once app has successfully rendered
    sessionStorage.removeItem('chunk_load_reload');
  }, []);

  return (
    <AppErrorBoundary>
      <ScrollToTop />
      <PWAInstallPrompt />
      <Suspense fallback={<PageLoadingFallback />}>
        <Routes>

          {/* ── Home page: top floating navbar layout ── */}
          <Route
            path="/"
            element={
              <WithNavbar>
                <HomePage />
              </WithNavbar>
            }
          />
          <Route
            path="/home"
            element={
              <WithNavbar>
                <HomePage />
              </WithNavbar>
            }
          />

          {/* ── All other pages: standard top Navbar ── */}

          {/* Core Workflows */}
          <Route path="/field-mode" element={<WithNavbar><FieldModePage /></WithNavbar>} />
          <Route path="/teacher-mode" element={<WithNavbar><TeacherModePage /></WithNavbar>} />
          <Route path="/emergency-mode" element={<WithNavbar><EmergencyModePage /></WithNavbar>} />
          <Route path="/conversation" element={<WithNavbar><SpeechToSpeechPage /></WithNavbar>} />

          {/* Features */}
          <Route path="/features/text-to-text" element={<WithNavbar><TextToTextPage /></WithNavbar>} />
          <Route path="/features/ocr" element={<WithNavbar><OCRPage /></WithNavbar>} />
          <Route path="/features/speech-to-text" element={<WithNavbar><SpeechToTextPage /></WithNavbar>} />
          <Route path="/features/speech-to-speech" element={<WithNavbar><SpeechToSpeechPage /></WithNavbar>} />
          <Route path="/features/text-to-speech" element={<WithNavbar><TextToSpeechPage /></WithNavbar>} />
          <Route path="/features/video-subtitle" element={<WithNavbar><VideoSubtitlePage /></WithNavbar>} />
          <Route path="/features/learning-studio" element={<WithNavbar><LearningStudioPage /></WithNavbar>} />

          {/* Resources */}
          <Route path="/resources/learning-studio" element={<WithNavbar><LearningStudioPage /></WithNavbar>} />
          <Route path="/learning-studio" element={<WithNavbar><LearningStudioPage /></WithNavbar>} />
          <Route path="/resources/dictionary" element={<WithNavbar><DictionaryPage /></WithNavbar>} />

          {/* Info & Support */}
          <Route path="/about-us" element={<WithNavbar><AboutPage /></WithNavbar>} />
          <Route path="/contact-us" element={<WithNavbar><ContactPage /></WithNavbar>} />
          <Route path="/vaani-stream" element={<WithNavbar><VaaniStreamPage /></WithNavbar>} />
          <Route path="/privacy-policy" element={<WithNavbar><PrivacyPolicyPage /></WithNavbar>} />
          <Route path="/login" element={<WithNavbar><LoginPage /></WithNavbar>} />

          {/* Fallback */}
          <Route
            path="*"
            element={
              <WithNavbar>
                <HomePage />
              </WithNavbar>
            }
          />

        </Routes>
      </Suspense>
    </AppErrorBoundary>
  );
};

export default App;
