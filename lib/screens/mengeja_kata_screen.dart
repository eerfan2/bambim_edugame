import 'package:flutter/material.dart';
import 'dart:math';
import 'tts_service.dart';

/// ============================================================
/// SCREEN: MengejaKataScreen (Halaman Mengeja Kata)
/// ✅ BARU: TTS nyata — kata diucapkan beserta ejaannya
/// ============================================================
class MengejaKataScreen extends StatefulWidget {
  const MengejaKataScreen({super.key});

  @override
  State<MengejaKataScreen> createState() => _MengejaKataScreenState();
}

class _MengejaKataScreenState extends State<MengejaKataScreen> {
  static const List<Map<String, String>> _soalList = [
    {'kata': 'AYAM', 'emoji': '🐔', 'label': 'Ayam'},
    {'kata': 'BOLA', 'emoji': '⚽', 'label': 'Bola'},
    {'kata': 'IKAN', 'emoji': '🐟', 'label': 'Ikan'},
    {'kata': 'KUCING', 'emoji': '🐱', 'label': 'Kucing'},
    {'kata': 'APEL', 'emoji': '🍎', 'label': 'Apel'},
    {'kata': 'BEBEK', 'emoji': '🦆', 'label': 'Bebek'},
  ];

  int _soalIndex = 0;
  List<Map<String, dynamic>> _hurufAcak = [];
  List<Map<String, dynamic>> _jawabanUser = [];
  bool? _statusBenar;
  bool _showFeedback = false;

  // ✅ BARU: State untuk animasi tombol TTS
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _muatSoal();
    // ✅ BARU: Ucapkan kata pertama saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ucapkanKata(_soalList[0]['label']!);
    });
  }

  @override
  void dispose() {
    // ✅ BARU: Stop TTS saat screen ditutup
    TtsService.instance.stop();
    super.dispose();
  }

  // ============================================================
  // ✅ BARU: Ucapkan kata + ejaannya via TTS
  // Contoh: "Ayam. A. Y. A. M. Ayam."
  // ============================================================
  Future<void> _ucapkanKata(String kata) async {
    if (_isSpeaking) return;
    setState(() => _isSpeaking = true);

    await TtsService.instance.speakKata(kata);

    if (mounted) setState(() => _isSpeaking = false);
  }

  // ============================================================
  // Logika soal
  // ============================================================
  void _muatSoal() {
    final soal = _soalList[_soalIndex];
    final hurufList = soal['kata']!.split('');
    hurufList.shuffle(Random());

    setState(() {
      _hurufAcak = hurufList
          .asMap()
          .entries
          .map((e) => {'id': e.key, 'huruf': e.value, 'dipilih': false})
          .toList();
      _jawabanUser = [];
      _statusBenar = null;
      _showFeedback = false;
    });
  }

  void _pilihHuruf(int id, String huruf) {
    if (_statusBenar == true) return;
    if (_jawabanUser.length >= _soalList[_soalIndex]['kata']!.length) return;
    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = true;
      _jawabanUser.add({'id': id, 'huruf': huruf});
      _statusBenar = null;
    });
  }

  void _batalHuruf(int id) {
    if (_statusBenar == true) return;
    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = false;
      _jawabanUser.removeWhere((h) => h['id'] == id);
      _statusBenar = null;
    });
  }

  void _cekJawaban() {
    final kataBenar = _soalList[_soalIndex]['kata']!;
    final kataUser = _jawabanUser.map((h) => h['huruf']).join('');
    setState(() {
      _statusBenar = (kataUser == kataBenar);
      _showFeedback = true;
    });

    if (_statusBenar == true) {
      // ✅ BARU: Ucapkan feedback benar
      TtsService.instance.speakBenar();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _soalBerikutnya();
      });
    } else {
      // ✅ BARU: Ucapkan feedback salah
      TtsService.instance.speakSalah();
    }
  }

  void _soalBerikutnya() {
    setState(() {
      _soalIndex = (_soalIndex + 1) % _soalList.length;
    });
    _muatSoal();
    // ✅ BARU: Ucapkan soal berikutnya
    _ucapkanKata(_soalList[_soalIndex]['label']!);
  }

  void _reset() {
    _muatSoal();
  }

  @override
  Widget build(BuildContext context) {
    final soal = _soalList[_soalIndex];
    final panjangKata = soal['kata']!.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4ECDC4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mengeja Kata',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${_soalIndex + 1}/${_soalList.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Gambar + tombol TTS
              _buildGambarSection(soal),
              const SizedBox(height: 16),

              // 2. Huruf acak
              _buildHurufAcak(),
              const SizedBox(height: 20),

              // 3. Instruksi
              _buildInstruksi(),
              const SizedBox(height: 12),

              // 4. Kotak jawaban
              _buildKotakJawaban(panjangKata),
              const SizedBox(height: 20),

              // 5. Feedback
              if (_showFeedback) _buildFeedback(),
              if (_showFeedback) const SizedBox(height: 16),

              // 6. Tombol aksi
              _buildTombolAksi(panjangKata),
            ],
          ),
        ),
      ),
    );
  }

  // ---- WIDGET: Gambar + Tombol TTS ----
  Widget _buildGambarSection(Map<String, String> soal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dengarkan kata ini:',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              // ✅ UPDATE: Tombol Play yang memanggil TTS nyata
              GestureDetector(
                onTap: _isSpeaking ? null : () => _ucapkanKata(soal['label']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isSpeaking
                        ? const Color(0xFF4ECDC4).withOpacity(0.3)
                        : const Color(0xFF4ECDC4).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4ECDC4)),
                  ),
                  child: _isSpeaking
                      ? const SizedBox(
                          width: 50,
                          height: 18,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF4ECDC4)),
                              ),
                              SizedBox(width: 4),
                              Text('...',
                                  style: TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ))
                      : const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Color(0xFF4ECDC4), size: 18),
                          SizedBox(width: 4),
                          Text('Play',
                              style: TextStyle(
                                  color: Color(0xFF4ECDC4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.4), width: 2.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(soal['emoji']!, style: const TextStyle(fontSize: 58)),
                const SizedBox(height: 4),
                Text(soal['label']!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- WIDGET: Huruf Acak ----
  Widget _buildHurufAcak() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _hurufAcak.map((item) {
        final dipilih = item['dipilih'] as bool;
        return GestureDetector(
          onTap: dipilih ? null : () => _pilihHuruf(item['id'], item['huruf']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: dipilih
                  ? Colors.grey[200]
                  : const Color(0xFF4ECDC4).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: dipilih ? Colors.grey[300]! : const Color(0xFF4ECDC4),
                  width: 2),
            ),
            child: Center(
              child: Text(
                dipilih ? '' : item['huruf'] as String,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color:
                        dipilih ? Colors.grey[400] : const Color(0xFF2D3436)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---- WIDGET: Instruksi ----
  Widget _buildInstruksi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💡', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text('Susun huruf menjadi kata yang benar',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B5200),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---- WIDGET: Kotak Jawaban ----
  Widget _buildKotakJawaban(int panjang) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(panjang, (i) {
        final adaHuruf = i < _jawabanUser.length;
        return GestureDetector(
          onTap: adaHuruf ? () => _batalHuruf(_jawabanUser[i]['id']) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: adaHuruf
                  ? _getStatusColor().withOpacity(0.15)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: adaHuruf ? _getStatusColor() : Colors.grey[300]!,
                  width: 2),
            ),
            child: Center(
              child: adaHuruf
                  ? Text(_jawabanUser[i]['huruf'] as String,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _getStatusColor()))
                  : Icon(Icons.remove, color: Colors.grey[300], size: 18),
            ),
          ),
        );
      }),
    );
  }

  Color _getStatusColor() {
    if (_statusBenar == true) return const Color(0xFF2ECC71);
    if (_statusBenar == false) return const Color(0xFFE74C3C);
    return const Color(0xFFFF8C00);
  }

  // ---- WIDGET: Feedback ----
  Widget _buildFeedback() {
    final benar = _statusBenar == true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: benar
            ? const Color(0xFF2ECC71).withOpacity(0.15)
            : const Color(0xFFE74C3C).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: benar ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
            width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(benar ? '🎉' : '😅', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(benar ? 'Benar! Hebat!' : 'Coba Lagi!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: benar
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFC0392B))),
              Text(
                  benar
                      ? 'Lanjut soal berikutnya...'
                      : 'Susun hurufnya dengan benar ya!',
                  style: TextStyle(
                      fontSize: 12,
                      color: benar
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFC0392B))),
            ],
          ),
        ],
      ),
    );
  }

  // ---- WIDGET: Tombol Aksi ----
  Widget _buildTombolAksi(int panjang) {
    final sudahLengkap = _jawabanUser.length == panjang;
    return Row(
      children: [
        // Tombol Petunjuk
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showPetunjuk,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[400]!, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(Icons.lightbulb_outline, color: Colors.grey[600]),
            label: Text('Petunjuk',
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        // Tombol Cek / Reset
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _statusBenar == false
                ? _reset
                : (sudahLengkap ? _cekJawaban : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _statusBenar == false
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 3,
            ),
            icon: Icon(_statusBenar == false
                ? Icons.refresh_rounded
                : Icons.check_circle_outline_rounded),
            label: Text(_statusBenar == false ? 'Reset' : 'Cek',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // ---- DIALOG: Petunjuk ----
  void _showPetunjuk() {
    final soal = _soalList[_soalIndex];
    // ✅ BARU: Ucapkan huruf pertama sebagai petunjuk audio
    TtsService.instance.speak('Huruf pertama adalah ${soal['kata']![0]}');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💡', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Petunjuk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Huruf pertama kata ini adalah:\n\n"${soal['kata']![0]}"',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti!',
                style: TextStyle(
                    color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
