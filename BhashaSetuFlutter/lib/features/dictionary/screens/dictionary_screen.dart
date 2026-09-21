import 'package:flutter/material.dart';
import '../../../data/models/translation_row.dart';
import '../../../services/database/database_service.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class FeaturedDictionaryResource {
  final String title;
  final String language;
  final String description;
  final int totalPages;

  const FeaturedDictionaryResource({
    required this.title,
    required this.language,
    required this.description,
    required this.totalPages,
  });
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedLanguage = 'All';
  List<TranslationRow> _entries = [];
  final Set<String> _bookmarks = {};
  bool _isLoading = true;
  int _totalRows = 6780;
  int _currentPage = 1;
  static const int _itemsPerPage = 16;

  final List<FeaturedDictionaryResource> _featuredResources = const [
    FeaturedDictionaryResource(
      title: 'Hakkipikki–Kannada–English Dictionary',
      language: 'Kannada',
      description: 'Comprehensive trilingual vocabulary and phonetic grammar for the nomadic Hakki Pikki community.',
      totalPages: 320,
    ),
    FeaturedDictionaryResource(
      title: 'Language Dictionaries TRI',
      language: 'Indigenous',
      description: 'Official Tribal Research Institute (TRI) comparative lexicon covering central and eastern tribal belts.',
      totalPages: 480,
    ),
    FeaturedDictionaryResource(
      title: 'Tangkhul Naga Grammar and Dictionary',
      language: 'Tangkhul Naga',
      description: 'Comprehensive grammar, etymology, and morphological guide for the Tangkhul Naga language.',
      totalPages: 290,
    ),
    FeaturedDictionaryResource(
      title: 'प्रकाशन का विवरण',
      language: 'Hindi',
      description: 'National publication details, linguistic classification, and state-wise tribal dialect glossaries.',
      totalPages: 164,
    ),
  ];

  final List<String> _categories = [
    'All Categories',
    'Classroom',
    'Education',
    'Healthcare',
    'Agriculture',
    'Animal',
    'Nature',
    'Administration',
    'Family',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final categoryFilter = _selectedCategory == 'All Categories' ? 'All' : _selectedCategory;
    final rows = await DatabaseService.instance.searchClassroomSentences(
      keyword: _searchController.text.trim(),
      category: categoryFilter,
      limit: 100,
    );
    final stats = await DatabaseService.instance.getStats();
    setState(() {
      _entries = rows;
      _totalRows = stats['totalRows'] ?? 6780;
      _isLoading = false;
    });
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarks.contains(id)) {
        _bookmarks.remove(id);
      } else {
        _bookmarks.add(id);
      }
    });
  }

  void _showContributeDialog() {
    final wordController = TextEditingController();
    final scriptController = TextEditingController();
    final meaningEnController = TextEditingController();
    final meaningHiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Contribute Tribal Word", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Help build the community-verified indigenous dictionary.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(labelText: "English Word", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scriptController,
                  decoration: const InputDecoration(labelText: "Native Script (Ol Chiki / Devanagari)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: meaningEnController,
                  decoration: const InputDecoration(labelText: "English Definition", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: meaningHiController,
                  decoration: const InputDecoration(labelText: "Hindi Meaning", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Thank you! Your contribution was submitted for linguist verification."),
                    backgroundColor: Color(0xFF249144),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF249144),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < _entries.length) ? startIndex + _itemsPerPage : _entries.length;
    final paginatedList = _entries.isNotEmpty && startIndex < _entries.length
        ? _entries.sublist(startIndex, endIndex)
        : _entries;
    final totalPages = (_entries.length / _itemsPerPage).ceil().clamp(1, 9999);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
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
                      // Section Header
                      Column(
                        children: [
                          const Text(
                            "Dictionary",
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              width: 140,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF249144),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Explore our collection of multilingual dictionaries and linguistic resources for indigenous languages",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Featured Dictionaries Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 2 : 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isWide ? 2.3 : 2.5,
                            ),
                            itemCount: _featuredResources.length,
                            itemBuilder: (context, i) {
                              final res = _featuredResources[i];
                              return Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF249144), size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                            child: Text(res.language.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(res.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(res.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Interactive Searchable Lexicon Explorer
                      Container(
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Searchable Lexicon & Word Bank",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Look up individual tribal words, definitions, and IPA phonetics",
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showContributeDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF249144),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                  label: const Text("Contribute Word", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Search Bar & Language Dropdown
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: "Search 6,800+ words/sentences in English, Hindi, or Ol Chiki...",
                                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.close_rounded, size: 18),
                                              onPressed: () {
                                                _searchController.clear();
                                                _loadEntries();
                                              },
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    onChanged: (_) {
                                      setState(() => _currentPage = 1);
                                      _loadEntries();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedLanguage,
                                      items: const [
                                        DropdownMenuItem(value: 'All', child: Text("All Languages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                                        DropdownMenuItem(value: 'Santali', child: Text("Santali", style: TextStyle(fontSize: 12.5))),
                                        DropdownMenuItem(value: 'Hindi', child: Text("Hindi", style: TextStyle(fontSize: 12.5))),
                                        DropdownMenuItem(value: 'English', child: Text("English", style: TextStyle(fontSize: 12.5))),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedLanguage = val);
                                          _loadEntries();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Category Filter Pills
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((cat) {
                                  final isSelected = _selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = cat;
                                          _currentPage = 1;
                                        });
                                        _loadEntries();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF249144) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Results Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Showing ${startIndex + 1}–$endIndex of $_totalRows entries",
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  "Page $_currentPage of $totalPages",
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

                            // Word Cards Grid
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF249144))),
                              )
                            else if (paginatedList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(child: Text("No dictionary entries found.", style: TextStyle(color: Color(0xFF94A3B8)))),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: paginatedList.length,
                                itemBuilder: (context, i) {
                                  final row = paginatedList[i];
                                  final isBookmarked = _bookmarks.contains(row.id.toString());
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: const Color(0xFFF1F5F9)),
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
                                                  Text(row.english, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(6)),
                                                    child: Text(row.category ?? 'General', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                row.santali,
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14532D)),
                                              ),
                                              if (row.santaliRoman != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Phonetic: ${row.santaliRoman}",
                                                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontFamily: 'monospace'),
                                                ),
                                              ],
                                              const SizedBox(height: 4),
                                              Text("Hindi: ${row.hindi}", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: isBookmarked ? const Color(0xFF249144) : const Color(0xFF94A3B8)),
                                              onPressed: () => _toggleBookmark(row.id.toString()),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF059669)),
                                              onPressed: () => TtsService.instance.speak(text: row.santali, langCode: 'sat'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            // Pagination Controls
                            if (totalPages > 1) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                                  ),
                                  Text("Page $_currentPage of $totalPages", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded),
                                    onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
    );
  }
}
