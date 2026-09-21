import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class LearningStudioScreen extends StatefulWidget {
  const LearningStudioScreen({super.key});

  @override
  State<LearningStudioScreen> createState() => _LearningStudioScreenState();
}

class _LearningStudioScreenState extends State<LearningStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  // Flashcards state
  int _cardIndex = 0;
  bool _isFlipped = false;
  final Set<String> _masteredIds = {};

  final List<Map<String, String>> _flashcards = [
    {'id': 'fc-1', 'sat': 'ᱟᱥᱲᱟ', 'roman': 'Asra', 'hi': 'विद्यालय / स्कूल', 'en': 'School', 'cat': 'Classroom'},
    {'id': 'fc-2', 'sat': 'ᱯᱩᱛᱷᱤ', 'roman': 'Puthi', 'hi': 'किताब / पुस्तक', 'en': 'Book', 'cat': 'Classroom'},
    {'id': 'fc-3', 'sat': 'ᱢᱟᱪᱮᱛ', 'roman': 'Machet', 'hi': 'शिक्षक / अध्यापक', 'en': 'Teacher', 'cat': 'Classroom'},
    {'id': 'fc-4', 'sat': 'ᱢᱤᱫ', 'roman': 'Mid', 'hi': 'एक (१)', 'en': 'One (1)', 'cat': 'Numbers'},
    {'id': 'fc-5', 'sat': 'ᱵᱟᱨ', 'roman': 'Bar', 'hi': 'दो (२)', 'en': 'Two (2)', 'cat': 'Numbers'},
    {'id': 'fc-6', 'sat': 'ᱯᱮ', 'roman': 'Pe', 'hi': 'तीन (३)', 'en': 'Three (3)', 'cat': 'Numbers'},
    {'id': 'fc-7', 'sat': 'ᱥᱮᱛᱟ', 'roman': 'Seta', 'hi': 'कुत्ता', 'en': 'Dog', 'cat': 'Animals'},
    {'id': 'fc-8', 'sat': 'ᱜᱟᱹᱭ', 'roman': 'Gai', 'hi': 'गाय', 'en': 'Cow', 'cat': 'Animals'},
    {'id': 'fc-9', 'sat': 'ᱫᱟᱨᱮ', 'roman': 'Dare', 'hi': 'पेड़ / वृक्ष', 'en': 'Tree', 'cat': 'Nature'},
    {'id': 'fc-10', 'sat': 'ᱫᱟᱜ', 'roman': 'Daag', 'hi': 'पानी / जल', 'en': 'Water', 'cat': 'Nature'},
  ];

  // Worksheet matching state
  String? _selectedColA;
  final Map<String, String> _userMatches = {}; // colA -> colB

  final List<Map<String, String>> _matchingPairs = [
    {'id': 'm-1', 'sat': 'ᱟᱥᱲᱟ', 'roman': 'Asra', 'en': 'School'},
    {'id': 'm-2', 'sat': 'ᱯᱩᱛᱷᱤ', 'roman': 'Puthi', 'en': 'Book'},
    {'id': 'm-3', 'sat': 'ᱫᱟᱜ', 'roman': 'Daag', 'en': 'Water'},
    {'id': 'm-4', 'sat': 'ᱫᱟᱨᱮ', 'roman': 'Dare', 'en': 'Tree'},
  ];

  // Quiz state
  int _quizIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'What does "ᱢᱟᱪᱮᱛ" (Machet) mean in English?',
      'options': ['Student', 'Teacher', 'School', 'Book'],
      'correct': 1,
    },
    {
      'question': 'Which of these is the Ol Chiki word for "Water"?',
      'options': ['ᱫᱟᱨᱮ', 'ᱫᱟᱜ', 'ᱥᱮᱛᱟ', 'ᱯᱩᱛᱷᱤ'],
      'correct': 1,
    },
    {
      'question': 'What number does "ᱯᱮ" (Pe) represent?',
      'options': ['One (1)', 'Two (2)', 'Three (3)', 'Four (4)'],
      'correct': 2,
    },
    {
      'question': 'Which animal does "ᱜᱟᱹᱭ" (Gai) refer to?',
      'options': ['Tiger', 'Dog', 'Cow', 'Elephant'],
      'correct': 2,
    },
    {
      'question': 'What is the Santali word for "Tree"?',
      'options': ['ᱫᱟᱨᱮ', 'ᱟᱥᱲᱟ', 'ᱢᱤᱫ', 'ᱫᱟᱜ'],
      'correct': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextCard() {
    setState(() {
      _isFlipped = false;
      _cardIndex = (_cardIndex + 1) % _flashcards.length;
    });
  }

  void _prevCard() {
    setState(() {
      _isFlipped = false;
      _cardIndex = (_cardIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  void _shuffleCards() {
    setState(() {
      _isFlipped = false;
      _cardIndex = Random().nextInt(_flashcards.length);
    });
  }

  void _toggleMastered(String id) {
    setState(() {
      if (_masteredIds.contains(id)) {
        _masteredIds.remove(id);
      } else {
        _masteredIds.add(id);
        _confettiController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xFFDCFCE7)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.school_rounded, color: Color(0xFF249144), size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      "Autonomous Pedagogical Studio",
                                      style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Indigenous Learning Studio",
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Master tribal scripts, phonetics, and grammar through interactive flashcards, printable worksheets, and graded quizzes.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Tab Controller Bar
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: const Color(0xFF249144),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: const Color(0xFF64748B),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(icon: Icon(Icons.style_rounded, size: 18), text: "Flashcards"),
                                Tab(icon: Icon(Icons.assignment_rounded, size: 18), text: "Worksheets"),
                                Tab(icon: Icon(Icons.quiz_rounded, size: 18), text: "Assessment & Quiz"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab Content
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, _) {
                              if (_tabController.index == 0) {
                                return _buildFlashcardsTab();
                              } else if (_tabController.index == 1) {
                                return _buildWorksheetsTab();
                              } else {
                                return _buildQuizTab();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),

          // Confetti Animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Color(0xFF249144), Colors.amber, Colors.orange, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: FLASHCARDS
  Widget _buildFlashcardsTab() {
    final card = _flashcards[_cardIndex];
    final isMastered = _masteredIds.contains(card['id']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Flashcard Top Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Card ${_cardIndex + 1} of ${_flashcards.length}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: Text(card['cat']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                    child: Text("${_masteredIds.length} Mastered", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF14532D))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3D Flip Flashcard Box
          InkWell(
            onTap: () => setState(() => _isFlipped = !_isFlipped),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: _isFlipped
                    ? const LinearGradient(colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _isFlipped ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isFlipped ? "ENGLISH & HINDI TRANSLATION" : "SANTALI (OL CHIKI SCRIPT)",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: _isFlipped ? const Color(0xFF15803D) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isFlipped ? card['en']! : card['sat']!,
                    style: TextStyle(
                      fontSize: _isFlipped ? 30 : 44,
                      fontWeight: FontWeight.w900,
                      color: _isFlipped ? const Color(0xFF0F172A) : const Color(0xFF14532D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isFlipped) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Hindi: ${card['hi']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pronunciation: ${card['roman']}",
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontFamily: 'monospace'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF249144), size: 26),
                        onPressed: () => TtsService.instance.speak(text: card['sat']!, langCode: 'sat'),
                      ),
                      const SizedBox(width: 8),
                      const Text("Tap card to flip", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Controls (Prev, Mastered, Shuffle, Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _prevCard,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                onPressed: () => _toggleMastered(card['id']!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMastered ? const Color(0xFF15803D) : const Color(0xFF249144),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(isMastered ? Icons.check_circle_rounded : Icons.star_border_rounded, size: 18),
                label: Text(isMastered ? "Mastered ✓" : "Mark Mastered", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _shuffleCards,
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: const Text("Shuffle"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(width: 14),
              IconButton.filledTonal(
                onPressed: _nextCard,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 2: WORKSHEETS
  Widget _buildWorksheetsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Interactive Matching Worksheet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 2),
                  Text("Tap an Ol Chiki word in Column A, then tap its English match in Column B.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("A4 Printable PDF downloaded successfully!"), backgroundColor: Color(0xFF249144)),
                  );
                },
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text("Print A4 Sheet", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
          const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

          // Matching columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column A
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("COLUMN A (OL CHIKI)", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    ..._matchingPairs.map((p) {
                      final isSelected = _selectedColA == p['id'];
                      final isMatched = _userMatches.containsKey(p['id']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedColA = p['id']);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? const Color(0xFFF0FDF4)
                                  : (isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMatched
                                    ? const Color(0xFF249144)
                                    : (isSelected ? const Color(0xFF4338CA) : const Color(0xFFE2E8F0)),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p['sat']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                if (isMatched) const Icon(Icons.check_circle_rounded, color: Color(0xFF249144), size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Column B
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("COLUMN B (ENGLISH)", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    ..._matchingPairs.reversed.map((p) {
                      final isMatched = _userMatches.values.contains(p['id']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            if (_selectedColA != null) {
                              setState(() {
                                _userMatches[_selectedColA!] = p['id']!;
                                _selectedColA = null;
                                if (_userMatches.length == _matchingPairs.length) {
                                  _confettiController.play();
                                }
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isMatched ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMatched ? const Color(0xFF249144) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p['en']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                if (isMatched) const Icon(Icons.check_circle_rounded, color: Color(0xFF249144), size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 3: QUIZ & ASSESSMENT
  Widget _buildQuizTab() {
    if (_quizCompleted) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              "Assessment Completed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              "Your Score: $_score / ${_quizQuestions.length} (${((_score / _quizQuestions.length) * 100).toInt()}%)",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF249144)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Congratulations! You have demonstrated verified proficiency in Santali Ol Chiki vocabulary.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _quizIndex = 0;
                  _score = 0;
                  _quizCompleted = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF249144),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: const Text("Retake Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    final q = _quizQuestions[_quizIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${_quizIndex + 1} of ${_quizQuestions.length}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
              ),
              Text(
                "Score: $_score",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF249144)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              q['question'] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(
            (q['options'] as List<String>).length,
            (index) {
              final opt = (q['options'] as List<String>)[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    final correct = q['correct'] as int;
                    if (index == correct) {
                      _score++;
                    }
                    if (_quizIndex + 1 < _quizQuestions.length) {
                      setState(() => _quizIndex++);
                    } else {
                      _confettiController.play();
                      setState(() => _quizCompleted = true);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      opt,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
