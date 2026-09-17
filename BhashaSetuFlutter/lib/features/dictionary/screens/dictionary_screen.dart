import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/database/database_service.dart';
import '../../../data/models/translation_row.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<TranslationRow> _entries = [];
  bool _isLoading = true;
  int _totalRows = 6780;

  final List<String> _categories = [
    'All',
    'Classroom',
    'Education',
    'Health',
    'Agriculture',
    'Nature',
    'Administration',
    'Family',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final rows = await DatabaseService.instance.searchClassroomSentences(
      keyword: _searchController.text.trim(),
      category: _selectedCategory,
      limit: 40,
    );
    final stats = await DatabaseService.instance.getStats();
    setState(() {
      _entries = rows;
      _totalRows = stats['totalRows'] ?? 6780;
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
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Multilingual Dictionary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("$_totalRows verified tribal lexicon records", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("100% Offline", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search in English, Hindi, Ol Chiki or Roman...",
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _loadEntries();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _loadEntries(),
            ),
            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                        _loadEntries();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Results List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _entries.isEmpty
                      ? const Center(child: Text("No dictionary entries found.", style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, i) {
                            final row = _entries[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(row.english, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.veryLightGreen,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(row.category ?? 'General', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Hindi: ${row.hindi}", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(row.santali, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                                        if (row.santaliRoman != null) ...[
                                          Text("Pronunciation: ${row.santaliRoman}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                                    onPressed: () {
                                      TtsService.instance.speak(text: row.santali, langCode: 'sat');
                                    },
                                  ),
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
