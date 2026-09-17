import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../services/database/database_service.dart';
import '../../../data/models/translation_row.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDomain = 'All';
  List<TranslationRow> _phrases = [];
  bool _isLoading = true;

  final List<String> _domains = [
    'All',
    'Classroom',
    'Health',
    'Agriculture',
    'Forestry',
    'Governance',
    'Culture',
    'Weather',
  ];

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    setState(() => _isLoading = true);
    final rows = await DatabaseService.instance.searchClassroomSentences(
      keyword: _searchController.text.trim(),
      category: _selectedDomain,
      limit: 30,
    );
    setState(() {
      _phrases = rows;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(18),
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
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text("VERIFIED KNOWLEDGE BASE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("12 Domains", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Verified Tribal Lexicon & Phrases", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text("Curated parallel records categorized across essential education, agriculture, and field domains.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search knowledge base by English, Hindi or Santali...",
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _loadPhrases();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _loadPhrases(),
            ),
            const SizedBox(height: 12),

            // Domain Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _domains.map((dom) {
                  final isSelected = _selectedDomain == dom;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(dom, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      onSelected: (_) {
                        setState(() => _selectedDomain = dom);
                        _loadPhrases();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Phrases List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _phrases.isEmpty
                      ? const Center(child: Text("No phrases found in this category.", style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: _phrases.length,
                          itemBuilder: (context, i) {
                            final p = _phrases[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
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
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.veryLightGreen,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(p.category ?? 'General', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: p.santali));
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied phrase!")));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.primary),
                                            onPressed: () {
                                              TtsService.instance.speak(text: p.santali, langCode: 'sat');
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(p.english, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text("Hindi: ${p.hindi}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  Text(p.santali, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                                  if (p.santaliRoman != null) ...[
                                    Text(p.santaliRoman!, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
