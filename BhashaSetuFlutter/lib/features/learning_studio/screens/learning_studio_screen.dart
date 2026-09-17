import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/colors.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

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
  int _masteredCount = 0;

  final List<Map<String, String>> _flashcards = [
    {'sat': 'ᱟᱥᱲᱟ', 'roman': 'Asra', 'hi': 'विद्यालय / स्कूल', 'en': 'School', 'cat': 'Classroom'},
    {'sat': 'ᱯᱩᱛᱷᱤ', 'roman': 'Puthi', 'hi': 'किताब / पुस्तक', 'en': 'Book', 'cat': 'Classroom'},
    {'sat': 'ᱢᱟᱪᱮᱛ', 'roman': 'Machet', 'hi': 'शिक्षक / अध्यापक', 'en': 'Teacher', 'cat': 'Classroom'},
    {'sat': 'ᱢᱤᱫ', 'roman': 'Mid', 'hi': 'एक (१)', 'en': 'One (1)', 'cat': 'Numbers'},
    {'sat': 'ᱵᱟᱨ', 'roman': 'Bar', 'hi': 'दो (२)', 'en': 'Two (2)', 'cat': 'Numbers'},
    {'sat': 'ᱯᱮ', 'roman': 'Pe', 'hi': 'तीन (३)', 'en': 'Three (3)', 'cat': 'Numbers'},
    {'sat': 'ᱥᱮᱛᱟ', 'roman': 'Seta', 'hi': 'कुत्ता', 'en': 'Dog', 'cat': 'Animals'},
    {'sat': 'ᱜᱟᱹᱭ', 'roman': 'Gai', 'hi': 'गाय', 'en': 'Cow', 'cat': 'Animals'},
    {'sat': 'ᱫᱟᱨᱮ', 'roman': 'Dare', 'hi': 'पेड़ / वृक्ष', 'en': 'Tree', 'cat': 'Nature'},
    {'sat': 'ᱫᱟᱜ', 'roman': 'Daag', 'hi': 'पानी / जल', 'en': 'Water', 'cat': 'Nature'},
  ];

  // Quiz state
  int _quizIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  int? _selectedAnswer;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Header
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(icon: Icon(Icons.style_rounded), text: "Flashcards"),
                    Tab(icon: Icon(Icons.print_rounded), text: "Worksheets"),
                    Tab(icon: Icon(Icons.quiz_rounded), text: "Quiz & Certificate"),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFlashcardsTab(),
                    _buildWorksheetsTab(),
                    _buildQuizTab(),
                  ],
                ),
              ),
            ],
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.primary, Colors.amber, Colors.orange, Colors.blue],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsTab() {
    final card = _flashcards[_cardIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Card ${_cardIndex + 1} of ${_flashcards.length}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("Category: ${card['cat']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flashcard Box
          InkWell(
            onTap: () => setState(() => _isFlipped = !_isFlipped),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isFlipped ? "MEANING & PHONETICS" : "SANTALI (OL CHIKI)",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isFlipped ? card['en']! : card['sat']!,
                    style: TextStyle(
                      fontSize: _isFlipped ? 26 : 38,
                      fontWeight: FontWeight.w800,
                      color: _isFlipped ? AppColors.textPrimary : AppColors.primaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isFlipped) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Hindi: ${card['hi']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pronunciation: ${card['roman']}",
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
                        onPressed: () {
                          TtsService.instance.speak(text: card['sat']!, langCode: 'sat');
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text("Tap card to flip", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Next / Previous Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _prevCard,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _masteredCount++);
                  _nextCard();
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text("Mastered!"),
              ),
              const SizedBox(width: 16),
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

  Widget _buildWorksheetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Printable A4 Classroom Worksheets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text("Generate offline bilingual practice sheets for rural primary schools.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Worksheet Preview Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("BHASHA SETU • LESSON WORKSHEET", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text("GRADE 1-3", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  ],
                ),
                const Divider(color: AppColors.border, height: 20),
                const Text("Section 1: Match the Ol Chiki word with English", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _buildMatchRow("1. ᱟᱥᱲᱟ (Asra)", "A. Water"),
                _buildMatchRow("2. ᱯᱩᱛᱷᱤ (Puthi)", "B. School"),
                _buildMatchRow("3. ᱫᱟᱜ (Daag)", "C. Book"),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("A4 Worksheet ready for offline printing!"),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text("Print / Save A4 Worksheet"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(String colA, String colB) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(colA, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
          Text(colB, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    if (_quizCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text("Assessment Completed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text("Your Score: $_score / ${_quizQuestions.length}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _quizIndex = 0;
                    _score = 0;
                    _quizCompleted = false;
                    _selectedAnswer = null;
                  });
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text("Retake Assessment"),
              ),
            ],
          ),
        ),
      );
    }

    final q = _quizQuestions[_quizIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${_quizIndex + 1} of ${_quizQuestions.length}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
              Text("Score: $_score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              q['question'] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      opt,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
