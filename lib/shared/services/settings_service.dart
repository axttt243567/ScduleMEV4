import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Gemini API Key
  static const String _geminiApiKeyKey = 'gemini_api_key';

  Future<void> saveGeminiApiKey(String key) async {
    if (_prefs == null) await init();
    await _prefs!.setString(_geminiApiKeyKey, key);
  }

  Future<String?> getGeminiApiKey() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_geminiApiKeyKey);
  }

  // Add other settings here as needed (e.g. theme, onboarding, etc.)
}
