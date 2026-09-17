class TribalLanguage {
  final String id;
  final String name;
  final String nativeName;
  final String code; // 3-letter ISO code: sat, unr, hoc, hin, eng
  final String badge;
  final String family;
  final String speakers;
  final List<String> states;
  final String script;
  final String description;
  final bool isTribal;
  final List<String>? virtualKeys;

  const TribalLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.code,
    required this.badge,
    required this.family,
    required this.speakers,
    required this.states,
    required this.script,
    required this.description,
    required this.isTribal,
    this.virtualKeys,
  });
}

const List<TribalLanguage> supportedLanguages = [
  TribalLanguage(
    id: 'santali',
    name: 'Santali',
    nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
    code: 'sat',
    badge: 'ᱥᱟ',
    family: 'Austroasiatic',
    speakers: '7.6 Million',
    states: ['Jharkhand', 'Odisha', 'West Bengal', 'Bihar', 'Assam'],
    script: 'Ol Chiki',
    description: "Scheduled VIII language written in the unique Ol Chiki script created by Pandit Raghunath Murmu.",
    isTribal: true,
    virtualKeys: ['ᱚ', 'ᱛ', 'ᱜ', 'ᱝ', 'ᱞ', 'ᱟ', 'ᱠ', 'ᱡ', 'ᱢ', 'ᱣ', 'ᱤ', 'ᱥ', 'ᱦ', 'ᱧ', 'ᱨ', 'ᱩ', 'ᱪ', 'ᱫ', 'ᱬ', 'ᱭ', 'ᱮ', 'ᱯ', 'ᱰ', 'ᱱ', 'ᱲ', 'ᱳ', 'ᱴ', 'ᱵ', 'ᱶ', 'ᱷ', 'ᱸ', 'ᱹ', 'ᱺ', 'ᱻ', 'ᱼ', 'ᱽ'],
  ),
  TribalLanguage(
    id: 'mundari',
    name: 'Mundari',
    nativeName: 'ᱢᱩᱱᱰᱟᱨᱤ',
    code: 'unr',
    badge: 'मु',
    family: 'Austroasiatic',
    speakers: '1.1+ Million',
    states: ['Jharkhand', 'Odisha', 'West Bengal', 'Chhattisgarh'],
    script: 'Mundari Bani / Devanagari',
    description: "Austroasiatic Munda language central to the legacy of Bhagwan Birsa Munda and Ulgulan.",
    isTribal: true,
  ),
  TribalLanguage(
    id: 'ho',
    name: 'Ho',
    nativeName: '𑢹𑣉𑣉 / हो',
    code: 'hoc',
    badge: 'हो',
    family: 'Austroasiatic',
    speakers: '1.4+ Million',
    states: ['Jharkhand', 'Odisha', 'West Bengal', 'Bihar'],
    script: 'Warang Chiti / Devanagari',
    description: "Austroasiatic Munda language of the Ho people, written in the indigenous Warang Chiti script.",
    isTribal: true,
  ),
  TribalLanguage(
    id: 'hindi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    code: 'hin',
    badge: 'HI',
    family: 'Indo-Aryan',
    speakers: '600+ Million',
    states: ['PAN India'],
    script: 'Devanagari',
    description: "Official language of the Union of India, bridging central schemes and regional dialogue.",
    isTribal: false,
  ),
  TribalLanguage(
    id: 'english',
    name: 'English',
    nativeName: 'English',
    code: 'eng',
    badge: 'EN',
    family: 'Indo-European',
    speakers: 'Global',
    states: ['Global'],
    script: 'Latin',
    description: "Global bridge language for digital empowerment, academic research, and policy documentation.",
    isTribal: false,
  ),
];
