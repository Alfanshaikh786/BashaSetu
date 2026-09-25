"""
Migration script: Populate Mundari dataset into translations.db and public/data/translations.db
Reads MUNDARI DATASET.csv and updates 6,780 parallel rows.
"""

import csv
import sqlite3
import sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

BASE_DIR = Path(__file__).resolve().parent.parent
CSV_PATH = BASE_DIR / 'MUNDARI DATASET.csv'
DB_PATHS = [
    BASE_DIR / 'translations.db',
    BASE_DIR / 'public' / 'data' / 'translations.db'
]

def load_mundari_csv():
    print(f"Loading CSV from {CSV_PATH}...")
    rows = []
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader)
        print("Header:", header)
        for i, row in enumerate(reader):
            # Hindi, English, Mundari, Mundari_English_Pronounciation
            hi = row[0].strip() if len(row) > 0 else ""
            en = row[1].strip() if len(row) > 1 else ""
            mun = row[2].strip() if len(row) > 2 else ""
            pron = row[3].strip() if len(row) > 3 else ""
            rows.append({
                'row_id': i + 1,
                'hindi': hi,
                'english': en,
                'mundari': mun,
                'mundari_roman': pron
            })
    print(f"Total rows read from CSV: {len(rows)}")
    return rows

def update_database(db_path: Path, mundari_data: list):
    print(f"\nProcessing database: {db_path}...")
    if not db_path.exists():
        print(f"⚠️ Warning: Database file not found at {db_path}")
        return

    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    # 1. Inspect existing columns
    cur.execute("PRAGMA table_info(translations);")
    columns = [col[1] for col in cur.fetchall()]
    print("Existing columns:", columns)

    # 2. Add mundari_roman column if not present
    if 'mundari_roman' not in columns:
        print("Adding 'mundari_roman' column...")
        cur.execute("ALTER TABLE translations ADD COLUMN mundari_roman TEXT;")
        conn.commit()

    # 3. Update rows
    updated_count = 0
    for item in mundari_data:
        cur.execute("""
            UPDATE translations 
            SET mundari = ?, mundari_roman = ?
            WHERE id = ?;
        """, (item['mundari'], item['mundari_roman'], item['row_id']))
        if cur.rowcount > 0:
            updated_count += cur.rowcount

    conn.commit()
    print(f"✅ Successfully updated {updated_count} rows in {db_path.name}")

    # 4. Verify updates
    cur.execute("""
        SELECT COUNT(*), 
               COUNT(CASE WHEN mundari IS NOT NULL AND length(mundari) > 0 THEN 1 END),
               COUNT(CASE WHEN mundari_roman IS NOT NULL AND length(mundari_roman) > 0 THEN 1 END)
        FROM translations;
    """)
    total, non_empty_mun, non_empty_roman = cur.fetchone()
    print(f"Verification for {db_path.name}: Total={total}, Mundari={non_empty_mun}, Mundari_Roman={non_empty_roman}")

    cur.execute("SELECT id, english, hindi, mundari, mundari_roman FROM translations LIMIT 3;")
    samples = cur.fetchall()
    for s in samples:
        print("Sample row:", s)

    cur.close()
    conn.close()

if __name__ == '__main__':
    data = load_mundari_csv()
    for p in DB_PATHS:
        update_database(p, data)
    print("\n🎉 All databases migrated successfully!")
