import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Settings } from 'lucide-react';

interface AdditionalFeatureCardProps {
  title: string;
  tag: string;
  description: string;
  link: string;
  iconNode: React.ReactNode;
  iconBg: string;
}

const AdditionalFeatureCard: React.FC<AdditionalFeatureCardProps> = ({
  title,
  tag,
  description,
  link,
  iconNode,
  iconBg
}) => {
  return (
    <div className="bg-white rounded-[22px] border border-[#D5E8D5] shadow-[0_2px_12px_-2px_rgba(35,139,69,0.04)] hover:shadow-[0_8px_24px_-4px_rgba(35,139,69,0.1)] hover:border-[#238B45] transition-all duration-300 p-6 sm:p-8 flex flex-col sm:flex-row items-center gap-6 sm:gap-7 group">
      
      {/* Left Icon Container */}
      <div className="relative flex-shrink-0 w-28 h-28 sm:w-32 sm:h-32 flex items-center justify-center">
        {/* Rounded square container */}
        <div className={`w-24 h-24 rounded-2xl ${iconBg} flex items-center justify-center group-hover:scale-105 transition-transform duration-300 shadow-2xs`}>
          {iconNode}
        </div>

        {/* Botanical leaf sprigs on corners */}
        <div className="absolute -bottom-1 -left-1 w-9 h-9 pointer-events-none">
          <svg viewBox="0 0 35 35" className="w-full h-full">
            <path d="M 22 30 Q 10 20, 5 8 Q 18 12, 22 30" fill="#238B45" />
            <path d="M 25 27 Q 32 12, 18 4 Q 20 16, 25 27" fill="#8ca68c" />
          </svg>
        </div>

        <div className="absolute -top-1 -right-1 w-7 h-7 pointer-events-none">
          <svg viewBox="0 0 30 30" className="w-full h-full">
            <path d="M 8 22 Q 12 8, 25 5 Q 18 16, 8 22" fill="#238B45" />
          </svg>
        </div>

        {/* Accent dot */}
        <div className="absolute bottom-2 -right-1 w-2 h-2 rounded-full bg-[#238B45] opacity-40" />
      </div>

      {/* Right Content */}
      <div className="flex flex-col justify-between flex-1 text-center sm:text-left h-full">
        <div>
          <div className="flex items-center justify-center sm:justify-start gap-2.5 mb-2 flex-wrap">
            <h3 className="text-xl font-bold text-[#17212B] tracking-tight">
              {title}
            </h3>
            <span className="text-[10px] bg-[#EAF5EA] text-[#238B45] px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider border border-[#D5E8D5]">
              {tag}
            </span>
          </div>
          <p className="text-xs sm:text-sm text-[#667085] leading-relaxed font-sans">
            {description}
          </p>
        </div>

        <div className="mt-5">
          <Link
            to={link}
            className="bg-[#238B45] hover:bg-[#176B3A] text-white px-5 py-2.5 text-xs sm:text-sm font-semibold rounded-[12px] inline-flex items-center gap-2 shadow-xs transition-all duration-200 group-hover:shadow cursor-pointer active:scale-98"
          >
            <span>Launch Feature</span>
            <ArrowRight className="w-3.5 h-3.5 transition-transform duration-200 group-hover:translate-x-1" />
          </Link>
        </div>
      </div>

    </div>
  );
};

export const AdditionalFeaturesSection: React.FC = () => {
  return (
    <section id="additional-features" className="py-20 lg:py-28 px-4 sm:px-6 lg:px-8 bg-[#F8FBF7] border-t border-[#D5E8D5] relative overflow-hidden">
      
      {/* Decorative Botanical Foliage in Background */}
      <div className="absolute top-8 -left-8 w-56 h-56 pointer-events-none opacity-20 select-none -z-10">
        <svg viewBox="0 0 200 200" className="w-full h-full">
          <path d="M 60 140 Q 20 80, 40 20 Q 90 60, 60 140 Z" fill="#238B45" />
          <path d="M 80 120 Q 50 60, 100 20 Q 110 80, 80 120 Z" fill="#176B3A" />
        </svg>
      </div>

      <div className="absolute top-8 -right-8 w-56 h-56 pointer-events-none opacity-20 select-none -z-10">
        <svg viewBox="0 0 200 200" className="w-full h-full">
          <path d="M 140 140 Q 180 80, 160 20 Q 110 60, 140 140 Z" fill="#238B45" />
          <path d="M 120 120 Q 150 60, 100 20 Q 90 80, 120 120 Z" fill="#176B3A" />
        </svg>
      </div>

      {/* Floating Cursive Notes on Margins */}
      <div className="max-w-6xl mx-auto flex items-center justify-between mb-2 px-2 select-none">
        {/* Top Left: "Simple Tools Stronger Communities" with dotted arc */}
        <div className="hidden sm:flex flex-col items-start -rotate-3">
          <svg viewBox="0 0 80 20" className="w-20 h-5 mb-1 pointer-events-none">
            <path d="M 5 15 Q 40 3, 75 12" fill="none" stroke="#238B45" strokeWidth="1.5" strokeDasharray="3 3" />
            <circle cx="5" cy="15" r="2.5" fill="#238B45" />
            <circle cx="75" cy="12" r="2.5" fill="#238B45" />
          </svg>
          <span className="font-handwriting text-xl sm:text-2xl text-[#17212B] font-semibold">
            Simple Tools<br />Stronger Communities
          </span>
        </div>

        {/* Top Right: "Technology for People Real Impact" */}
        <div className="hidden sm:flex flex-col items-end rotate-3">
          <span className="font-handwriting text-xl sm:text-2xl text-[#17212B] font-semibold text-right leading-snug">
            Technology<br />for People<br />Real Impact
          </span>
        </div>
      </div>

      {/* Section Header */}
      <div className="max-w-4xl mx-auto flex flex-col items-center text-center mb-12 sm:mb-16 relative z-10">
        
        {/* Gear Icon in Circular Disc */}
        <div className="relative mb-3 flex items-center justify-center">
          <div className="w-14 h-14 rounded-full bg-[#EAF5EA] border border-[#D5E8D5] flex items-center justify-center shadow-xs">
            <Settings className="w-7 h-7 text-[#238B45]" />
          </div>
          {/* Leaf sprigs */}
          <div className="absolute -left-5 top-1 w-6 h-6">
            <svg viewBox="0 0 30 30" className="w-full h-full">
              <path d="M 20 20 Q 5 15, 2 5 Q 15 8, 20 20" fill="#238B45" />
            </svg>
          </div>
          <div className="absolute -right-5 top-1 w-6 h-6">
            <svg viewBox="0 0 30 30" className="w-full h-full">
              <path d="M 10 20 Q 25 15, 28 5 Q 15 8, 10 20" fill="#238B45" />
            </svg>
          </div>
        </div>

        {/* Title */}
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-[#17212B] tracking-tight">
          Additional <span className="text-[#238B45]">Features</span>
        </h2>
        
        {/* Green Bar Accent */}
        <div className="mt-3.5 w-16 sm:w-20 h-[3px] bg-[#238B45] rounded-full" />

        {/* Subtitle */}
        <p className="mt-4 text-sm sm:text-base md:text-lg text-[#667085] max-w-2xl font-sans">
          Specialized operational modes engineered for rural village fieldwork, classroom projection, verified lexicon search, and urgent triage.
        </p>

      </div>

      {/* Grid of 4 Additional Features */}
      <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8 relative z-10">
        
        {/* 1. Field Mode */}
        <AdditionalFeatureCard
          title="Field Mode"
          tag="Outdoor / Mobile"
          description="High-contrast one-handed interface with large touch targets, real-time noise feedback, and a 4-step workflow: Speak → Recognize → Translate → Listen."
          link="/field-mode"
          iconBg="bg-[#EAF5EA]"
          iconNode={
            <svg viewBox="0 0 60 60" className="w-12 h-12">
              {/* Mountains */}
              <polygon points="12,42 26,20 40,42" fill="none" stroke="#238B45" strokeWidth="2.5" strokeLinejoin="round" />
              <polygon points="32,42 42,28 52,42" fill="none" stroke="#238B45" strokeWidth="2.5" strokeLinejoin="round" />
              {/* Map pin */}
              <path d="M 40 12 C 36 12, 33 15, 33 19 C 33 24, 40 30, 40 30 C 40 30, 47 24, 47 19 C 47 15, 44 12, 40 12 Z" fill="none" stroke="#238B45" strokeWidth="2" />
              <circle cx="40" cy="19" r="2.5" fill="#238B45" />
            </svg>
          }
        />

        {/* 2. Teacher Mode */}
        <AdditionalFeatureCard
          title="Teacher Mode"
          tag="Classroom Projection"
          description="Live projector dual-script captions, synchronized Santali Ol Chiki subtitles, dynamic lesson vocabulary extraction, and instant transcript export (.TXT & .SRT)."
          link="/teacher-mode"
          iconBg="bg-[#EAF5EA]"
          iconNode={
            <svg viewBox="0 0 60 60" className="w-12 h-12">
              {/* Projector Screen */}
              <rect x="14" y="14" width="32" height="24" rx="2" fill="none" stroke="#238B45" strokeWidth="2.5" />
              <line x1="30" y1="38" x2="30" y2="46" stroke="#238B45" strokeWidth="2.5" />
              <line x1="20" y1="46" x2="40" y2="46" stroke="#238B45" strokeWidth="2.5" strokeLinecap="round" />
              {/* Graduation Cap in screen */}
              <polygon points="30,20 42,24 30,28 18,24" fill="#238B45" />
              <path d="M 22 26 L 22 31 C 22 33, 38 33, 38 31 L 38 26" fill="none" stroke="#238B45" strokeWidth="1.5" />
            </svg>
          }
        />

        {/* 3. Emergency Mode */}
        <AdditionalFeatureCard
          title="Emergency Mode"
          tag="Offline Triage Cards"
          description="Rapid high-visibility communication cards for urgent medical situations, pain assessment, fever, and snakebites with instant Santali & Hindi audio."
          link="/emergency-mode"
          iconBg="bg-[#FEE2E2]"
          iconNode={
            <svg viewBox="0 0 60 60" className="w-12 h-12">
              {/* Siren / Emergency Beacon */}
              <path d="M 22 38 L 22 28 C 22 20, 38 20, 38 28 L 38 38 Z" fill="none" stroke="#DC2626" strokeWidth="2.5" />
              <line x1="16" y1="38" x2="44" y2="38" stroke="#DC2626" strokeWidth="3" strokeLinecap="round" />
              {/* Light beams */}
              <line x1="30" y1="14" x2="30" y2="18" stroke="#DC2626" strokeWidth="2" strokeLinecap="round" />
              <line x1="18" y1="18" x2="22" y2="21" stroke="#DC2626" strokeWidth="2" strokeLinecap="round" />
              <line x1="42" y1="18" x2="38" y2="21" stroke="#DC2626" strokeWidth="2" strokeLinecap="round" />
            </svg>
          }
        />

        {/* 4. Verified Knowledge Base */}
        <AdditionalFeatureCard
          title="Verified Knowledge Base"
          tag="12 Domains"
          description="Instant search across 12 practical semantic categories indexing 6,780 parallel master records in Ol Chiki, Roman pronunciation, Hindi, and English."
          link="/knowledge-base"
          iconBg="bg-[#EAF5EA]"
          iconNode={
            <svg viewBox="0 0 60 60" className="w-12 h-12">
              {/* Stack of books */}
              <rect x="14" y="32" width="24" height="6" rx="1.5" fill="none" stroke="#238B45" strokeWidth="2" />
              <rect x="14" y="24" width="24" height="6" rx="1.5" fill="none" stroke="#238B45" strokeWidth="2" />
              <rect x="14" y="16" width="24" height="6" rx="1.5" fill="none" stroke="#238B45" strokeWidth="2" />
              {/* Magnifying Glass */}
              <circle cx="36" cy="34" r="8" fill="#ffffff" stroke="#238B45" strokeWidth="2.5" />
              <line x1="42" y1="40" x2="48" y2="46" stroke="#238B45" strokeWidth="3" strokeLinecap="round" />
            </svg>
          }
        />

      </div>

      {/* Bottom Floating Cursive Annotations */}
      <div className="max-w-6xl mx-auto flex items-center justify-between mt-12 px-2 select-none">
        {/* Bottom Left: "Bridging Languages Building Futures" */}
        <div className="flex flex-col items-start -rotate-2">
          <span className="font-handwriting text-xl sm:text-2xl text-[#17212B] font-semibold">
            Bridging Languages<br />Building Futures
          </span>
          <svg viewBox="0 0 100 8" className="w-24 h-2 mt-0.5">
            <path d="M 5 4 Q 50 7, 95 3" fill="none" stroke="#238B45" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
        </div>

        {/* Bottom Right: "Languages Connect People" with underline */}
        <div className="flex flex-col items-end rotate-1">
          <span className="font-handwriting text-2xl sm:text-3xl text-[#17212B] font-medium tracking-wide">
            Languages Connect People
          </span>
          <svg viewBox="0 0 130 8" className="w-32 h-2 mt-0.5">
            <path d="M 5 4 Q 65 7, 125 3" fill="none" stroke="#238B45" strokeWidth="2" strokeLinecap="round" />
          </svg>
        </div>
      </div>

    </section>
  );
};

export default AdditionalFeaturesSection;
