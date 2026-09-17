import React, { useState } from 'react';
import { Menu, ChevronDown, Volume2, ArrowUpDown, Wifi, Battery, Sparkles } from 'lucide-react';
import { translateText } from '../../services/translationService';

interface PresetPair {
  sourceLang: string;
  targetLang: string;
  sourceText: string;
  targetText: string;
  sourceCode: string;
  targetCode: string;
}

const PRESET_PAIRS: PresetPair[] = [
  {
    sourceLang: 'Gondi',
    targetLang: 'English',
    sourceText: 'िम्मा बदम मन्तोम।',
    targetText: 'How are you?',
    sourceCode: 'gon',
    targetCode: 'eng'
  },
  {
    sourceLang: 'Santali',
    targetLang: 'English',
    sourceText: 'ᱡᱚᱦᱟᱨ, ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱜ ᱵᱤᱱᱟ?',
    targetText: 'Hello, how are you?',
    sourceCode: 'sat',
    targetCode: 'eng'
  },
  {
    sourceLang: 'Hindi',
    targetLang: 'English',
    sourceText: 'नमस्ते, आप कैसे हैं?',
    targetText: 'Hello, how are you?',
    sourceCode: 'hin',
    targetCode: 'eng'
  }
];

export const InteractiveHeroPhone: React.FC = () => {
  const [selectedPresetIndex, setSelectedPresetIndex] = useState(0);
  const [sourceLang, setSourceLang] = useState(PRESET_PAIRS[0].sourceLang);
  const [targetLang, setTargetLang] = useState(PRESET_PAIRS[0].targetLang);
  const [sourceText, setSourceText] = useState(PRESET_PAIRS[0].sourceText);
  const [targetText, setTargetText] = useState(PRESET_PAIRS[0].targetText);
  const [isTranslating, setIsTranslating] = useState(false);
  const [buttonState, setButtonState] = useState<'translate' | 'translated'>('translated');

  // Handle translation
  const handleTranslate = async (textToTranslate?: string) => {
    const query = textToTranslate !== undefined ? textToTranslate : sourceText;
    if (!query.trim()) {
      setTargetText('');
      return;
    }

    setIsTranslating(true);
    try {
      const res = await translateText(query, sourceLang.toLowerCase(), targetLang.toLowerCase());
      if (res.targetText || res.text) {
        setTargetText(res.targetText || res.text);
      } else {
        const match = PRESET_PAIRS.find(p => p.sourceText === query);
        setTargetText(match ? match.targetText : 'How are you?');
      }
      setButtonState('translated');
    } catch {
      setTargetText('How are you?');
      setButtonState('translated');
    } finally {
      setIsTranslating(false);
    }
  };

  // Swap languages & texts
  const handleSwap = () => {
    const prevSourceLang = sourceLang;
    const prevTargetLang = targetLang;
    const prevSourceText = sourceText;
    const prevTargetText = targetText;

    setSourceLang(prevTargetLang);
    setTargetLang(prevSourceLang);
    setSourceText(prevTargetText);
    setTargetText(prevSourceText);
    setButtonState('translated');
  };

  // Speak text with Web Speech API
  const handleSpeak = (text: string, langName: string) => {
    if (!('speechSynthesis' in window) || !text) return;

    window.speechSynthesis.cancel();
    const utterance = new SpeechSynthesisUtterance(text);
    
    if (langName.toLowerCase().includes('english') || langName === 'eng') {
      utterance.lang = 'en-US';
    } else if (langName.toLowerCase().includes('hindi') || langName === 'hin') {
      utterance.lang = 'hi-IN';
    } else {
      utterance.lang = 'hi-IN';
    }
    
    utterance.rate = 0.9;
    window.speechSynthesis.speak(utterance);
  };

  // Switch between demo presets
  const handleCyclePreset = () => {
    const nextIdx = (selectedPresetIndex + 1) % PRESET_PAIRS.length;
    setSelectedPresetIndex(nextIdx);
    const preset = PRESET_PAIRS[nextIdx];
    setSourceLang(preset.sourceLang);
    setTargetLang(preset.targetLang);
    setSourceText(preset.sourceText);
    setTargetText(preset.targetText);
    setButtonState('translated');
  };

  return (
    <div className="relative w-full max-w-[320px] sm:max-w-[340px] md:max-w-[360px] aspect-[9/18.5] mx-auto select-none">
      
      {/* Outer Phone Hardware Frame */}
      <div className="relative w-full h-full bg-[#0A0F1D] rounded-[48px] p-2.5 sm:p-3 shadow-[0_25px_60px_-15px_rgba(15,23,42,0.35),0_0_0_1px_rgba(255,255,255,0.12)] border-2 border-slate-800 transition-all duration-300 hover:shadow-[0_30px_70px_-15px_rgba(35,139,69,0.2)]">
        
        {/* Top Dynamic Island Notch */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-30 flex items-center justify-center pointer-events-none">
          <div className="w-24 h-5 bg-black rounded-full flex items-center justify-end pr-2.5 gap-1.5 shadow-sm">
            <div className="w-2.5 h-2.5 rounded-full bg-[#1E293B] border border-[#334155]" />
          </div>
        </div>

        {/* Screen Display Container */}
        <div className="w-full h-full bg-[#F8FBF7] rounded-[38px] overflow-hidden flex flex-col justify-between p-4 sm:p-5 pt-3 relative border border-[#D5E8D5]">
          
          {/* Top Status Bar */}
          <div className="flex items-center justify-between text-[#17212B] text-[11px] font-bold px-1 select-none pt-0.5">
            <span>9:30</span>
            <div className="flex items-center gap-1.5 text-[#17212B]">
              <Wifi className="w-3.5 h-3.5" />
              <Battery className="w-3.5 h-3.5" />
            </div>
          </div>

          {/* App Header */}
          <div className="flex items-center justify-between mt-3 mb-2 px-1">
            <button 
              type="button" 
              aria-label="Menu"
              className="p-1 text-[#17212B] hover:text-[#238B45] transition cursor-pointer"
            >
              <Menu className="w-4 h-4" />
            </button>
            <h3 className="text-sm font-bold text-[#176B3A] tracking-tight">
              Text to Text
            </h3>
            <button
              type="button"
              onClick={handleCyclePreset}
              title="Click to switch sample language pair"
              className="text-[10px] text-[#238B45] bg-[#EAF5EA] px-2 py-0.5 rounded-full font-bold hover:bg-[#238B45] hover:text-white transition cursor-pointer flex items-center gap-1"
            >
              <Sparkles className="w-2.5 h-2.5" />
              <span>Demo</span>
            </button>
          </div>

          {/* Translation Interactive Workspace */}
          <div className="flex-1 flex flex-col justify-center gap-2">
            
            {/* "From" Section */}
            <div>
              <div className="flex items-center justify-between mb-1 px-1">
                <span className="text-[10px] uppercase font-bold text-[#667085] tracking-wider">
                  From
                </span>
              </div>
              
              {/* Language Pill Selector */}
              <button
                type="button"
                onClick={handleCyclePreset}
                className="inline-flex items-center gap-1.5 bg-white border border-[#D5E8D5] px-2.5 py-1 rounded-full shadow-2xs text-xs font-semibold text-[#17212B] mb-1.5 hover:border-[#238B45] transition cursor-pointer"
              >
                <div className="w-4 h-4 rounded-full bg-[#238B45] text-white flex items-center justify-center text-[8px] font-bold">
                  {sourceLang[0]}
                </div>
                <span>{sourceLang}</span>
                <ChevronDown className="w-3 h-3 text-[#667085]" />
              </button>

              {/* Source Input Box */}
              <div className="bg-white rounded-2xl border border-[#D5E8D5] p-3 shadow-xs flex flex-col justify-between min-h-[92px] group focus-within:border-[#238B45] focus-within:ring-2 focus-within:ring-[#238B45]/10 transition">
                <textarea
                  value={sourceText}
                  onChange={(e) => {
                    setSourceText(e.target.value);
                    setButtonState('translate');
                  }}
                  placeholder="Type text here..."
                  rows={2}
                  className="w-full text-xs sm:text-sm font-medium text-[#17212B] bg-transparent resize-none focus:outline-none placeholder:text-slate-300 leading-snug"
                />
                <div className="flex justify-end pt-1">
                  <button
                    type="button"
                    aria-label="Listen source audio"
                    onClick={() => handleSpeak(sourceText, sourceLang)}
                    className="p-1 rounded-md text-[#667085] hover:text-[#238B45] hover:bg-[#EAF5EA] transition cursor-pointer"
                    title="Listen pronunciation"
                  >
                    <Volume2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>

            {/* Circular Swap Button */}
            <div className="flex justify-center -my-1 relative z-10">
              <button
                type="button"
                onClick={handleSwap}
                className="w-8 h-8 rounded-full bg-white border border-[#D5E8D5] shadow-xs flex items-center justify-center text-[#17212B] hover:text-[#238B45] hover:border-[#238B45] hover:scale-105 active:scale-95 transition cursor-pointer"
                title="Swap Languages"
              >
                <ArrowUpDown className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* "To" Section */}
            <div>
              <div className="flex items-center justify-between mb-1 px-1">
                <span className="text-[10px] uppercase font-bold text-[#667085] tracking-wider">
                  To
                </span>
              </div>

              {/* Language Pill Selector */}
              <button
                type="button"
                onClick={handleCyclePreset}
                className="inline-flex items-center gap-1.5 bg-white border border-[#D5E8D5] px-2.5 py-1 rounded-full shadow-2xs text-xs font-semibold text-[#17212B] mb-1.5 hover:border-[#238B45] transition cursor-pointer"
              >
                <div className="w-4 h-4 rounded-full bg-[#238B45] text-white flex items-center justify-center text-[8px] font-bold">
                  {targetLang.slice(0, 2).toUpperCase()}
                </div>
                <span>{targetLang}</span>
                <ChevronDown className="w-3 h-3 text-[#667085]" />
              </button>

              {/* Target Output Box */}
              <div className="bg-white rounded-2xl border border-[#D5E8D5] p-3 shadow-xs flex flex-col justify-between min-h-[92px]">
                <p className="text-xs sm:text-sm font-medium text-[#17212B] leading-snug">
                  {targetText || <span className="text-slate-300">Translation output...</span>}
                </p>
                <div className="flex justify-end pt-1">
                  <button
                    type="button"
                    aria-label="Listen translation audio"
                    onClick={() => handleSpeak(targetText, targetLang)}
                    className="p-1 rounded-md text-[#667085] hover:text-[#238B45] hover:bg-[#EAF5EA] transition cursor-pointer"
                    title="Listen pronunciation"
                  >
                    <Volume2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>

          </div>

          {/* Bottom Action Button */}
          <div className="mt-3">
            <button
              type="button"
              onClick={() => handleTranslate()}
              disabled={isTranslating}
              className="w-full bg-[#176B3A] hover:bg-[#11522c] active:bg-[#0c3c20] text-white py-2.5 rounded-xl font-bold text-xs sm:text-sm shadow-xs transition active:scale-98 cursor-pointer flex items-center justify-center gap-1.5"
            >
              {isTranslating ? (
                <span>Translating...</span>
              ) : buttonState === 'translated' ? (
                <span>Translated</span>
              ) : (
                <span>Translate</span>
              )}
            </button>
          </div>

        </div>

      </div>

    </div>
  );
};
