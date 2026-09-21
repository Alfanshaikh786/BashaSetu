import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/translation_row.dart';
import '../../../services/database/database_service.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  List<TranslationRow> _phrases = [];
  bool _isLoading = true;
  String? _copiedId;
  int _currentPage = 1;
  static const int _itemsPerPage = 16;
  int _totalPhrases = 6780;

  final List<String> _categories = [
    'All Categories',
    'Classroom',
    'Education',
    'Healthcare',
    'Agriculture',
    'Animal',
    'Nature',
    'Emergency',
    'Administration',
    'Family',
  ];

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPhrases() async {
    setState(() => _isLoading = true);
    final cat = _selectedCategory == 'All Categories' ? 'All' : _selectedCategory;
    final rows = await DatabaseService.instance.searchClassroomSentences(
      keyword: _searchController.text.trim(),
      category: cat,
      limit: 100,
    );
    final stats = await DatabaseService.instance.getStats();
    setState(() {
      _phrases = rows;
      _totalPhrases = stats['totalRows'] ?? 6780;
      _isLoading = false;
    });
  }

  void _handleCopy(String text, String id) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedId = id);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copiedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < _phrases.length) ? startIndex + _itemsPerPage : _phrases.length;
    final paginatedList = _phrases.isNotEmpty && startIndex < _phrases.length
        ? _phrases.sublist(startIndex, endIndex)
        : _phrases;
    final totalPages = (_phrases.length / _itemsPerPage).ceil().clamp(1, 9999);

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
                      // Header Bar
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0xFFDCFCE7)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.verified_user_rounded, color: Color(0xFF249144), size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        "Verified Language Knowledge Base",
                                        style: TextStyle(color: Color(0xFF14532D), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Verified Tribal Lexicon & Phrases",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.4),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Explore 6,780 parallel verified records categorized across 12 educational and field domains.",
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "$_totalPhrases Phrases Available",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Search & Filter Controls
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Search Input
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search by English, Hindi, Ol Chiki script, or Roman phonetic...",
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          _loadPhrases();
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
                                _loadPhrases();
                              },
                            ),
                            const SizedBox(height: 12),

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
                                        _loadPhrases();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF249144) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: isSelected ? const Color(0xFF249144) : const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            color: isSelected ? Colors.white : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phrases Grid
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF249144))),
                        )
                      else if (paginatedList.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 12),
                              Text("No verified phrases matched your search.", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                              SizedBox(height: 4),
                              Text("Try searching for keywords like 'hospital', 'book', 'water', or 'school'.", style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 720;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: isWide ? 2.0 : 2.2,
                              ),
                              itemCount: paginatedList.length,
                              itemBuilder: (context, i) {
                                final p = paginatedList[i];
                                final id = p.id.toString();
                                final isCopied = _copiedId == id;
                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Top Category & Status
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                            child: Text(p.category ?? 'General', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                          ),
                                          Row(
                                            children: const [
                                              Icon(Icons.check, size: 12, color: Color(0xFF047857)),
                                              SizedBox(width: 4),
                                              Text("100% Verified", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Santali Ol Chiki Script & Listen
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.santali,
                                                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.3),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (p.santaliRoman != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Phonetic: ${p.santaliRoman}",
                                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontFamily: 'monospace'),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF059669)),
                                                onPressed: () => TtsService.instance.speak(text: p.santali, langCode: 'sat'),
                                              ),
                                              IconButton(
                                                icon: Icon(isCopied ? Icons.check : Icons.copy_rounded, size: 18, color: isCopied ? const Color(0xFF059669) : const Color(0xFF94A3B8)),
                                                onPressed: () => _handleCopy("${p.santali}\n${p.hindi}\n${p.english}", id),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Parallel Hindi & English
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFF1F5F9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                                                children: [
                                                  const TextSpan(text: "Hindi: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                                  TextSpan(text: p.hindi),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text.rich(
                                              TextSpan(
                                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                                                children: [
                                                  const TextSpan(text: "English: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                                  TextSpan(text: p.english),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
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

                      // Pagination Controls
                      if (totalPages > 1) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Page $_currentPage of $totalPages (${_phrases.length} entries)", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded),
                                    onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
