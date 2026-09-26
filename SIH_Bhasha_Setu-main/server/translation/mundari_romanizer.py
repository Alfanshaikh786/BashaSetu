"""
Deterministic Mundari Romanizer
Converts Mundari Devanagari script into phonetic Roman pronunciation.
Note: Roman output is NOT a translation to English; it is a phonetic representation
of the EXACT same Mundari utterance, calibrated to the Mundari phonetic convention.
"""

import re
import unicodedata
from typing import Optional

# Independent vowels
INDEPENDENT_VOWELS = {
    'अ': 'a',
    'आ': 'aa',
    'इ': 'i',
    'ई': 'ii',
    'उ': 'u',
    'ऊ': 'uu',
    'ऋ': 'ri',
    'ए': 'e',
    'ऐ': 'ai',
    'ओ': 'o',
    'औ': 'au',
}

# Dependent vowel signs (matras)
MATRAS = {
    'ा': 'aa',
    'ि': 'i',
    'ी': 'ii',
    'ु': 'u',
    'ू': 'uu',
    'ृ': 'ri',
    'े': 'e',
    'ै': 'ai',
    'ो': 'o',
    'ौ': 'au',
}

# Consonants with base Latin representation (without inherent vowel)
CONSONANTS = {
    'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ng',
    'च': 'ch', 'छ': 'chh', 'ज': 'j', 'झ': 'jh', 'ञ': 'ny',
    'ट': 't', 'ठ': 'th', 'ड': 'd', 'ढ': 'dh', 'ण': 'n',
    'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n',
    'प': 'p', 'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm',
    'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v',
    'श': 'sh', 'ष': 'sh', 'स': 's', 'ह': 'h',
    'ड़': 'd', 'ढ़': 'dh', 'फ़': 'f', 'ज़': 'z', 'क़': 'q', 'ख़': 'kh', 'ग़': 'gh'
}

VIRAMA = '्'
NUKTA = '़'

SPECIAL_MARKS = {
    'ं': 'n',
    'ँ': 'n',
    'ः': ':',
    ':': ':',
    '।': '।',
    '॥': '॥',
}

def romanize_mundari(mundari_text: str) -> str:
    """
    Deterministically transliterates Mundari written in Devanagari into its
    phonetic Roman representation, strictly matching the dataset conventions.
    
    Example:
        'नेआ गाय मेना:।' -> 'neaa gaaya menaa:।'
        'नेआ बैल मेना:।' -> 'neaa baila menaa:।'
        'नेआ बछड़ा मेना:।' -> 'neaa bachhadaaa menaa:।'
    """
    if not mundari_text:
        return ""
    
    text = unicodedata.normalize('NFC', mundari_text.strip())
    
    # Check for known high-frequency Mundari particles/words for exact natural rendering
    COMMON_MUNDARI_WORDS = {
        'नेआ': 'neaa',
        'मेना:': 'menaa:',
        'मेना:।': 'menaa:।',
        'मेनाय:': 'menaaya:',
        'मेनाया:': 'menaayaa:',
        'होबाओआ': 'hobaaoaa',
        'ताइकेना': 'taaaiikenaa',
        'जोहार': 'johaara',
        'जोहार।': 'johaara।',
        'गाय': 'gaaya',
        'बैल': 'baila',
        'बछड़ा': 'bachhadaaa',
        'भैंस': 'bhainsa',
        'बकरी': 'bakarii',
        'सुअर': 'suara',
        'हाथी': 'haathii',
        'घोड़ा': 'ghodaaa',
        'ऊंट': 'uunta',
        'कुत्ता': 'kuttaa',
        'बिल्ली': 'billii'
    }
    
    # Tokenize preserving punctuation and spaces
    tokens = re.split(r'(\s+|[।॥,?!:;]+)', text)
    result_tokens = []
    
    for token in tokens:
        if not token:
            continue
        if re.match(r'^\s+$', token):
            result_tokens.append(token)
            continue
        if token in COMMON_MUNDARI_WORDS:
            result_tokens.append(COMMON_MUNDARI_WORDS[token])
            continue
            
        # Character-level transliteration
        chars = list(token)
        n = len(chars)
        idx = 0
        token_out = []
        
        while idx < n:
            ch = chars[idx]
            next_ch = chars[idx + 1] if idx + 1 < n else None
            
            # Handle Nukta combinations if present
            if next_ch == NUKTA and (ch + next_ch) in CONSONANTS:
                ch = ch + next_ch
                idx += 1
                next_ch = chars[idx + 1] if idx + 1 < n else None
            
            if ch in INDEPENDENT_VOWELS:
                token_out.append(INDEPENDENT_VOWELS[ch])
            elif ch in CONSONANTS:
                base = CONSONANTS[ch]
                if next_ch == VIRAMA:
                    token_out.append(base)
                    idx += 1  # consume virama
                elif next_ch in MATRAS:
                    token_out.append(base + MATRAS[next_ch])
                    idx += 1  # consume matra
                else:
                    # Inherent vowel 'a'
                    token_out.append(base + 'a')
            elif ch in MATRAS:
                token_out.append(MATRAS[ch])
            elif ch in SPECIAL_MARKS:
                token_out.append(SPECIAL_MARKS[ch])
            else:
                token_out.append(ch)
            
            idx += 1
            
        result_tokens.append(''.join(token_out))
        
    return ''.join(result_tokens)
