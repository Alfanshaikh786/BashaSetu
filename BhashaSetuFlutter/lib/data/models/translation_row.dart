/// Represents a record in the SQLite translations table (6,780 parallel records)
class TranslationRow {
  final int id;
  final String english;
  final String hindi;
  final String santali;
  final String? santaliRoman;
  final String? ho;
  final String? mundari;
  final String? category;
  final String? verified;

  const TranslationRow({
    required this.id,
    required this.english,
    required this.hindi,
    required this.santali,
    this.santaliRoman,
    this.ho,
    this.mundari,
    this.category,
    this.verified,
  });

  factory TranslationRow.fromMap(Map<String, dynamic> map) {
    return TranslationRow(
      id: map['id'] as int? ?? 0,
      english: map['english'] as String? ?? '',
      hindi: map['hindi'] as String? ?? '',
      santali: map['santali'] as String? ?? '',
      santaliRoman: map['santali_roman'] as String?,
      ho: map['ho'] as String?,
      mundari: map['mundari'] as String?,
      category: map['category'] as String?,
      verified: map['verified'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'hindi': hindi,
      'santali': santali,
      'santali_roman': santaliRoman,
      'ho': ho,
      'mundari': mundari,
      'category': category,
      'verified': verified,
    };
  }

  /// Get text for specific language code (sat, unr, hoc, hin, eng)
  String getForLanguage(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'sat':
        return santali;
      case 'unr':
        return mundari ?? santali;
      case 'hoc':
        return ho ?? santali;
      case 'hin':
        return hindi;
      case 'eng':
      default:
        return english;
    }
  }
}
