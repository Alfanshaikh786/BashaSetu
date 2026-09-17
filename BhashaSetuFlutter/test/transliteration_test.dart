import 'package:flutter_test/flutter_test.dart';
import 'package:bhasha_setu_flutter/core/utils/ol_chiki_transliteration.dart';

void main() {
  group('Ol Chiki Transliteration Engine Tests', () {
    test('Detects Ol Chiki Unicode characters accurately', () {
      expect(OlChikiTransliteration.containsOlChiki('ᱥᱟᱱᱛᱟᱲᱤ'), isTrue);
      expect(OlChikiTransliteration.containsOlChiki('ᱡᱚᱦᱟᱨ'), isTrue);
      expect(OlChikiTransliteration.containsOlChiki('Hello World'), isFalse);
      expect(OlChikiTransliteration.containsOlChiki('नमस्ते'), isFalse);
    });

    test('Transliterates Ol Chiki digits to Roman correctly', () {
      expect(OlChikiTransliteration.olChikiToRoman('᱐᱑᱒᱓'), '0123');
      expect(OlChikiTransliteration.olChikiToRoman('᱔᱕᱖'), '456');
      expect(OlChikiTransliteration.olChikiToRoman('᱗᱘᱙'), '789');
    });

    test('Transliterates Ol Chiki digits to Devanagari correctly', () {
      expect(OlChikiTransliteration.olChikiToDevanagari('᱐᱑᱒'), '०१२');
      expect(OlChikiTransliteration.olChikiToDevanagari('᱓᱔᱕'), '३४५');
    });

    test('Normalizes punctuation accurately for search indexing', () {
      expect(OlChikiTransliteration.normalizePunctuation('ᱡᱚᱦᱟᱨ! ᱪᱮᱫ?'), 'ᱡᱚᱦᱟᱨ ᱪᱮᱫ');
      expect(OlChikiTransliteration.normalizePunctuation('How are you?'), 'How are you');
    });
  });
}
