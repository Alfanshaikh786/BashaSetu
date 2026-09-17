/// Ol Chiki Unicode Transliteration & Phonetic Bridge
/// Maps Ol Chiki (U+1C50–U+1C7F) to Devanagari and Roman phonetics
/// Ported directly from SIH_Bhasha_Setu-main/src/services/translationService.ts
class OlChikiTransliteration {
  static const Map<String, Map<String, String>> olChikiMap = {
    // Consonants and Vowels
    'ᱚ': {'hi': 'ऑ', 'en': 'o'},
    'ᱛ': {'hi': 'त', 'en': 't'},
    'ᱜ': {'hi': 'ग', 'en': 'g'},
    'ᱝ': {'hi': 'ं', 'en': 'ng'},
    'ᱞ': {'hi': 'ल', 'en': 'l'},
    'ᱟ': {'hi': 'आ', 'en': 'a'},
    'ᱠ': {'hi': 'क', 'en': 'k'},
    'ᱡ': {'hi': 'ज', 'en': 'j'},
    'ᱢ': {'hi': 'म', 'en': 'm'},
    'ᱣ': {'hi': 'व', 'en': 'w'},
    'ᱤ': {'hi': 'इ', 'en': 'i'},
    'ᱥ': {'hi': 'स', 'en': 's'},
    'ᱦ': {'hi': 'ह', 'en': 'h'},
    'ᱧ': {'hi': 'ञ', 'en': 'ny'},
    'ᱨ': {'hi': 'र', 'en': 'r'},
    'ᱩ': {'hi': 'उ', 'en': 'u'},
    'ᱪ': {'hi': 'च', 'en': 'ch'},
    'ᱫ': {'hi': 'द', 'en': 'd'},
    'ᱬ': {'hi': 'ण', 'en': 'n'},
    'ᱭ': {'hi': 'य', 'en': 'y'},
    'ᱮ': {'hi': 'ए', 'en': 'e'},
    'ᱯ': {'hi': 'प', 'en': 'p'},
    'ᱰ': {'hi': 'ड', 'en': 'd'},
    'ᱱ': {'hi': 'न', 'en': 'n'},
    'ᱲ': {'hi': 'ड़', 'en': 'r'},
    'ᱳ': {'hi': 'ओ', 'en': 'o'},
    'ᱴ': {'hi': 'ट', 'en': 't'},
    'ᱵ': {'hi': 'ब', 'en': 'b'},
    'ᱶ': {'hi': 'ँ', 'en': 'nh'},
    'ᱷ': {'hi': 'ह', 'en': 'h'},
    // Digits (U+1C50 - U+1C59)
    '᱐': {'hi': '०', 'en': '0'},
    '᱑': {'hi': '१', 'en': '1'},
    '᱒': {'hi': '२', 'en': '2'},
    '᱓': {'hi': '३', 'en': '3'},
    '᱔': {'hi': '४', 'en': '4'},
    '᱕': {'hi': '५', 'en': '5'},
    '᱖': {'hi': '६', 'en': '6'},
    '᱗': {'hi': '७', 'en': '7'},
    '᱘': {'hi': '८', 'en': '8'},
    '᱙': {'hi': '९', 'en': '9'},
    // Modifiers & Punctuation
    'ᱸ': {'hi': 'ं', 'en': 'n'},
    'ᱹ': {'hi': '', 'en': ''},
    'ᱺ': {'hi': 'ं', 'en': 'n'},
    'ᱻ': {'hi': '', 'en': ''},
    'ᱼ': {'hi': '', 'en': ''},
    'ᱽ': {'hi': '', 'en': ''},
    '᱾': {'hi': '।', 'en': '.'},
    '᱿': {'hi': '॥', 'en': '.'},
  };

  /// Transliterate Ol Chiki string into Devanagari representation
  static String olChikiToDevanagari(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.runes.length; i++) {
      final char = String.fromCharCode(text.runes.elementAt(i));
      if (olChikiMap.containsKey(char)) {
        buffer.write(olChikiMap[char]!['hi']);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Transliterate Ol Chiki string into Roman phonetic representation
  static String olChikiToRoman(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.runes.length; i++) {
      final char = String.fromCharCode(text.runes.elementAt(i));
      if (olChikiMap.containsKey(char)) {
        buffer.write(olChikiMap[char]!['en']);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Detect if string contains Ol Chiki characters (Unicode range U+1C50 - U+1C7F)
  static bool containsOlChiki(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x1C50 && rune <= 0x1C7F) {
        return true;
      }
    }
    return false;
  }

  /// Clean punctuation for fuzzy indexing
  static String normalizePunctuation(String text) {
    return text.replaceAll(RegExp(r'[?!.,;:()|᱾᱿]'), '').trim();
  }
}
