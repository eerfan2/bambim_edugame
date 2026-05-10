import 'package:flutter/material.dart';
import 'dart:math';
import '../services/data_service.dart';
import 'tts_service.dart';
import 'hasil_screen.dart';

/// Stage 2 — Susun Kata (tap huruf, validasi string)
/// ✅ FIX: Skor sekarang disimpan via DataService.simpanSkorStage()
/// ✅ BARU: Integrasi TTS untuk audio kata dan feedback
class Stage2Screen extends StatefulWidget {
  const Stage2Screen({super.key});
  @override
  State<Stage2Screen> createState() => _Stage2ScreenState();
}

class _Stage2ScreenState extends State<Stage2Screen>
    with SingleTickerProviderStateMixin {
  static const List<Map<String, dynamic>> _soalList = [
    {'kata': 'AYAM', 'emoji': '🐔', 'label': 'Ayam'},
    {'kata': 'BOLA', 'emoji': '⚽', 'label': 'Bola'},
    {'kata': 'IKAN', 'emoji': '🐟', 'label': 'Ikan'},
    {'kata': 'APEL', 'emoji': '🍎', 'label': 'Apel'},
    {'kata': 'BEBEK', 'emoji': '🦆', 'label': 'Bebek'},
  ];

  int _soalIndex = 0;
  int _skor = 0;
  int _nyawa = 3;
  List<Map<String, dynamic>> _hurufAcak = [];
  List<Map<String, dynamic>> _jawaban = [];
  bool? _statusBenar;
  bool _sudahCek = false;

  // ✅ BARU: Cegah tombol TTS ditekan berkali-kali
  bool _isSpeaking = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _muatSoal();

    // ✅ BARU: Ucapkan instruksi & soal pertama saat screen dibuka
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
  // ✅ BARU: Ucapkan soal (kata + ejaannya)
  // ============================================================
  Future<void> _ucapkanSoal(Map<String, dynamic> soal) async {
    if (_isSpeaking) return;
    setState(() => _isSpeaking = true);

    // Ucapkan kata beserta ejaannya huruf per huruf
    // Contoh: "Ayam. A. Y. A. M. Ayam."
    await TtsService.instance.speakKata(soal['label'] as String);

    if (mounted) setState(() => _isSpeaking = false);
  }

  // ============================================================
  // Logika muat & susun soal
  // ============================================================
  void _muatSoal() {
    final huruf = (_soalList[_soalIndex]['kata'] as String).split('');
    huruf.shuffle(Random());
    setState(() {
      _hurufAcak = huruf
          .asMap()
          .entries
          .map((e) => {'id': e.key, 'huruf': e.value, 'dipilih': false})
          .toList();
      _jawaban = [];
      _statusBenar = null;
      _sudahCek = false;
    });
  }

  void _pilihHuruf(int id, String huruf) {
    if (_sudahCek && _statusBenar == true) return;
    final panjang = (_soalList[_soalIndex]['kata'] as String).length;
    if (_jawaban.length >= panjang) return;
    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = true;
      _jawaban.add({'id': id, 'huruf': huruf});
      if (_sudahCek) {
        _statusBenar = null;
        _sudahCek = false;
      }
    });
  }

  void _batalHuruf(int id) {
    if (_statusBenar == true) return;
    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = false;
      _jawaban.removeWhere((h) => h['id'] == id);
      _statusBenar = null;
      _sudahCek = false;
    });
  }

  void _cekJawaban() {
    final kataBenar = _soalList[_soalIndex]['kata'] as String;
    final kataUser = _jawaban.map((h) => h['huruf']).join('');
    final benar = kataUser == kataBenar;
    setState(() {
      _statusBenar = benar;
      _sudahCek = true;
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

  void _tombolJawab() {
    final panjang = (_soalList[_soalIndex]['kata'] as String).length;
    if (_jawaban.length < panjang) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lengkapi semua hurufnya dulu! 🤔'),
          backgroundColor: Color(0xFFFF8C00),
          duration: Duration(seconds: 1)));
      return;
    }
    if (!_sudahCek) {
      _cekJawaban();
      return;
    }
    if (_nyawa <= 0) {
      _keHasil();
      return;
    }
    if (_statusBenar == true) {
      if (_soalIndex >= _soalList.length - 1) {
        _keHasil();
        return;
      }
      setState(() => _soalIndex++);
      _muatSoal();
      // ✅ BARU: Ucapkan soal berikutnya
      _ucapkanSoal(_soalList[_soalIndex]);
    } else {
      _muatSoal();
    }
  }

  // ============================================================
  // ✅ FIX: Simpan skor ke DataService sebelum ke HasilScreen
  // ============================================================
  Future<void> _keHasil() async {
    // Simpan skor ke SharedPreferences via DataService
    // Ini yang sebelumnya TIDAK dilakukan!
    await DataService.instance.simpanSkorStage(2, _skor);

    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => HasilScreen(skor: _skor, stageNomor: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final soal = _soalList[_soalIndex];
    final panjang = (soal['kata'] as String).length;
    final progress =
        (_soalIndex + (_sudahCek && _statusBenar == true ? 1 : 0)) /
            _soalList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFFFFD93D),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Stage 2',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Kartu gambar + tombol TTS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dengarkan kata ini',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                      // ✅ UPDATE: Tombol TTS dengan animasi loading
                      GestureDetector(
                        onTap: _isSpeaking ? null : () => _ucapkanSoal(soal),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: _isSpeaking
                                  ? const Color(0xFFFFD93D).withOpacity(0.3)
                                  : const Color(0xFFFFD93D).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFFD93D), width: 1.5)),
                          child: _isSpeaking
                              ? const SizedBox(
                                  width: 60,
                                  height: 18,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFD4A017)),
                                      ),
                                      SizedBox(width: 6),
                                      Text('...',
                                          style: TextStyle(
                                              color: Color(0xFFD4A017),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ))
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      Icon(Icons.play_arrow_rounded,
                                          color: Color(0xFFD4A017), size: 18),
                                      SizedBox(width: 4),
                                      Text('Play',
                                          style: TextStyle(
                                              color: Color(0xFFD4A017),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                        ),
                      ),
                    ]),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D).withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFFFD93D).withOpacity(0.5),
                          width: 2.5)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(soal['emoji'] as String,
                            style: const TextStyle(fontSize: 50)),
                        const SizedBox(height: 4),
                        Text(soal['label'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436))),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Kotak jawaban
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0), child: child),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(panjang, (i) {
                  final ada = i < _jawaban.length;
                  Color border, bg;
                  if (!_sudahCek || !ada) {
                    border = ada ? const Color(0xFFFFD93D) : Colors.grey[300]!;
                    bg = ada
                        ? const Color(0xFFFFD93D).withOpacity(0.12)
                        : Colors.grey[100]!;
                  } else if (_statusBenar == true) {
                    border = const Color(0xFF2ECC71);
                    bg = const Color(0xFF2ECC71).withOpacity(0.12);
                  } else {
                    border = const Color(0xFFE74C3C);
                    bg = const Color(0xFFE74C3C).withOpacity(0.1);
                  }
                  return GestureDetector(
                    onTap: ada ? () => _batalHuruf(_jawaban[i]['id']) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: 2)),
                      child: Center(
                          child: ada
                              ? Text(_jawaban[i]['huruf'] as String,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: _sudahCek
                                          ? (_statusBenar == true
                                              ? const Color(0xFF27AE60)
                                              : const Color(0xFFC0392B))
                                          : const Color(0xFF2D3436)))
                              : Text('_',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.bold))),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Instruksi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFF8C00).withOpacity(0.3))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('💡', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text('Susun huruf menjadi kata yang benar',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B5200),
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 14),

            // Huruf acak
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _hurufAcak.map((item) {
                final dipilih = item['dipilih'] as bool;
                return GestureDetector(
                  onTap: dipilih
                      ? null
                      : () => _pilihHuruf(item['id'], item['huruf'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: dipilih
                          ? Colors.grey[200]
                          : const Color(0xFFFFD93D).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: dipilih
                              ? Colors.grey[300]!
                              : const Color(0xFFFFD93D),
                          width: 2),
                      boxShadow: dipilih
                          ? []
                          : [
                              BoxShadow(
                                  color:
                                      const Color(0xFFFFD93D).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3))
                            ],
                    ),
                    child: Center(
                        child: Text(dipilih ? '' : item['huruf'] as String,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: dipilih
                                    ? Colors.grey[300]
                                    : const Color(0xFF2D3436)))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Feedback
            if (_sudahCek)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: (_statusBenar!
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C))
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _statusBenar!
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C),
                      width: 1.5),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_statusBenar! ? '🎉' : '😅',
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _statusBenar!
                                    ? 'Benar! +20 poin'
                                    : 'Coba Lagi!',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _statusBenar!
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFC0392B))),
                            Text(
                                _statusBenar!
                                    ? 'Lanjut ke soal berikutnya!'
                                    : (_nyawa > 0
                                        ? 'Susun ulang hurufnya ya!'
                                        : 'Nyawa habis...'),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _statusBenar!
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFC0392B))),
                          ]),
                    ]),
              ),
            const SizedBox(height: 16),

            // Tombol jawab
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _tombolJawab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_sudahCek
                      ? (_jawaban.length == panjang
                          ? const Color(0xFFFFD93D)
                          : Colors.grey[300])
                      : (_statusBenar == true
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C)),
                  foregroundColor: Colors.white,
                  elevation: _jawaban.length == panjang ? 4 : 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  !_sudahCek
                      ? 'Jawab'
                      : _statusBenar == true
                          ? (_soalIndex >= _soalList.length - 1
                              ? 'Lihat Hasil 🏆'
                              : 'Lanjut ▶')
                          : (_nyawa <= 0 ? 'Lihat Hasil 🏆' : 'Coba Lagi 🔄'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}
