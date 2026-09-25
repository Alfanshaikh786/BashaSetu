import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Sparkles, Languages, Mic, ScanText, BookOpen } from 'lucide-react';

export const HeroSection: React.FC = () => {
  return (
    <section className="relative min-h-[75vh] lg:min-h-[80vh] w-full bg-[#F9F6F0] pt-6 pb-12 sm:pt-20 sm:pb-20 lg:pt-24 lg:pb-28 overflow-hidden flex items-center justify-center">
      
      {/* Soft Botanical Leafy Motifs (Top-Right & Bottom-Left) */}
      <div className="absolute -top-6 right-0 w-64 h-64 sm:w-80 sm:h-80 pointer-events-none opacity-40 select-none -z-10">
        <svg viewBox="0 0 200 200" className="w-full h-full">
          <path d="M 120 20 Q 150 60, 190 80 Q 150 100, 110 90 Q 130 50, 120 20 Z" fill="#8ca68c" opacity="0.6" />
          <path d="M 140 10 Q 170 40, 200 50 Q 175 75, 140 60 Q 150 30, 140 10 Z" fill="#238B45" opacity="0.35" />
          <path d="M 90 40 Q 130 65, 160 110 Q 120 115, 95 90 Q 85 60, 90 40 Z" fill="#9db69d" opacity="0.5" />
          <path d="M 70 80 Q 110 90, 130 140 Q 95 140, 75 120 Z" fill="#7a9a7a" opacity="0.5" />
          <circle cx="160" cy="140" r="3" fill="#238B45" opacity="0.4" />
          <circle cx="175" cy="125" r="2" fill="#238B45" opacity="0.4" />
        </svg>
      </div>

      <div className="absolute bottom-0 -left-6 w-64 h-64 sm:w-80 sm:h-80 pointer-events-none opacity-45 select-none -z-10">
        <svg viewBox="0 0 200 200" className="w-full h-full">
          <path d="M 80 180 Q 50 140, 10 120 Q 50 100, 90 110 Q 70 150, 80 180 Z" fill="#8ca68c" opacity="0.6" />
          <path d="M 60 190 Q 30 160, 0 150 Q 25 125, 60 140 Q 50 170, 60 190 Z" fill="#238B45" opacity="0.35" />
          <path d="M 110 160 Q 70 135, 40 90 Q 80 85, 105 110 Q 115 140, 110 160 Z" fill="#9db69d" opacity="0.5" />
          <path d="M 130 120 Q 90 110, 70 60 Q 105 60, 125 80 Z" fill="#7a9a7a" opacity="0.5" />
          <circle cx="40" cy="60" r="3" fill="#238B45" opacity="0.4" />
          <circle cx="25" cy="75" r="2" fill="#238B45" opacity="0.4" />
        </svg>
      </div>

      <div className="max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 relative z-10">
        <div className="flex flex-col space-y-5 sm:space-y-8 max-w-2xl lg:max-w-3xl text-left items-start">
          
          {/* Top Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#EAF5EA] border border-[#D5E8D5] text-[#238B45] text-xs sm:text-sm font-semibold shadow-2xs">
            <Sparkles className="w-4 h-4 text-[#238B45]" />
            <span>Offline-First Multidirectional Tribal Translation</span>
          </div>

          {/* Main Heading */}
          <h1 className="text-3xl sm:text-5xl md:text-6xl xl:text-7xl font-bold leading-[1.15] sm:leading-[1.12] tracking-tight text-[#17212B]" style={{ fontFamily: "'Domine', Georgia, serif" }}>
            Translate{' '}
            <span className="text-[#238B45]">
              Anything
            </span>
            <br />
            Instantly with AI
          </h1>

          {/* Subtitle */}
          <p className="max-w-xl text-sm sm:text-lg md:text-xl text-[#667085] font-normal leading-relaxed font-sans">
            Type, speak, or scan. Seamless linguistic bridge for tribal languages with verified on-device offline translation and zero network dependency.
          </p>

          {/* Action Button */}
          <div className="pt-1 w-full sm:w-auto">
            <Link
              to="/features/text-to-text"
              className="bg-[#238B45] hover:bg-[#176B3A] text-white px-7 sm:px-8 py-3.5 text-sm sm:text-base font-semibold rounded-[14px] inline-flex items-center gap-2.5 shadow-xs transition-all duration-200 group w-full sm:w-auto justify-center cursor-pointer active:scale-98"
            >
              <span>Try Translation Now</span>
              <ArrowRight className="w-4 h-4 transition-transform duration-200 group-hover:translate-x-1" />
            </Link>
          </div>

          {/* Mobile Native App Quick Tools Grid (md:hidden) */}
          <div className="md:hidden w-full pt-2">
            <div className="flex items-center justify-between mb-2.5">
              <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                Quick App Launchpad
              </span>
              <span className="text-[10px] font-semibold text-[#238B45] bg-[#EAF5EA] px-2 py-0.5 rounded-full border border-[#D5E8D5]">
                Tap to Open
              </span>
            </div>
            
            <div className="grid grid-cols-2 gap-2.5">
              {/* Text Translation */}
              <Link
                to="/features/text-to-text"
                className="p-3 bg-white rounded-2xl border border-[#D5E8D5] shadow-2xs hover:shadow-xs flex flex-col gap-2 active:scale-95 transition"
              >
                <div className="w-9 h-9 rounded-xl bg-[#EAF5EA] text-[#238B45] flex items-center justify-center">
                  <Languages className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-xs font-bold text-slate-800">Text Translate</h3>
                  <p className="text-[10px] text-slate-500 leading-tight mt-0.5">6,780 SQLite WASM</p>
                </div>
              </Link>

              {/* Voice Input */}
              <Link
                to="/features/speech-to-text"
                className="p-3 bg-white rounded-2xl border border-[#D5E8D5] shadow-2xs hover:shadow-xs flex flex-col gap-2 active:scale-95 transition"
              >
                <div className="w-9 h-9 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                  <Mic className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-xs font-bold text-slate-800">Voice Input</h3>
                  <p className="text-[10px] text-slate-500 leading-tight mt-0.5">Live speech recognition</p>
                </div>
              </Link>

              {/* Camera OCR */}
              <Link
                to="/features/ocr"
                className="p-3 bg-white rounded-2xl border border-[#D5E8D5] shadow-2xs hover:shadow-xs flex flex-col gap-2 active:scale-95 transition"
              >
                <div className="w-9 h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
                  <ScanText className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-xs font-bold text-slate-800">Camera OCR</h3>
                  <p className="text-[10px] text-slate-500 leading-tight mt-0.5">Scan tribal scripts</p>
                </div>
              </Link>

              {/* Tribal Lexicon */}
              <Link
                to="/resources/dictionary"
                className="p-3 bg-white rounded-2xl border border-[#D5E8D5] shadow-2xs hover:shadow-xs flex flex-col gap-2 active:scale-95 transition"
              >
                <div className="w-9 h-9 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
                  <BookOpen className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-xs font-bold text-slate-800">Dictionary</h3>
                  <p className="text-[10px] text-slate-500 leading-tight mt-0.5">6,780+ curated lexicon</p>
                </div>
              </Link>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
};

export default HeroSection;
