import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/database/database_service.dart';
import 'services/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-warm local SQLite database & API config in background
  try {
    await DatabaseService.instance.database;
    await ApiClient.instance.init();
  } catch (e) {
    debugPrint("Background initialization error: $e");
  }

  runApp(const BhashaSetuApp());
}
