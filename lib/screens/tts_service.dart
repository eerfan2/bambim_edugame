import 'package:flutter_tts/flutter_tts.dart';

/// ============================================================
/// SERVICE: TtsService (Text-to-Speech)
/// ============================================================
/// Singleton yang mengelola semua fitur audio pembelajaran.
///
/// Cara pakai:
///   await TtsService.instance.speak('Ayam');
///   await TtsService.instance.speakHuruf('A');
///   await TtsService.instance.stop();
///
/// Fitur:
///   - Bahasa Indonesia otomatis
///   - Kecepatan bicara lambat (cocok untuk anak)
///   - Volume & pitch optimal untuk pembelajaran
///   - Method khusus: huruf, kata, kalimat instruksi
/// ============================================================
class TtsService {
  // ---- SINGLETON PATTERN ----
  static final TtsService _instance = TtsService._internal();
  static TtsService get instance => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  // ============================================================
  // INISIALISASI — panggil sekali di main() atau saat app start
  // ============================================================
  Future<void> init() async {
    if (_initialized) return;

    // Bahasa Indonesia
    await _tts.setLanguage('id-ID');

    // Kecepatan bicara: 0.4 = lambat, cocok untuk anak belajar
    // Range: 0.0 (sangat lambat) - 1.0 (sangat cepat)
    await _tts.setSpeechRate(0.4);

    // Volume penuh
    await _tts.setVolume(1.0);

    // Pitch sedikit tinggi → terdengar lebih ceria & ramah anak
    // Range: 0.5 (rendah) - 2.0 (tinggi), default 1.0
    await _tts.setPitch(1.1);

    // Callback saat TTS mulai & selesai berbicara
    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _initialized = true;
  }

  // ============================================================
  // SPEAK — ucapkan teks apapun
  // ============================================================
  Future<void> speak(String text) async {
    if (!_initialized) await init();
    if (text.trim().isEmpty) return;

    // Stop dulu jika sedang berbicara
    await stop();
    await _tts.speak(text);
  }

  // ============================================================
  // SPEAK HURUF — ucapkan satu huruf dengan konteks
  // Contoh: 'A' → "Huruf A, A seperti Ayam"
  // ============================================================
  Future<void> speakHuruf(String huruf, {String? contohKata}) async {
    if (!_initialized) await init();
    await stop();

    String teks;
    if (contohKata != null) {
      // Ejaan huruf + kata contoh
      // Contoh: "Huruf A, A seperti Ayam"
      teks = 'Huruf $huruf. $huruf, seperti $contohKata';
    } else {
      teks = 'Huruf $huruf';
    }

    await _tts.speak(teks);
  }

  // ============================================================
  // SPEAK KATA — ucapkan satu kata dengan pengejaan
  // Contoh: 'AYAM' → "Ayam. A - Y - A - M. Ayam."
  // ============================================================
  Future<void> speakKata(String kata) async {
    if (!_initialized) await init();
    await stop();

    // Eja huruf per huruf dengan jeda titik
    // Contoh: AYAM → "A. Y. A. M"
    final ejaan = kata.split('').join('. ');

    // Format: Kata → Ejaan huruf per huruf → Kata lagi
    final teks = '$kata. $ejaan. $kata.';
    await _tts.speak(teks);
  }

  // ============================================================
  // SPEAK INSTRUKSI — ucapkan kalimat instruksi game
  // ============================================================
  Future<void> speakInstruksi(String instruksi) async {
    if (!_initialized) await init();
    await stop();

    // Kecepatan sedikit lebih cepat untuk instruksi
    await _tts.setSpeechRate(0.45);
    await _tts.speak(instruksi);
    // Kembalikan ke kecepatan default
    await _tts.setSpeechRate(0.4);
  }

  // ============================================================
  // SPEAK FEEDBACK — ucapkan feedback benar/salah
  // ============================================================
  Future<void> speakBenar() async {
    await speak('Hebat! Jawabanmu benar!');
  }

  Future<void> speakSalah() async {
    await speak('Coba lagi ya!');
  }

  // ============================================================
  // STOP — hentikan TTS yang sedang berjalan
  // ============================================================
  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  // ============================================================
  // DISPOSE — bersihkan resource
  // ============================================================
  Future<void> dispose() async {
    await stop();
    await _tts.stop();
  }
}
