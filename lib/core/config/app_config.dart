import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String _defaultBackendUrl = 'http://192.168.1.40:8080';

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get backendUrl =>
      dotenv.env['BACKEND_URL']?.trim().isNotEmpty == true
      ? dotenv.env['BACKEND_URL']!.trim()
      : _defaultBackendUrl;
  // App settings
  static const String appName = 'Scifit App';
  static const Duration splashDuration = Duration(seconds: 2);
}
