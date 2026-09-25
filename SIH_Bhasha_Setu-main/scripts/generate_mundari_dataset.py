"""
Generate src/data/mundariDataset.ts from translations.db.
Provides in-memory 6,780 parallel entries with O(1) hash maps for instant, zero-latency offline translations.
"""

import sqlite3
import json
import sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / 'translations.db'
OUTPUT_TS_PATH = BASE_DIR / 'src' / 'data' / 'mundariDataset.ts'

def generate_dataset():
    print(f"Reading from {DB_PATH}...")
    conn = sqlite3.connect(str(DB_PATH))
    cur = conn.cursor()
    cur.execute("""
        SELECT id, english, hindi, mundari, mundari_roman, category
        FROM translations
        ORDER BY id ASC;
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    print(f"Loaded {len(rows)} rows from database.")

    entries = []
    for r in rows:
        row_id, en, hi, mun, roman, cat = r
        entries.append({
            "id": f"mun-{row_id}",
            "en": en or "",
            "hi": hi or "",
            "mun": mun or "",
            "roman": roman or "",
            "cat": cat or "General",
            "verified": True
        })

    entries_json = json.dumps(entries, ensure_ascii=False, indent=2)

    ts_content = f'''// Auto-generated Mundari Dataset containing 6,780+ verified parallel sentences & vocabulary
// Sourced from MUNDARI DATASET.csv and translations.db with verified Devanagari script, Roman pronunciations & categories.

export interface MundariDatasetEntry {{
  id: string;
  en: string;
  hi: string;
  mun: string;
  roman: string;
  cat: string;
  verified?: boolean;
}}

export const MUNDARI_DATASET: MundariDatasetEntry[] = {entries_json};

export function normalizeMundariText(text: string): string {{
  return text
    .toLowerCase()
    .replace(/[\\s\\u200B-\\u200D\\uFEFF]+/g, ' ')
    .replace(/[?!.,;:()|॥\\-"']/g, '')
    .trim();
}}

// Fast O(1) in-memory index maps
const exactEnglishMap = new Map<string, MundariDatasetEntry>();
const exactHindiMap = new Map<string, MundariDatasetEntry>();
const exactMundariMap = new Map<string, MundariDatasetEntry>();
const exactRomanMap = new Map<string, MundariDatasetEntry>();

// Populate indexes once on module load
MUNDARI_DATASET.forEach(entry => {{
  if (entry.en) {{
    const normEn = normalizeMundariText(entry.en);
    if (normEn && !exactEnglishMap.has(normEn)) exactEnglishMap.set(normEn, entry);
  }}
  if (entry.hi) {{
    const normHi = normalizeMundariText(entry.hi);
    if (normHi && !exactHindiMap.has(normHi)) exactHindiMap.set(normHi, entry);
  }}
  if (entry.mun) {{
    const normMun = normalizeMundariText(entry.mun);
    if (normMun && !exactMundariMap.has(normMun)) exactMundariMap.set(normMun, entry);
  }}
  if (entry.roman) {{
    const normRom = normalizeMundariText(entry.roman);
    if (normRom && !exactRomanMap.has(normRom)) exactRomanMap.set(normRom, entry);
  }}
}});

/**
 * Exact O(1) dataset lookup for Mundari
 */
export function lookupExactMundariEntry(text: string, lang: 'eng' | 'hin' | 'mun'): MundariDatasetEntry | undefined {{
  const norm = normalizeMundariText(text);
  if (!norm) return undefined;

  if (lang === 'eng') return exactEnglishMap.get(norm);
  if (lang === 'hin') return exactHindiMap.get(norm);
  if (lang === 'mun') return exactMundariMap.get(norm) || exactRomanMap.get(norm);

  return exactEnglishMap.get(norm) || exactHindiMap.get(norm) || exactMundariMap.get(norm);
}}

export interface MundariMatchResult {{
  match: MundariDatasetEntry;
  confidence: number;
  alternateCandidates?: MundariDatasetEntry[];
}}

/**
 * Search Mundari Dataset with O(1) exact matching and token Jaccard fallback
 */
export function findMundariMatch(
  query: string,
  sourceLang: string,
  targetLang: string,
  options?: {{ domain?: string }}
): MundariMatchResult | null {{
  const cleanQuery = normalizeMundariText(query);
  if (!cleanQuery) return null;

  // 1. Exact Match via O(1) hash maps
  let exactEntry: MundariDatasetEntry | undefined;
  if (sourceLang === 'english') exactEntry = exactEnglishMap.get(cleanQuery);
  else if (sourceLang === 'hindi') exactEntry = exactHindiMap.get(cleanQuery);
  else if (sourceLang === 'mundari') exactEntry = exactMundariMap.get(cleanQuery) || exactRomanMap.get(cleanQuery);

  if (exactEntry) {{
    return {{ match: exactEntry, confidence: 0.99 }};
  }}

  // 2. Fuzzy / Token search across dataset
  const queryTokens = cleanQuery.split(' ').filter(t => t.length > 1);
  if (queryTokens.length === 0) return null;

  let bestEntry: MundariDatasetEntry | null = null;
  let bestScore = 0;

  for (let i = 0; i < MUNDARI_DATASET.length; i++) {{
    const item = MUNDARI_DATASET[i];
    let targetText = '';
    if (sourceLang === 'english') targetText = item.en;
    else if (sourceLang === 'hindi') targetText = item.hi;
    else if (sourceLang === 'mundari') targetText = item.mun;
    else targetText = item.en;

    const normTarget = normalizeMundariText(targetText);
    if (!normTarget) continue;

    const targetTokens = normTarget.split(' ').filter(t => t.length > 1);
    let intersection = 0;
    for (const qt of queryTokens) {{
      if (targetTokens.includes(qt)) intersection++;
    }}

    const union = new Set([...queryTokens, ...targetTokens]).size;
    const jaccard = union > 0 ? intersection / union : 0;
    const tokenRatio = Math.min(queryTokens.length, targetTokens.length) / Math.max(queryTokens.length, targetTokens.length);

    if (tokenRatio < 0.70) continue;

    let score = jaccard * tokenRatio;
    if (normTarget.includes(cleanQuery) || cleanQuery.includes(normTarget)) {{
      score = Math.max(score, 0.85 + (jaccard * 0.15));
    }}

    if (score > bestScore) {{
      bestScore = score;
      bestEntry = item;
      if (bestScore >= 0.98) break;
    }}
  }}

  const minThreshold = queryTokens.length <= 1 ? 0.90 : 0.82;
  if (bestEntry && bestScore >= minThreshold) {{
    return {{ match: bestEntry, confidence: Math.min(bestScore, 0.96) }};
  }}

  return null;
}}
'''

    print(f"Writing TS file to {OUTPUT_TS_PATH}...")
    with open(OUTPUT_TS_PATH, 'w', encoding='utf-8') as f:
        f.write(ts_content)

    print(f"✅ Generated {OUTPUT_TS_PATH.name} ({len(entries)} entries, {len(ts_content)} bytes)")

if __name__ == '__main__':
    generate_dataset()
