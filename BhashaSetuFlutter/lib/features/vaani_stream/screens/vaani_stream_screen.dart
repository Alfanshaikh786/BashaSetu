import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class VaaniStreamScreen extends StatefulWidget {
  const VaaniStreamScreen({super.key});

  @override
  State<VaaniStreamScreen> createState() => _VaaniStreamScreenState();
}

class _VaaniStreamScreenState extends State<VaaniStreamScreen> {
  final List<Map<String, String>> _episodes = [
    {
      'title': 'The Legend of Marang Buru and Sacred Trees',
      'language': 'Santali',
      'category': 'Folklore',
      'duration': '4:15',
      'satText': 'ᱢᱟᱨᱟᱝ ᱵᱩᱨᱩ ᱟᱨ ᱡᱟᱦᱮᱨ ᱛᱷᱟᱱ ᱨᱮᱭᱟᱜ ᱠᱟᱛᱷᱟ ᱾ ᱟᱵᱚᱣᱟᱜ ᱫᱟᱨᱮ ᱱᱟᱹᱲᱤ ᱫᱚ ᱡᱤᱣᱤ ᱠᱟᱱᱟ ᱾',
      'hiDesc': 'मरांग बुरु और पवित्र जाहेर थान की कथा। प्रकृति संरक्षण का महत्व।',
    },
    {
      'title': 'Birsa Munda and the Ulgulan Movement',
      'language': 'Mundari / Hindi',
      'category': 'History',
      'duration': '6:30',
      'satText': 'ᱵᱤᱨᱥᱟᱹ ᱢᱩᱱᱰᱟ ᱟᱜ ᱩᱞᱜᱩᱞᱟᱱ ᱞᱟᱹᱲᱦᱟᱹᱭ ᱟᱨ ᱡᱟᱹᱛᱤᱭᱟᱹᱨᱤ ᱢᱟᱹᱱ ᱾',
      'hiDesc': 'भगवान बिरसा मुंडा और उलगुलान आंदोलन की प्रेरक गाथा।',
    },
    {
      'title': 'Monsoon Health & Clean Drinking Water Guidelines',
      'language': 'Santali',
      'category': 'Healthcare',
      'duration': '3:45',
      'satText': 'ᱫᱟᱜ ᱫᱤᱱ ᱨᱮ ᱨᱩᱣᱟᱹ ᱠᱷᱚᱱ ᱵᱟᱧᱪᱟᱣ ᱛᱟᱦᱮᱸᱱ ᱞᱟᱹᱜᱤᱫ ᱥᱟᱯᱷᱟ ᱫᱟᱜ ᱧᱩᱭ ᱯᱮ ᱾',
      'hiDesc': 'बरसात के मौसम में पानी उबाल कर पीने और मलेरिया से बचाव के निर्देश।',
    },
  ];

  int? _playingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.podcasts_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Vaani Stream (वाणी प्रवाह)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("Community radio broadcasts, folklore & health updates", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            ..._episodes.asMap().entries.map((entry) {
              final idx = entry.key;
              final ep = entry.value;
              final isPlaying = _playingIndex == idx;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isPlaying ? AppColors.primary : AppColors.border, width: isPlaying ? 1.5 : 1),
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
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${ep['category']} • ${ep['language']}",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ),
                        Text(ep['duration']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(ep['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(ep['hiDesc']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isPlaying) {
                              TtsService.instance.stop();
                              setState(() => _playingIndex = null);
                            } else {
                              setState(() => _playingIndex = idx);
                              TtsService.instance.speak(text: ep['satText']!, langCode: 'sat');
                            }
                          },
                          icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                          label: Text(isPlaying ? "Stop Broadcast" : "Listen in Native Audio"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
