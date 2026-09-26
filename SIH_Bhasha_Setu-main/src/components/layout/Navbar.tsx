import React, { useState, useEffect, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  Home,
  Languages, 
  ScanText, 
  Mic, 
  Volume2, 
  Video, 
  BookOpen, 
  BookMarked, 
  FileText, 
  Target, 
  Image as ImageIcon, 
  Mic2, 
  Lightbulb, 
  Radio, 
  ChevronDown, 
  ChevronUp, 
  Menu, 
  X, 
  ArrowRight, 
  Smartphone, 
  GraduationCap,
  Layers,
  Award,
  FileSpreadsheet,
  Wifi,
  WifiOff,
  Zap,
  CheckCircle2,
  Shield,
  Globe,
  Compass,
  AlertTriangle,
  ShieldCheck,
  Sparkles,
  Info
} from 'lucide-react';
import { BhashaSetuLogo } from '../common/BhashaSetuLogo';
import { LoginModal } from '../common/LoginModal';
import { getCurrentUser, logoutUser } from '../../services/authService';
import { getSimulatedOffline, setSimulatedOffline } from '../../services/translationService';

export const Navbar: React.FC = () => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activeDropdown, setActiveDropdown] = useState<string | null>(null);
  const [loginOpen, setLoginOpen] = useState(false);
  const [currentUser, setCurrentUser] = useState<{ email: string; name: string; role: string } | null>(null);
  const [offlineModalOpen, setOfflineModalOpen] = useState(false);
  const [isPhysicalOnline, setIsPhysicalOnline] = useState<boolean>(
    typeof navigator !== 'undefined' ? navigator.onLine : true
  );
  const [isOfflineMode, setIsOfflineMode] = useState<boolean>(() => {
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem('bhasha_offline_mode');
      if (stored !== null) {
        const val = stored === 'true';
        setSimulatedOffline(val);
        return val;
      }
      if (typeof navigator !== 'undefined' && !navigator.onLine) {
        setSimulatedOffline(true);
        return true;
      }
    }
    return getSimulatedOffline();
  });
  const [offlineActivating, setOfflineActivating] = useState(false);
  const [activeMobileSheet, setActiveMobileSheet] = useState<'features' | 'resources' | 'studio' | 'about' | null>(null);
  const location = useLocation();
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Sync auth state
  useEffect(() => {
    setCurrentUser(getCurrentUser());
  }, [location.pathname, loginOpen]);

  // Close dropdown on click outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setActiveDropdown(null);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Close mobile sheets & dropdowns on route change
  useEffect(() => {
    setMobileMenuOpen(false);
    setActiveMobileSheet(null);
    setActiveDropdown(null);
  }, [location.pathname]);

  // Listen for open-offline-modal events from footer/other components
  useEffect(() => {
    const handleOpenOffline = () => setOfflineModalOpen(true);
    window.addEventListener('open-offline-modal', handleOpenOffline);
    return () => window.removeEventListener('open-offline-modal', handleOpenOffline);
  }, []);

  // Listen for physical network status changes
  useEffect(() => {
    const handleOnline = () => {
      setIsPhysicalOnline(true);
      const stored = localStorage.getItem('bhasha_offline_mode');
      if (stored !== 'true') {
        setSimulatedOffline(false);
        setIsOfflineMode(false);
      }
    };
    const handleOffline = () => {
      setIsPhysicalOnline(false);
      setSimulatedOffline(true);
      setIsOfflineMode(true);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const toggleDropdown = (name: string) => {
    setActiveDropdown(activeDropdown === name ? null : name);
  };

  const handleOfflineToggle = () => {
    setOfflineActivating(true);
    setTimeout(() => {
      const next = !isOfflineMode;
      setSimulatedOffline(next);
      setIsOfflineMode(next);
      if (typeof window !== 'undefined') {
        localStorage.setItem('bhasha_offline_mode', String(next));
        window.dispatchEvent(new CustomEvent('offline-mode-change', { detail: { isOffline: next } }));
      }
      setOfflineActivating(false);
    }, 350);
  };

  return (
    <>
      {/* ─── 1. MOBILE NATIVE APP TOP BAR (md:hidden) ─── */}
      <header className="md:hidden sticky top-0 z-40 w-full bg-[#F9F6F0]/95 backdrop-blur-md border-b border-[#D5E8D5] px-4 py-2.5 shadow-2xs safe-top">
        <div className="flex items-center justify-between">
          {/* Logo & Tagline */}
          <Link to="/" className="flex items-center group transition-transform active:scale-95">
            <BhashaSetuLogo size="sm" />
          </Link>

          {/* Right Header Quick App Actions */}
          <div className="flex items-center gap-2">
            {/* Quick Offline Status Pill */}
            <button
              onClick={() => setOfflineModalOpen(true)}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border transition active:scale-95 cursor-pointer shadow-2xs ${
                isOfflineMode
                  ? 'bg-orange-50 text-orange-700 border-orange-200'
                  : 'bg-emerald-50 text-[#238B45] border-[#D5E8D5]'
              }`}
              title="Toggle or inspect Offline Mode"
            >
              {isOfflineMode ? (
                <>
                  <WifiOff className="w-3.5 h-3.5 text-orange-600 animate-pulse" />
                  <span className="text-[11px] font-bold">Offline</span>
                </>
              ) : (
                <>
                  <Wifi className="w-3.5 h-3.5 text-[#238B45]" />
                  <span className="text-[11px] font-bold">Online</span>
                </>
              )}
            </button>

            {/* User Profile Avatar / Sign In */}
            {currentUser ? (
              <button
                onClick={() => setActiveMobileSheet('about')}
                className="w-8 h-8 rounded-full bg-[#238B45] text-white flex items-center justify-center text-xs font-bold shadow-2xs active:scale-95 transition cursor-pointer"
                title="Account menu"
              >
                {currentUser.name ? currentUser.name[0].toUpperCase() : 'U'}
              </button>
            ) : (
              <button
                onClick={() => setLoginOpen(true)}
                className="text-xs font-bold text-[#238B45] border border-[#238B45] px-3 py-1 rounded-xl hover:bg-[#EAF5EA] transition active:scale-95 cursor-pointer"
              >
                Login
              </button>
            )}
          </div>
        </div>
      </header>

      {/* ─── 2. DESKTOP FLOATING NAVBAR (hidden on mobile, unchanged for desktop) ─── */}
      <header className="hidden md:block sticky top-3 z-50 w-[calc(100%-24px)] sm:w-[calc(100%-48px)] max-w-[1440px] mx-auto bg-[#F9F6F0]/95 backdrop-blur-md border border-[#D5E8D5] rounded-[20px] shadow-[0_4px_20px_-2px_rgba(35,139,69,0.06)] transition-all duration-200">
        <div ref={dropdownRef} className="w-full px-4 sm:px-6 lg:px-7">
          <div className="flex items-center justify-between h-[68px] sm:h-[72px]">
            
            {/* Left: Official Bhasha Setu Logo */}
            <Link to="/" className="flex items-center group transition-transform hover:opacity-95">
              <BhashaSetuLogo size="md" />
            </Link>

            {/* Center Desktop Navigation */}
            <nav className="hidden md:flex items-center gap-1 lg:gap-2">
              
              {/* Home */}
              <Link
                to="/"
                className={`font-medium transition-colors py-2 px-3.5 rounded-xl text-sm ${
                  location.pathname === '/'
                    ? 'text-[#238B45] bg-[#EAF5EA] font-semibold'
                    : 'text-[#17212B] hover:text-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                Home
              </Link>

              {/* 1. Features Dropdown */}
              <div className="relative">
                <button
                  onClick={() => toggleDropdown('features')}
                  className={`font-medium transition-all flex items-center gap-1.5 py-2 px-3.5 rounded-xl text-sm cursor-pointer ${
                    activeDropdown === 'features' || location.pathname.startsWith('/features')
                      ? 'text-[#238B45] bg-[#EAF5EA] font-semibold'
                      : 'text-[#17212B] hover:text-[#238B45] hover:bg-[#F4FAF3]'
                  }`}
                >
                  <span>Features</span>
                  {activeDropdown === 'features' ? (
                    <ChevronUp className="w-3.5 h-3.5 text-[#238B45]" />
                  ) : (
                    <ChevronDown className="w-3.5 h-3.5 text-[#667085]" />
                  )}
                </button>

                {/* Features Mega Panel */}
                {activeDropdown === 'features' && (
                  <div className="absolute top-full left-1/2 -translate-x-1/2 mt-3 w-[680px] bg-white rounded-3xl border border-[#D5E8D5] shadow-xl p-6 grid gap-4 animate-in fade-in slide-in-from-top-2 duration-150 z-50">
                    <div className="border-b border-[#D5E8D5] pb-2">
                      <span className="text-[11px] font-bold text-[#667085] uppercase tracking-widest">
                        FEATURES
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      {/* 1. Text to Text Translation */}
                      <Link
                        to="/features/text-to-text"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Languages className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Text to Text Translation</p>
                          <p className="text-xs text-[#667085] mt-0.5">Type in any tribal language</p>
                        </div>
                      </Link>

                      {/* 2. OCR */}
                      <Link
                        to="/features/ocr"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <ScanText className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">OCR</p>
                          <p className="text-xs text-[#667085] mt-0.5">Extract and translate from images</p>
                        </div>
                      </Link>

                      {/* 3. Speech to Text */}
                      <Link
                        to="/features/speech-to-text"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Mic className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Speech to Text</p>
                          <p className="text-xs text-[#667085] mt-0.5">Speak, get it transcribed</p>
                        </div>
                      </Link>

                      {/* 4. Voice to Voice */}
                      <Link
                        to="/features/speech-to-speech"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Radio className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Voice to Voice</p>
                          <p className="text-xs text-[#667085] mt-0.5">Two-way conversational dialogue</p>
                        </div>
                      </Link>

                      {/* 5. Text to Speech */}
                      <Link
                        to="/features/text-to-speech"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Volume2 className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Text to Speech</p>
                          <p className="text-xs text-[#667085] mt-0.5">Listen in native tribal accents</p>
                        </div>
                      </Link>

                      {/* 6. Video Subtitle */}
                      <Link
                        to="/features/video-subtitle"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-11 h-11 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Video className="w-5 h-5" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Video Subtitle</p>
                          <p className="text-xs text-[#667085] mt-0.5">Subtitles for videos & media</p>
                        </div>
                      </Link>
                    </div>
                  </div>
                )}
              </div>

              {/* 2. Resources Dropdown */}
              <div className="relative">
                <button
                  onClick={() => toggleDropdown('resources')}
                  className={`font-medium transition-all flex items-center gap-1.5 py-2 px-3.5 rounded-xl text-sm cursor-pointer ${
                    activeDropdown === 'resources' || location.pathname.startsWith('/resources')
                      ? 'text-[#238B45] bg-[#EAF5EA] font-semibold'
                      : 'text-[#17212B] hover:text-[#238B45] hover:bg-[#F4FAF3]'
                  }`}
                >
                  <span>Resources</span>
                  {activeDropdown === 'resources' ? (
                    <ChevronUp className="w-3.5 h-3.5 text-[#238B45]" />
                  ) : (
                    <ChevronDown className="w-3.5 h-3.5 text-[#667085]" />
                  )}
                </button>

                {/* Resources Mega Panel */}
                {activeDropdown === 'resources' && (
                  <div className="absolute top-full left-1/2 -translate-x-1/2 mt-3 w-[640px] bg-white rounded-3xl border border-[#D5E8D5] shadow-xl p-6 grid gap-4 animate-in fade-in slide-in-from-top-2 duration-150 z-50">
                    <div className="border-b border-[#D5E8D5] pb-2">
                      <span className="text-[11px] font-bold text-[#667085] uppercase tracking-widest">
                        RESOURCES
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      {/* Dictionary */}
                      <Link
                        to="/resources/dictionary"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-4 p-3.5 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-12 h-12 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <BookOpen className="w-6 h-6" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Dictionary</p>
                          <p className="text-xs text-[#667085] mt-0.5">Type in any tribal language</p>
                        </div>
                      </Link>

                      {/* Offline Mode Trigger */}
                      <button
                        onClick={() => { setOfflineModalOpen(true); setActiveDropdown(null); }}
                        className="flex items-center gap-4 p-3.5 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs w-full text-left cursor-pointer"
                      >
                        <div className="w-12 h-12 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition relative">
                          <Target className="w-6 h-6" />
                          {isOfflineMode && (
                            <span className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-orange-500 border-2 border-white animate-pulse" />
                          )}
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Offline Mode</p>
                          <p className="text-xs mt-0.5 flex items-center gap-1">
                            {isOfflineMode
                              ? <><span className="w-1.5 h-1.5 rounded-full bg-orange-500 animate-pulse inline-block" /> <span className="text-orange-600 font-semibold">Offline Mode Active</span></>
                              : <><span className="text-[#667085]">No internet? No problem</span></>}
                          </p>
                        </div>
                      </button>
                    </div>
                  </div>
                )}
              </div>

              {/* 3. Learning Studio Dropdown */}
              <div className="relative">
                <button
                  onClick={() => toggleDropdown('learning-studio')}
                  className={`font-medium transition-all flex items-center gap-1.5 py-2 px-3.5 rounded-xl text-sm cursor-pointer ${
                    activeDropdown === 'learning-studio' || location.pathname.includes('learning-studio')
                      ? 'text-[#238B45] bg-[#EAF5EA] font-semibold'
                      : 'text-[#17212B] hover:text-[#238B45] hover:bg-[#F4FAF3]'
                  }`}
                >
                  <GraduationCap className="w-4 h-4 text-[#238B45]" />
                  <span>Learning Studio</span>
                  {activeDropdown === 'learning-studio' ? (
                    <ChevronUp className="w-3.5 h-3.5 text-[#238B45]" />
                  ) : (
                    <ChevronDown className="w-3.5 h-3.5 text-[#667085]" />
                  )}
                </button>

                {/* Learning Studio Mega Panel */}
                {activeDropdown === 'learning-studio' && (
                  <div className="absolute top-full left-1/2 -translate-x-1/2 mt-3 w-[840px] bg-white rounded-3xl border border-[#D5E8D5] shadow-xl p-6 grid gap-4 animate-in fade-in slide-in-from-top-2 duration-150 z-50">
                    <div className="border-b border-[#D5E8D5] pb-2">
                      <span className="text-[11px] font-bold text-[#667085] uppercase tracking-widest">
                        LEARNING STUDIO
                      </span>
                    </div>

                    <div className="grid grid-cols-3 gap-4">
                      {/* Worksheets */}
                      <Link
                        to="/features/learning-studio?tab=worksheets"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3.5 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-12 h-12 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <FileSpreadsheet className="w-6 h-6" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Worksheets</p>
                          <p className="text-xs text-[#667085] mt-0.5">Solve live or export printable A4</p>
                        </div>
                      </Link>

                      {/* 3D Flashcards */}
                      <Link
                        to="/features/learning-studio?tab=flashcards"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3.5 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-12 h-12 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Layers className="w-6 h-6" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">3D Audio Flashcards</p>
                          <p className="text-xs text-[#667085] mt-0.5">Interactive cards with spoken audio</p>
                        </div>
                      </Link>

                      {/* Quiz and Assessment */}
                      <Link
                        to="/features/learning-studio?tab=assessment"
                        onClick={() => setActiveDropdown(null)}
                        className="flex items-center gap-3.5 p-3.5 rounded-2xl border border-[#D5E8D5]/70 hover:border-[#238B45] hover:bg-[#F4FAF3] transition group bg-white shadow-xs"
                      >
                        <div className="w-12 h-12 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 group-hover:bg-[#238B45] group-hover:text-white transition">
                          <Award className="w-6 h-6" />
                        </div>
                        <div>
                          <p className="text-sm font-bold text-[#17212B] group-hover:text-[#238B45]">Quiz and Assessment</p>
                          <p className="text-xs text-[#667085] mt-0.5">Language test & certificates</p>
                        </div>
                      </Link>
                    </div>
                  </div>
                )}
              </div>

              {/* 4. About */}
              <Link
                to="/about-us"
                className={`font-medium transition-colors py-2 px-3.5 rounded-xl text-sm ${
                  location.pathname === '/about-us'
                    ? 'text-[#238B45] bg-[#EAF5EA] font-semibold'
                    : 'text-[#17212B] hover:text-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                About
              </Link>
            </nav>

            {/* Right Action CTA Buttons */}
            <div className="hidden md:flex items-center gap-3">
              <button
                onClick={() => {
                  window.dispatchEvent(new CustomEvent('trigger-pwa-install'));
                }}
                className="bg-[#238B45] hover:bg-[#176B3A] text-white px-5 py-2.5 rounded-[12px] text-sm font-semibold inline-flex items-center gap-2 transition active:scale-98 shadow-xs cursor-pointer"
                title="Install Progressive Web App"
              >
                <span>Download App</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>

              {currentUser ? (
                <div className="flex items-center gap-2.5">
                  <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#EAF5EA] border border-[#D5E8D5]">
                    <div className="w-6 h-6 rounded-full bg-[#238B45] text-white flex items-center justify-center text-[10px] font-bold">
                      {currentUser.name ? currentUser.name[0].toUpperCase() : 'U'}
                    </div>
                    <span className="text-xs font-semibold text-[#17212B] max-w-[120px] truncate">
                      {currentUser.name || currentUser.email}
                    </span>
                  </div>
                  <button
                    onClick={() => {
                      logoutUser();
                      setCurrentUser(null);
                    }}
                    className="text-xs font-semibold text-[#667085] hover:text-red-600 px-2.5 py-1.5 rounded-lg hover:bg-slate-100 transition cursor-pointer"
                  >
                    Logout
                  </button>
                </div>
              ) : (
                <button
                  onClick={() => setLoginOpen(true)}
                  className="border border-[#238B45] text-[#238B45] hover:bg-[#EAF5EA] px-5 py-2 rounded-[12px] text-sm font-semibold transition active:scale-98 cursor-pointer"
                >
                  Login
                </button>
              )}
            </div>

          </div>
        </div>
      </header>

      {/* ─── 3. MOBILE NATIVE BOTTOM TAB BAR (md:hidden) ─── */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-[#F9F6F0]/95 backdrop-blur-lg border-t border-[#D5E8D5] shadow-[0_-4px_24px_rgba(0,0,0,0.06)] safe-bottom">
        <div className="grid grid-cols-5 h-[62px] items-center px-1">
          {/* Tab 1: Home */}
          <Link
            to="/"
            onClick={() => setActiveMobileSheet(null)}
            className={`flex flex-col items-center justify-center py-1 transition-all active:scale-90 ${
              (location.pathname === '/' || location.pathname === '/home') && activeMobileSheet === null
                ? 'text-[#238B45]'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <div className={`p-1 rounded-xl transition-all ${
              (location.pathname === '/' || location.pathname === '/home') && activeMobileSheet === null
                ? 'bg-[#EAF5EA]'
                : ''
            }`}>
              <Home className="w-5 h-5" />
            </div>
            <span className="text-[10px] font-semibold mt-0.5 tracking-tight">Home</span>
          </Link>

          {/* Tab 2: Features */}
          <button
            onClick={() => setActiveMobileSheet(activeMobileSheet === 'features' ? null : 'features')}
            className={`flex flex-col items-center justify-center py-1 transition-all active:scale-90 cursor-pointer ${
              activeMobileSheet === 'features' || (location.pathname.startsWith('/features') && !location.pathname.includes('learning-studio'))
                ? 'text-[#238B45]'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <div className={`p-1 rounded-xl transition-all ${
              activeMobileSheet === 'features' || (location.pathname.startsWith('/features') && !location.pathname.includes('learning-studio'))
                ? 'bg-[#EAF5EA]'
                : ''
            }`}>
              <Sparkles className="w-5 h-5" />
            </div>
            <span className="text-[10px] font-semibold mt-0.5 tracking-tight">Features</span>
          </button>

          {/* Tab 3: Resources */}
          <button
            onClick={() => setActiveMobileSheet(activeMobileSheet === 'resources' ? null : 'resources')}
            className={`flex flex-col items-center justify-center py-1 transition-all active:scale-90 cursor-pointer ${
              activeMobileSheet === 'resources' || location.pathname.startsWith('/resources') || location.pathname === '/teacher-mode'
                ? 'text-[#238B45]'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <div className={`p-1 rounded-xl transition-all ${
              activeMobileSheet === 'resources' || location.pathname.startsWith('/resources') || location.pathname === '/teacher-mode'
                ? 'bg-[#EAF5EA]'
                : ''
            }`}>
              <BookOpen className="w-5 h-5" />
            </div>
            <span className="text-[10px] font-semibold mt-0.5 tracking-tight">Resources</span>
          </button>

          {/* Tab 4: Learning Studio */}
          <button
            onClick={() => setActiveMobileSheet(activeMobileSheet === 'studio' ? null : 'studio')}
            className={`flex flex-col items-center justify-center py-1 transition-all active:scale-90 cursor-pointer ${
              activeMobileSheet === 'studio' || location.pathname.includes('learning-studio')
                ? 'text-[#238B45]'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <div className={`p-1 rounded-xl transition-all ${
              activeMobileSheet === 'studio' || location.pathname.includes('learning-studio')
                ? 'bg-[#EAF5EA]'
                : ''
            }`}>
              <GraduationCap className="w-5 h-5" />
            </div>
            <span className="text-[10px] font-semibold mt-0.5 tracking-tight">Studio</span>
          </button>

          {/* Tab 5: About */}
          <button
            onClick={() => setActiveMobileSheet(activeMobileSheet === 'about' ? null : 'about')}
            className={`flex flex-col items-center justify-center py-1 transition-all active:scale-90 cursor-pointer ${
              activeMobileSheet === 'about' || location.pathname === '/about-us'
                ? 'text-[#238B45]'
                : 'text-slate-500 hover:text-slate-800'
            }`}
          >
            <div className={`p-1 rounded-xl transition-all ${
              activeMobileSheet === 'about' || location.pathname === '/about-us'
                ? 'bg-[#EAF5EA]'
                : ''
            }`}>
              <Info className="w-5 h-5" />
            </div>
            <span className="text-[10px] font-semibold mt-0.5 tracking-tight">About</span>
          </button>
        </div>
      </nav>

      {/* ─── 4. MOBILE SLIDE-UP PANELS (Dedicated Per Section) ─── */}

      {/* 4a. FEATURES PANEL (ONLY Features Section) */}
      {activeMobileSheet === 'features' && (
        <div
          className="md:hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex flex-col justify-end animate-in fade-in duration-200"
          onClick={(e) => { if (e.target === e.currentTarget) setActiveMobileSheet(null); }}
        >
          <div className="bg-[#F9F6F0] rounded-t-[28px] border-t border-[#D5E8D5] max-h-[82vh] overflow-y-auto safe-bottom shadow-2xl p-5 animate-in slide-in-from-bottom duration-200">
            {/* Drag Handle */}
            <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto mb-4" />

            {/* Header */}
            <div className="flex items-center justify-between pb-3 border-b border-[#D5E8D5]/70">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center">
                  <Sparkles className="w-4 h-4" />
                </div>
                <div>
                  <span className="text-sm font-bold text-slate-900 block">Features & AI Tools</span>
                  <span className="text-[11px] text-slate-500">Multimodal translation & speech suite</span>
                </div>
              </div>
              <button
                onClick={() => setActiveMobileSheet(null)}
                className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* List of ONLY Features */}
            <div className="mt-3.5 grid grid-cols-1 gap-2">
              {/* 1. Text to Text */}
              <Link
                to="/features/text-to-text"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/text-to-text'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Languages className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Text to Text Translation</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-emerald-100 text-[#238B45]">AI Core</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Multidirectional Hindi, Santali, Mundari & English</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 2. Scan & OCR */}
              <Link
                to="/features/ocr"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/ocr'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <ScanText className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Scan & OCR Text</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-purple-100 text-purple-700">Vision</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Extract & translate from textbook charts & photos</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 3. Speech to Text */}
              <Link
                to="/features/speech-to-text"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/speech-to-text'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Mic className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Speech to Text (ASR)</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-700">Voice</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Live speech recognition & audio transcription</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 4. Voice to Voice */}
              <Link
                to="/features/speech-to-speech"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/speech-to-speech'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Radio className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Voice to Voice</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-amber-100 text-amber-800">Live Dual</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Two-way conversational dialogue bridge</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 5. Text to Speech */}
              <Link
                to="/features/text-to-speech"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/text-to-speech'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Volume2 className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Text to Speech</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-teal-100 text-teal-800">TTS Audio</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Listen in natural tribal accents with Roman phonetics</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 6. Video Subtitle */}
              <Link
                to="/features/video-subtitle"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/video-subtitle'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Video className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Video Subtitle</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-indigo-100 text-indigo-700">Media</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Multilingual subtitles for educational lessons & videos</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* 4b. RESOURCES PANEL (ONLY Resources Section) */}
      {activeMobileSheet === 'resources' && (
        <div
          className="md:hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex flex-col justify-end animate-in fade-in duration-200"
          onClick={(e) => { if (e.target === e.currentTarget) setActiveMobileSheet(null); }}
        >
          <div className="bg-[#F9F6F0] rounded-t-[28px] border-t border-[#D5E8D5] max-h-[82vh] overflow-y-auto safe-bottom shadow-2xl p-5 animate-in slide-in-from-bottom duration-200">
            {/* Drag Handle */}
            <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto mb-4" />

            {/* Header */}
            <div className="flex items-center justify-between pb-3 border-b border-[#D5E8D5]/70">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center">
                  <BookOpen className="w-4 h-4" />
                </div>
                <div>
                  <span className="text-sm font-bold text-slate-900 block">Resources & Lexicon</span>
                  <span className="text-[11px] text-slate-500">Dictionaries, offline packages & frontline aids</span>
                </div>
              </div>
              <button
                onClick={() => setActiveMobileSheet(null)}
                className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* List of ONLY Resources */}
            <div className="mt-3.5 grid grid-cols-1 gap-2">
              {/* 1. Tribal Dictionary */}
              <Link
                to="/resources/dictionary"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/resources/dictionary'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <BookOpen className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Tribal Dictionary</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-emerald-100 text-[#238B45]">6,780+ Words</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Multilingual verified vocabulary with native pronunciation</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 2. Offline Mode & Data Packages */}
              <button
                onClick={() => {
                  setActiveMobileSheet(null);
                  setOfflineModalOpen(true);
                }}
                className="flex items-center gap-3 p-3 rounded-2xl border border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3] transition text-left cursor-pointer shadow-2xs"
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0 relative">
                  <Target className="w-5 h-5" />
                  {isOfflineMode && (
                    <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-orange-500 border border-white animate-pulse" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Offline Mode & Data</p>
                    {isOfflineMode ? (
                      <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-orange-100 text-orange-700 animate-pulse">Active</span>
                    ) : (
                      <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-slate-100 text-slate-600">Offline Ready</span>
                    )}
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">
                    {isOfflineMode ? 'Running offline without internet' : 'Download packages for zero-network rural schools'}
                  </p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </button>

              {/* 3. Teacher Mode */}
              <Link
                to="/teacher-mode"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/teacher-mode'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <BookMarked className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Teacher Mode</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-800">Classroom</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Bilingual classroom drills for migrant teachers</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* 4c. LEARNING STUDIO PANEL (ONLY Learning Studio Section) */}
      {activeMobileSheet === 'studio' && (
        <div
          className="md:hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex flex-col justify-end animate-in fade-in duration-200"
          onClick={(e) => { if (e.target === e.currentTarget) setActiveMobileSheet(null); }}
        >
          <div className="bg-[#F9F6F0] rounded-t-[28px] border-t border-[#D5E8D5] max-h-[82vh] overflow-y-auto safe-bottom shadow-2xl p-5 animate-in slide-in-from-bottom duration-200">
            {/* Drag Handle */}
            <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto mb-4" />

            {/* Header */}
            <div className="flex items-center justify-between pb-3 border-b border-[#D5E8D5]/70">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center">
                  <GraduationCap className="w-4 h-4" />
                </div>
                <div>
                  <span className="text-sm font-bold text-slate-900 block">Learning Studio</span>
                  <span className="text-[11px] text-slate-500">Interactive drills, 3D flashcards & quizzes</span>
                </div>
              </div>
              <button
                onClick={() => setActiveMobileSheet(null)}
                className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* List of ONLY Learning Studio Tools */}
            <div className="mt-3.5 grid grid-cols-1 gap-2">
              {/* 1. Classroom Worksheets */}
              <Link
                to="/features/learning-studio?tab=worksheets"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/learning-studio' && location.search.includes('worksheets')
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <FileSpreadsheet className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Classroom Worksheets</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-emerald-100 text-[#238B45]">Printable A4</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Solve live or export A4 printable tribal exercises</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 2. 3D Audio Flashcards */}
              <Link
                to="/features/learning-studio?tab=flashcards"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/learning-studio' && location.search.includes('flashcards')
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Layers className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">3D Audio Flashcards</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-700">Audio Visual</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Interactive 3D cards with native speaker pronunciation</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 3. Quiz & Assessments */}
              <Link
                to="/features/learning-studio?tab=assessment"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/features/learning-studio' && location.search.includes('assessment')
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Award className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Quiz & Assessments</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-amber-100 text-amber-800">Certificates</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Language fluency test challenges & student certificates</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* 4d. ABOUT & ACCOUNT PANEL (ONLY About Section) */}
      {activeMobileSheet === 'about' && (
        <div
          className="md:hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex flex-col justify-end animate-in fade-in duration-200"
          onClick={(e) => { if (e.target === e.currentTarget) setActiveMobileSheet(null); }}
        >
          <div className="bg-[#F9F6F0] rounded-t-[28px] border-t border-[#D5E8D5] max-h-[82vh] overflow-y-auto safe-bottom shadow-2xl p-5 animate-in slide-in-from-bottom duration-200">
            {/* Drag Handle */}
            <div className="w-12 h-1.5 bg-slate-300 rounded-full mx-auto mb-4" />

            {/* Header */}
            <div className="flex items-center justify-between pb-3 border-b border-[#D5E8D5]/70">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center">
                  <Info className="w-4 h-4" />
                </div>
                <div>
                  <span className="text-sm font-bold text-slate-900 block">About & Community</span>
                  <span className="text-[11px] text-slate-500">Project vision, mobile app & account</span>
                </div>
              </div>
              <button
                onClick={() => setActiveMobileSheet(null)}
                className="p-1.5 rounded-full text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* User Profile Card */}
            {currentUser ? (
              <div className="mt-3.5 p-3 rounded-2xl bg-emerald-50/70 border border-emerald-200 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#238B45] text-white flex items-center justify-center font-bold text-sm">
                    {currentUser.name ? currentUser.name[0].toUpperCase() : 'U'}
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-900">{currentUser.name || 'User'}</p>
                    <p className="text-[11px] text-slate-500 truncate max-w-[170px]">{currentUser.email}</p>
                  </div>
                </div>
                <button
                  onClick={() => {
                    logoutUser();
                    setCurrentUser(null);
                  }}
                  className="text-xs font-semibold text-red-600 hover:bg-red-50 px-2.5 py-1.5 rounded-lg border border-red-200 transition cursor-pointer"
                >
                  Logout
                </button>
              </div>
            ) : (
              <div className="mt-3.5 p-3 rounded-2xl bg-white border border-slate-200 flex items-center justify-between shadow-2xs">
                <div>
                  <p className="text-xs font-bold text-slate-900">Sign in to sync your work</p>
                  <p className="text-[11px] text-slate-500">History, saved words & classroom drills</p>
                </div>
                <button
                  onClick={() => {
                    setActiveMobileSheet(null);
                    setLoginOpen(true);
                  }}
                  className="text-xs font-bold bg-[#238B45] text-white px-3.5 py-1.5 rounded-xl hover:bg-[#176B3A] transition cursor-pointer"
                >
                  Sign In
                </button>
              </div>
            )}

            {/* List of ONLY About Section Items */}
            <div className="mt-3 grid grid-cols-1 gap-2">
              {/* 1. About Us Full Page */}
              <Link
                to="/about-us"
                onClick={() => setActiveMobileSheet(null)}
                className={`flex items-center gap-3 p-3 rounded-2xl border transition ${
                  location.pathname === '/about-us'
                    ? 'border-[#238B45] bg-[#EAF5EA] shadow-xs'
                    : 'border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3]'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <ShieldCheck className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">About Bhasha Setu</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-emerald-100 text-[#238B45]">Mission</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Our vision to bridge tribal languages for migrant teachers</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </Link>

              {/* 2. Install App (PWA) */}
              <button
                onClick={() => {
                  setActiveMobileSheet(null);
                  window.dispatchEvent(new CustomEvent('trigger-pwa-install'));
                }}
                className="w-full flex items-center gap-3 p-3 rounded-2xl border border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3] transition text-left cursor-pointer shadow-2xs"
              >
                <div className="w-10 h-10 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Smartphone className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-xs font-bold text-slate-900">Install Mobile App (PWA)</p>
                    <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-md bg-blue-100 text-blue-700">Offline App</span>
                  </div>
                  <p className="text-[11px] text-slate-500 truncate">Add to home screen for native app experience</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-400 ml-auto flex-shrink-0" />
              </button>

              {/* 3. Return to Home */}
              <Link
                to="/"
                onClick={() => setActiveMobileSheet(null)}
                className="flex items-center gap-3 p-2.5 rounded-xl border border-slate-200 bg-white hover:border-[#238B45] hover:bg-[#F4FAF3] transition"
              >
                <div className="w-8 h-8 rounded-lg bg-[#EAF5EA] text-[#238B45] flex items-center justify-center flex-shrink-0">
                  <Home className="w-4 h-4" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold text-slate-800">Home Launchpad</p>
                  <p className="text-[10px] text-slate-500">Return to main dashboard & quick tools</p>
                </div>
                <ArrowRight className="w-3.5 h-3.5 text-slate-400 ml-auto" />
              </Link>
            </div>

            {/* Footer Badge */}
            <div className="mt-4 pt-3 border-t border-slate-200/80 text-center">
              <p className="text-[10px] font-medium text-slate-500">
                Bhasha Setu v2.4.0 • 100% Offline Ready • Ol Chiki & Devanagari Enabled
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Login Modal */}
      <LoginModal isOpen={loginOpen} onClose={() => setLoginOpen(false)} />

      {/* ─── Offline Mode Modal (White Theme Matching Website) ─── */}
      {offlineModalOpen && (
        <div
          className="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200"
          onClick={(e) => { if (e.target === e.currentTarget) setOfflineModalOpen(false); }}
        >
          <div className="relative w-full max-w-xl max-h-[92vh] flex flex-col bg-white rounded-3xl border border-slate-100 shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">

            {/* Animated top gradient accent bar */}
            <div className={`h-1.5 w-full transition-all duration-700 ${isOfflineMode ? 'bg-gradient-to-r from-orange-400 via-amber-500 to-orange-500' : 'bg-gradient-to-r from-[#249144] via-emerald-400 to-[#86c498]'}`} />

            {/* Close Button */}
            <button
              onClick={() => setOfflineModalOpen(false)}
              className="absolute top-4 right-4 p-2 text-slate-400 hover:text-slate-700 rounded-full hover:bg-slate-100 transition cursor-pointer z-10"
              aria-label="Close modal"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="p-6 sm:p-7 space-y-4 overflow-y-auto hide-scrollbar">

              {/* Header with animated WiFi icon */}
              <div className="flex items-center gap-3.5">
                <div className={`w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-500 shadow-xs ${isOfflineMode ? 'bg-orange-50 text-orange-600 border border-orange-200' : 'bg-emerald-50 text-[#249144] border border-emerald-200'}`}>
                  {offlineActivating ? (
                    <div className="w-7 h-7 border-2 border-current border-t-transparent rounded-full animate-spin" />
                  ) : isOfflineMode ? (
                    <WifiOff className="w-7 h-7 animate-pulse" />
                  ) : (
                    <Wifi className="w-7 h-7" />
                  )}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h2 className="text-xl font-bold text-slate-900 domine-bold tracking-tight">Offline Mode</h2>
                    <span className="text-[11px] font-semibold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                      100% On-Device
                    </span>
                  </div>
                  <p className="text-xs text-slate-500 font-sans mt-0.5">Zero-network architecture powered by in-browser SQLite WASM</p>
                </div>
              </div>

              {/* Live Status Bar */}
              <div className={`rounded-2xl p-4 border transition-all duration-500 shadow-xs ${isOfflineMode ? 'bg-orange-50/70 border-orange-200' : 'bg-[#f0fdf4] border-[#dcfce7]'}`}>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className={`w-2.5 h-2.5 rounded-full ${offlineActivating ? 'bg-yellow-500 animate-ping' : isOfflineMode ? 'bg-orange-500 animate-pulse' : 'bg-emerald-500 animate-pulse'}`} />
                    <div>
                      <p className="text-sm font-bold text-slate-900">
                        {offlineActivating
                          ? 'Switching pipeline...'
                          : isOfflineMode
                          ? '100% Offline Mode Active'
                          : !isPhysicalOnline
                          ? 'Device Disconnected (Offline SQLite Active)'
                          : 'Online & Fully Offline Capable'}
                      </p>
                      <p className="text-xs text-slate-500 font-sans mt-0.5">
                        {offlineActivating
                          ? 'Updating translation provider state...'
                          : isOfflineMode
                          ? 'Zero data transmitted • In-browser SQLite WASM & 6,780 parallel records'
                          : 'Local 6,780 SQLite DB queried first (<5ms) • Cloud neural fallback ready'}
                      </p>
                    </div>
                  </div>
                  {/* WiFi signal bars animation */}
                  <div className="flex items-end gap-1 h-6">
                    {[1, 2, 3, 4].map((bar) => (
                      <div
                        key={bar}
                        className={`w-1.5 rounded-xs transition-all duration-500 ${
                          isOfflineMode || !isPhysicalOnline
                            ? bar <= 1 ? 'bg-orange-500' : 'bg-slate-200'
                            : 'bg-[#249144]'
                        }`}
                        style={{ height: `${bar * 4 + 6}px`, transitionDelay: `${bar * 60}ms` }}
                      />
                    ))}
                  </div>
                </div>
              </div>

              {/* Big Toggle Switch */}
              <div className="flex items-center justify-between py-3.5 px-4 rounded-2xl bg-slate-50 border border-slate-200/80 shadow-2xs">
                <div className="flex items-center gap-3">
                  {isOfflineMode ? <WifiOff className="w-5 h-5 text-orange-500" /> : <Globe className="w-5 h-5 text-[#249144]" />}
                  <div>
                    <p className="text-sm font-bold text-slate-900">{isOfflineMode ? 'Strict Offline Mode' : 'Online / Hybrid Mode'}</p>
                    <p className="text-xs text-slate-500 font-sans">
                      {isOfflineMode ? 'Cloud disabled • Tap to allow online fallback' : 'Tap to simulate 100% zero-network offline mode'}
                    </p>
                  </div>
                </div>
                <button
                  onClick={handleOfflineToggle}
                  disabled={offlineActivating}
                  className={`relative w-14 h-7 rounded-full transition-all duration-300 cursor-pointer shadow-inner disabled:opacity-60 ${isOfflineMode ? 'bg-orange-500' : 'bg-[#249144]'}`}
                  aria-label="Toggle offline mode"
                >
                  <span className={`absolute top-1 w-5 h-5 rounded-full bg-white shadow-md transition-all duration-300 ${isOfflineMode ? 'left-8' : 'left-1'}`} />
                </button>
              </div>

              {/* Offline Features Grid (Accurate 100% On-Device Suite) */}
              <div>
                <div className="flex items-center justify-between mb-2.5">
                  <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider flex items-center gap-1.5">
                    <ShieldCheck className="w-3.5 h-3.5 text-[#249144]" /> Complete On-Device Suite
                  </p>
                  <span className="text-[11px] font-semibold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                    8 Modules 100% Offline
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-2.5">
                  {[
                    { icon: <Languages className="w-4 h-4" />, label: 'Text Translation', sub: '6,780 SQLite WASM records' },
                    { icon: <BookOpen className="w-4 h-4" />, label: 'Tribal Dictionary', sub: '6,780+ curated lexicon entries' },
                    { icon: <Volume2 className="w-4 h-4" />, label: 'Text to Speech', sub: 'On-device phonetic synthesis' },
                    { icon: <GraduationCap className="w-4 h-4" />, label: 'Learning Studio', sub: 'FLN flashcards & student drills' },
                    { icon: <FileSpreadsheet className="w-4 h-4" />, label: 'Classroom Worksheets', sub: 'Printable A4 PDF generator' },
                    { icon: <Target className="w-4 h-4" />, label: 'Emergency & Field Mode', sub: 'Frontline tribal phrasebook' },
                    { icon: <Sparkles className="w-4 h-4" />, label: 'Script Transliteration', sub: 'Ol Chiki ↔ Devanagari ↔ Latin' },
                    { icon: <Smartphone className="w-4 h-4" />, label: 'PWA Offline Shell', sub: 'Zero-data service worker' },
                  ].map((feat) => (
                    <div key={feat.label} className="flex items-start gap-2.5 p-2.5 rounded-xl bg-slate-50 border border-slate-200/70 hover:border-emerald-200 hover:bg-emerald-50/30 transition shadow-2xs">
                      <div className="w-7 h-7 rounded-lg bg-white border border-slate-200/90 text-[#249144] flex items-center justify-center flex-shrink-0 mt-0.5 shadow-2xs">
                        {feat.icon}
                      </div>
                      <div className="min-w-0">
                        <p className="text-xs font-bold text-slate-900 truncate">{feat.label}</p>
                        <p className="text-[10px] text-slate-500 font-sans mt-0.5 leading-tight">{feat.sub}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Bottom note */}
              <div className="flex items-start gap-2.5 text-xs text-slate-500 pt-2 border-t border-slate-100 font-sans">
                <CheckCircle2 className="w-4 h-4 text-[#249144] flex-shrink-0 mt-0.5" />
                <span>
                  <strong>Offline-First Architecture:</strong> Bhasha Setu stores all 6,780 tribal records, phonetic models, and classroom tools directly in your browser. No server connection is required for core features.
                </span>
              </div>

            </div>
          </div>
        </div>
      )}
    </>
  );
};
