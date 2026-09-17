import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/translation/screens/text_to_text_screen.dart';
import 'features/speech_to_speech/screens/s2s_screen.dart';
import 'features/speech_to_text/screens/stt_screen.dart';
import 'features/text_to_speech/screens/tts_screen.dart';
import 'features/ocr/screens/ocr_screen.dart';
import 'features/video_subtitle/screens/video_subtitle_screen.dart';
import 'features/learning_studio/screens/learning_studio_screen.dart';
import 'features/field_mode/screens/field_mode_screen.dart';
import 'features/teacher_mode/screens/teacher_mode_screen.dart';
import 'features/emergency_mode/screens/emergency_mode_screen.dart';
import 'features/dictionary/screens/dictionary_screen.dart';
import 'features/knowledge_base/screens/knowledge_base_screen.dart';
import 'features/about/screens/about_screen.dart';
import 'features/contact/screens/contact_screen.dart';
import 'features/privacy/screens/privacy_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/vaani_stream/screens/vaani_stream_screen.dart';

class BhashaSetuApp extends StatelessWidget {
  const BhashaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bhasha Setu (भाषा | SETU)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        // Landing & Home
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),

        // Core Translation & Media AI
        '/features/text-to-text': (context) => const TextToTextScreen(),
        '/features/speech-to-speech': (context) => const SpeechToSpeechScreen(),
        '/conversation': (context) => const SpeechToSpeechScreen(),
        '/features/speech-to-text': (context) => const SpeechToTextScreen(),
        '/features/text-to-speech': (context) => const TextToSpeechScreen(),
        '/features/ocr': (context) => const OcrScreen(),
        '/features/video-subtitle': (context) => const VideoSubtitleScreen(),

        // Pedagogical & Operational Modes
        '/features/learning-studio': (context) => const LearningStudioScreen(),
        '/learning-studio': (context) => const LearningStudioScreen(),
        '/field-mode': (context) => const FieldModeScreen(),
        '/teacher-mode': (context) => const TeacherModeScreen(),
        '/emergency-mode': (context) => const EmergencyModeScreen(),

        // Lexicons & Resources
        '/resources/dictionary': (context) => const DictionaryScreen(),
        '/resources/knowledge-base': (context) => const KnowledgeBaseScreen(),
        '/vaani-stream': (context) => const VaaniStreamScreen(),

        // Info & Legal
        '/about-us': (context) => const AboutScreen(),
        '/contact-us': (context) => const ContactScreen(),
        '/privacy-policy': (context) => const PrivacyScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
