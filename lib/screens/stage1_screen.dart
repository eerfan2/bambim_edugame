import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'tts_service.dart'; // ✅ BARU
import 'hasil_screen.dart';

/// Stage 1 — Tebak Huruf
/// ✅ FIX: Skor sekarang disimpan via DataService.simpanSkorStage()
/// ✅ BARU: Integrasi TTS untuk audio huruf dan feedback
class Stage1Screen extends StatefulWidget {
  const Stage1Screen({super.key});
  @override
  State<Stage1Screen> createState() => _Stage1ScreenState();
}

class _Stage1ScreenState extends State<Stage1Screen>
    with SingleTickerProviderStateMixin {
  static const List<Map<String, dynamic>> _soalList = [
    {
      'huruf': 'A',
      'emoji': '🐔',
      'contoh': 'Ayam',
      'pilihan': ['A', 'B', 'C'],
      'benar': 0
    },
    {
      'huruf': 'D',
      'emoji': '🍭',
      'contoh': 'Donat',
      'pilihan': ['B', 'D', 'E'],
      'benar': 1
    },
    {
      'huruf': 'G',
      'emoji': '🐘',
      'contoh': 'Gajah',
      'pilihan': ['F', 'H', 'G'],
      'benar': 2
    },
    {
      'huruf': 'K',
      'emoji': '🐰',
      'contoh': 'Kelinci',
      'pilihan': ['K', 'L', 'M'],
      'benar': 0
    },
    {
      'huruf': 'S',
      'emoji': '🐄',
      'contoh': 'Sapi',
      'pilihan': ['R', 'T', 'S'],
      'benar': 2
    },
  ];

  int _soalIndex = 0;
  int _nyawa = 3;
  int _skor = 0;
  int? _pilihanUser;
  bool? _statusJawaban;
  bool _sudahJawab = false;

  // ✅ BARU: Cegah tombol TTS ditekan berkali-kali
  bool _isSpeaking = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // ✅ BARU: Ucapkan instruksi soal pertama saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ucapkanSoal(_soalList[0]);
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    // ✅ BARU: Stop TTS saat screen ditutup
    TtsService.instance.stop();
    super.dispose();
  }

  // ============================================================
  // ✅ BARU: Ucapkan soal (huruf + kata contoh)
  // ============================================================
  Future<void> _ucapkanSoal(Map<String, dynamic> soal) async {
    if (_isSpeaking) return;
    setState(() => _isSpeaking = true);

    // Ucapkan huruf beserta kata contoh
    // Contoh: "Huruf A. A, seperti Ayam"
    await TtsService.instance.speakHuruf(
      soal['huruf'] as String,
      contohKata: soal['contoh'] as String,
    );

    if (mounted) setState(() => _isSpeaking = false);
  }

  // ============================================================
  // Logika menjawab soal
  // ============================================================
  void _pilih(int i) {
    if (_sudahJawab) return;
    final benar = i == (_soalList[_soalIndex]['benar'] as int);
    setState(() {
      _pilihanUser = i;
      _statusJawaban = benar;
      _sudahJawab = true;
      if (benar) {
        _skor += 20;
        // ✅ BARU: Ucapkan feedback benar
        TtsService.instance.speakBenar();
      } else {
        _nyawa--;
        _shakeCtrl.forward(from: 0);
        // ✅ BARU: Ucapkan feedback salah
        TtsService.instance.speakSalah();
      }
    });
  }

  void _konfirmasi() {
    if (_pilihanUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih jawaban dulu ya! 😊'),
          backgroundColor: Color(0xFFFF8C00),
          duration: Duration(seconds: 1)));
      return;
    }
    if (!_sudahJawab) {
      _pilih(_pilihanUser!);
      return;
    }

    if (_nyawa <= 0 || _soalIndex >= _soalList.length - 1) {
      _keHasil();
      return;
    }

    setState(() {
      _soalIndex++;
      _pilihanUser = null;
      _statusJawaban = null;
      _sudahJawab = false;
    });

    // ✅ BARU: Ucapkan soal berikutnya
    _ucapkanSoal(_soalList[_soalIndex]);
  }

  // ============================================================
  // ✅ FIX: Simpan skor ke DataService sebelum ke HasilScreen
  // ============================================================
  Future<void> _keHasil() async {
    // Simpan skor ke SharedPreferences via DataService
    // Ini yang sebelumnya TIDAK dilakukan, sehingga skor tidak tersimpan!
    await DataService.instance.simpanSkorStage(1, _skor);

    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => HasilScreen(skor: _skor, stageNomor: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final soal = _soalList[_soalIndex];
    final progress = (_soalIndex + (_sudahJawab ? 1 : 0)) / _soalList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF4ECDC4),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Stage 1',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Soal ${_soalIndex + 1}/${_soalList.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white))),
                    ])),
                const SizedBox(width: 14),
                Row(
                    children: List.generate(
                        3,
                        (i) => Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                  color: i < _nyawa
                                      ? const Color(0xFFFF6B6B)
                                      : Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                            ))),
              ]),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Area soal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ]),
              child: Column(children: [
                const Text('Huruf apakah ini?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF636E72))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // ✅ BARU: Tombol TTS dengan animasi loading
                  GestureDetector(
                    onTap: _isSpeaking ? null : () => _ucapkanSoal(soal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: _isSpeaking
                              ? const Color(0xFF4ECDC4).withOpacity(0.3)
                              : const Color(0xFF4ECDC4).withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF4ECDC4), width: 2)),
                      child: Center(
                        child: _isSpeaking
                            // Animasi loading saat TTS berbicara
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Color(0xFF4ECDC4)))
                            : const Icon(Icons.volume_up_rounded,
                                color: Color(0xFF4ECDC4), size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                        offset: Offset(_shakeAnim.value, 0), child: child),
                    child: Container(
                      width: 120,
                      height: 100,
                      decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF4ECDC4).withOpacity(0.4),
                              width: 2)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(soal['emoji'] as String,
                                style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 4),
                            Text(soal['contoh'] as String,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3436))),
                          ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                // ✅ UPDATE: Label tombol lebih informatif
                Text(
                  _isSpeaking
                      ? 'Sedang berbicara...'
                      : 'Ketuk 🔊 untuk mendengarkan',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Feedback
            if (_statusJawaban != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: (_statusJawaban!
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C))
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _statusJawaban!
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C),
                      width: 1.5),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_statusJawaban! ? '🎉' : '😅',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Text(
                          _statusJawaban!
                              ? 'Benar! +20 poin'
                              : 'Salah! Coba lagi',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _statusJawaban!
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFFC0392B))),
                    ]),
              ),

            const Spacer(),

            // Pilihan
            _buildPilihan(soal),
            const SizedBox(height: 20),

            // Tombol jawab
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _konfirmasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pilihanUser != null
                      ? const Color(0xFF4ECDC4)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: _pilihanUser != null ? 4 : 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  !_sudahJawab
                      ? 'JAWAB'
                      : (_nyawa <= 0 || _soalIndex >= _soalList.length - 1)
                          ? 'LIHAT HASIL'
                          : 'LANJUT ▶',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPilihan(Map<String, dynamic> soal) {
    final pilihan = soal['pilihan'] as List<String>;
    final indexBenar = soal['benar'] as int;
    return Row(
        children: List.generate(pilihan.length, (i) {
      Color warna, border, text;
      if (!_sudahJawab) {
        warna = _pilihanUser == i
            ? const Color(0xFF4ECDC4).withOpacity(0.15)
            : Colors.white;
        border =
            _pilihanUser == i ? const Color(0xFF4ECDC4) : Colors.grey[300]!;
        text = const Color(0xFF2D3436);
      } else if (i == indexBenar) {
        warna = const Color(0xFF2ECC71).withOpacity(0.15);
        border = const Color(0xFF2ECC71);
        text = const Color(0xFF27AE60);
      } else if (i == _pilihanUser && _pilihanUser != indexBenar) {
        warna = const Color(0xFFE74C3C).withOpacity(0.12);
        border = const Color(0xFFE74C3C);
        text = const Color(0xFFC0392B);
      } else {
        warna = Colors.white;
        border = Colors.grey[200]!;
        text = Colors.grey[400]!;
      }
      return Expanded(
          child: GestureDetector(
        onTap: () => _pilih(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(left: i == 0 ? 0 : 8),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 2),
              boxShadow: [
                BoxShadow(
                    color: border.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ]),
          child: Center(
              child: Text(pilihan[i],
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: text))),
        ),
      ));
    }));
  }
}
