import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'stage_soal_model.dart';
import 'hasil_screen.dart';

/// ============================================================
/// SCREEN: StageEngine — Game engine terpusat untuk Stage 1–5
///
/// Cara pakai:
///   Navigator.push(ctx, MaterialPageRoute(
///     builder: (_) => StageEngine(stageNomor: 1)));
///
/// Menangani semua tipe soal:
///   TipeA → Tebak Huruf (Pilihan Ganda)
///   TipeB → Susun Kata  (Tap Huruf)
///   TipeC → Soal tambahan (berbagai subtipe)
///
/// Sistem poin:
///   Benar pertama kali  → +20
///   Benar setelah hint  → +10
///   Salah               → -1 nyawa
///   Bonus tanpa salah   → +10 di akhir
/// ============================================================
class StageEngine extends StatefulWidget {
  final int stageNomor;
  const StageEngine({super.key, required this.stageNomor});

  @override
  State<StageEngine> createState() => _StageEngineState();
}

class _StageEngineState extends State<StageEngine>
    with TickerProviderStateMixin {
  // ── Ambil daftar soal berdasarkan stage ──
  List<Soal> get _daftarSoal {
    switch (widget.stageNomor) {
      case 1:
        return soalStage1;
      case 2:
        return soalStage2;
      case 3:
        return soalStage3;
      case 4:
        return soalStage4;
      case 5:
        return soalStage5;
      default:
        return soalStage1;
    }
  }

  // ── Warna tema per stage ──
  Color get _warnaStage {
    switch (widget.stageNomor) {
      case 1:
        return const Color(0xFF4ECDC4);
      case 2:
        return const Color(0xFFFFD93D);
      case 3:
        return const Color(0xFFFF6B6B);
      case 4:
        return const Color(0xFFA29BFE);
      case 5:
        return const Color(0xFFFF8C00);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  // ── State game ──
  int _soalIndex = 0;
  int _nyawa = 3;
  int _skor = 0;
  bool _sudahJawab = false;
  bool _pakaiHint = false; // Apakah hint sudah dipakai soal ini
  bool _adaSalah = false; // Untuk cek bonus tanpa salah

  // ── State TipeA & TipeC ──
  int? _pilihanUser;
  bool? _statusBenar;

  // ── State TipeB ──
  List<Map<String, dynamic>> _hurufAcak = [];
  List<Map<String, dynamic>> _jawabanSusun = [];

  // ── Timer ──
  static const int _durasiDetik = 30; // 30 detik per soal
  int _sisaWaktu = _durasiDetik;
  Timer? _timer;

  // ── Animasi ──
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _feedbackAnim =
        CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut);

    _muatSoal();
    _mulaiTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================
  void _mulaiTimer() {
    _timer?.cancel();
    setState(() => _sisaWaktu = _durasiDetik);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_sisaWaktu > 0 && !_sudahJawab) {
          _sisaWaktu--;
        } else if (_sisaWaktu == 0 && !_sudahJawab) {
          // Waktu habis → anggap salah
          _prosesWaktuHabis();
        }
      });
    });
  }

  void _prosesWaktuHabis() {
    setState(() {
      _sudahJawab = true;
      _statusBenar = false;
      _nyawa--;
      _adaSalah = true;
      _shakeCtrl.forward(from: 0);
    });
  }

  // ============================================================
  // MUAT SOAL
  // ============================================================
  void _muatSoal() {
    _timer?.cancel();
    final soal = _daftarSoal[_soalIndex];
    setState(() {
      _sudahJawab = false;
      _pakaiHint = false;
      _pilihanUser = null;
      _statusBenar = null;
      _jawabanSusun = [];
    });

    // Siapkan huruf acak untuk TipeB
    if (soal.tipe == TipeSoal.tipeB && soal.kata != null) {
      final hurufList = soal.kata!.split('');
      hurufList.shuffle(Random());
      setState(() {
        _hurufAcak = hurufList
            .asMap()
            .entries
            .map((e) => {'id': e.key, 'huruf': e.value, 'dipilih': false})
            .toList();
      });
    }

    _mulaiTimer();
  }

  // ============================================================
  // HINT — tampilkan petunjuk, kurangi poin jika benar
  // ============================================================
  void _pakaiHintAction() {
    if (_pakaiHint || _sudahJawab) return;
    setState(() => _pakaiHint = true);

    final soal = _daftarSoal[_soalIndex];
    String pesanHint = '';

    if (soal.tipe == TipeSoal.tipeA || soal.tipe == TipeSoal.tipeC) {
      // Tunjukkan huruf/pilihan pertama sebagai hint
      pesanHint = 'Petunjuk: Jawaban dimulai dengan '
          '"${soal.pilihan[soal.indexBenar!][0]}"';
    } else if (soal.tipe == TipeSoal.tipeB) {
      pesanHint = 'Petunjuk: Huruf pertama adalah "${soal.kata![0]}"';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('💡 $pesanHint'),
      backgroundColor: const Color(0xFFFF8C00),
      duration: const Duration(seconds: 2),
    ));
  }

  // ============================================================
  // PROSES JAWABAN TIPE A & C (Pilihan Ganda)
  // ============================================================
  void _pilihJawaban(int index) {
    if (_sudahJawab) return;
    final soal = _daftarSoal[_soalIndex];
    final benar = index == soal.indexBenar;

    setState(() {
      _pilihanUser = index;
      _sudahJawab = true;
      _statusBenar = benar;
    });

    if (benar) {
      final poin = _pakaiHint ? 10 : 20;
      setState(() => _skor += poin);
      _feedbackCtrl.forward(from: 0);
    } else {
      setState(() {
        _nyawa--;
        _adaSalah = true;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  // ============================================================
  // PROSES JAWABAN TIPE B (Susun Kata)
  // ============================================================
  void _pilihHuruf(int id, String huruf) {
    if (_sudahJawab) return;
    final soal = _daftarSoal[_soalIndex];
    if (_jawabanSusun.length >= (soal.kata?.length ?? 0)) return;

    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = true;
      _jawabanSusun.add({'id': id, 'huruf': huruf});
      _statusBenar = null;
    });
  }

  void _batalHuruf(int id) {
    if (_sudahJawab && _statusBenar == true) return;
    setState(() {
      final idx = _hurufAcak.indexWhere((h) => h['id'] == id);
      if (idx != -1) _hurufAcak[idx]['dipilih'] = false;
      _jawabanSusun.removeWhere((h) => h['id'] == id);
      _statusBenar = null;
    });
  }

  void _cekSusunanKata() {
    final soal = _daftarSoal[_soalIndex];
    final kataUser = _jawabanSusun.map((h) => h['huruf']).join('');
    final benar = kataUser == soal.kata;

    setState(() {
      _sudahJawab = true;
      _statusBenar = benar;
    });

    if (benar) {
      final poin = _pakaiHint ? 10 : 20;
      setState(() => _skor += poin);
      _feedbackCtrl.forward(from: 0);
    } else {
      setState(() {
        _nyawa--;
        _adaSalah = true;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  // ============================================================
  // TOMBOL LANJUT
  // ============================================================
  void _lanjut() {
    if (!_sudahJawab) {
      // Untuk TipeB: cek dulu
      final soal = _daftarSoal[_soalIndex];
      if (soal.tipe == TipeSoal.tipeB) {
        if (_jawabanSusun.length < (soal.kata?.length ?? 0)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lengkapi semua hurufnya dulu! 🤔'),
            backgroundColor: Color(0xFFFF8C00),
            duration: Duration(seconds: 1),
          ));
          return;
        }
        _cekSusunanKata();
        return;
      }
      return;
    }

    // Nyawa habis → langsung ke hasil
    if (_nyawa <= 0) {
      _keHasil();
      return;
    }

    // Soal terakhir → ke hasil
    if (_soalIndex >= _daftarSoal.length - 1) {
      _keHasil();
      return;
    }

    // Soal berikutnya
    setState(() => _soalIndex++);
    _muatSoal();
  }

  // ============================================================
  // KE HALAMAN HASIL
  // ============================================================
  Future<void> _keHasil() async {
    _timer?.cancel();

    // Bonus tanpa salah sama sekali
    if (!_adaSalah) setState(() => _skor += 10);

    // Pastikan skor tidak melebihi 100
    final skorFinal = _skor.clamp(0, 100);

    await DataService.instance.simpanSkorStage(widget.stageNomor, skorFinal);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HasilScreen(
          skor: skorFinal,
          stageNomor: widget.stageNomor,
          bonusTanpaSalah: !_adaSalah,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final soal = _daftarSoal[_soalIndex];
    final progress = (_soalIndex + (_sudahJawab ? 1 : 0)) / _daftarSoal.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: _buildAppBar(progress),
      body: SafeArea(
        child: Column(
          children: [
            // Timer bar
            _buildTimerBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  // Kartu soal utama
                  _buildKartuSoal(soal),
                  const SizedBox(height: 16),

                  // Area jawaban (berdasarkan tipe)
                  if (soal.tipe == TipeSoal.tipeB)
                    ..._buildTipeB(soal)
                  else
                    _buildPilihanGanda(soal),

                  const SizedBox(height: 16),

                  // Feedback benar/salah
                  if (_sudahJawab) _buildFeedback(),
                  if (_sudahJawab) const SizedBox(height: 12),

                  // Tombol aksi
                  _buildTombolAksi(soal),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──
  PreferredSizeWidget _buildAppBar(double progress) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: _warnaStage,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Stage ${widget.stageNomor}',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              // Progress soal
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Soal ${_soalIndex + 1}/${_daftarSoal.length}',
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
                    ]),
              ),
              const SizedBox(width: 14),
              // Nyawa
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
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                          ))),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Timer Bar ──
  Widget _buildTimerBar() {
    final persen = _sisaWaktu / _durasiDetik;
    Color warnaTimer;
    if (persen > 0.5) {
      warnaTimer = const Color(0xFF2ECC71);
    } else if (persen > 0.25) {
      warnaTimer = const Color(0xFFFF8C00);
    } else {
      warnaTimer = const Color(0xFFE74C3C);
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(Icons.timer_rounded, size: 18, color: warnaTimer),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: persen,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(warnaTimer),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$_sisaWaktu',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: warnaTimer)),
      ]),
    );
  }

  // ── Kartu Soal ──
  Widget _buildKartuSoal(Soal soal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        // Label tipe soal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: _warnaStage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            _labelTipeSoal(soal),
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: _warnaStage),
          ),
        ),
        const SizedBox(height: 12),

        // Pertanyaan
        Text(
          soal.pertanyaan,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436)),
        ),
        const SizedBox(height: 14),

        // Gambar / huruf soal
        if (soal.huruf != null && soal.tipe == TipeSoal.tipeA)
          _buildKartuHuruf(soal.huruf!, soal.emoji, soal.contoh)
        else if (soal.emoji != null)
          _buildKartuEmoji(soal.emoji!, soal.contoh)
        else if (soal.huruf != null)
          _buildKartuHurufBesar(soal.huruf!),
      ]),
    );
  }

  String _labelTipeSoal(Soal soal) {
    if (soal.tipe == TipeSoal.tipeA) return '🔤 Tebak Huruf';
    if (soal.tipe == TipeSoal.tipeB) return '✏️ Susun Kata';
    switch (soal.tipeC) {
      case TipeC.mengenalBentukHuruf:
        return '👁️ Mengenal Bentuk Huruf';
      case TipeC.mengenalBunyiHuruf:
        return '🔊 Mengenal Bunyi Huruf';
      case TipeC.hubungkanHurufGambar:
        return '🔗 Hubungkan Huruf & Gambar';
      case TipeC.menyusunKata:
        return '🧩 Menyusun Kata';
      case TipeC.membacaSukuKata:
        return '📖 Membaca Suku Kata';
      case TipeC.membacaKataUtuh:
        return '📚 Membaca Kata Utuh';
      case TipeC.membacaKalimatPendek:
        return '📝 Membaca Kalimat';
      default:
        return '❓ Soal';
    }
  }

  Widget _buildKartuHuruf(String huruf, String? emoji, String? contoh) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value, 0), child: child),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 110,
          height: 90,
          decoration: BoxDecoration(
              color: _warnaStage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: _warnaStage.withOpacity(0.4), width: 2)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji ?? '', style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 4),
            Text(contoh ?? '',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildKartuEmoji(String emoji, String? contoh) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 64)),
      if (contoh != null) ...[
        const SizedBox(height: 4),
        Text(contoh,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436))),
      ]
    ]);
  }

  Widget _buildKartuHurufBesar(String huruf) {
    return Text(
      huruf,
      style: TextStyle(
          fontSize: 80, fontWeight: FontWeight.w900, color: _warnaStage),
    );
  }

  // ── Pilihan Ganda (TipeA & TipeC) ──
  Widget _buildPilihanGanda(Soal soal) {
    return Column(
      children: soal.pilihan.asMap().entries.map((e) {
        final i = e.key;
        final teks = e.value;
        Color bg, border, textColor;

        if (!_sudahJawab) {
          bg = _pilihanUser == i ? _warnaStage.withOpacity(0.15) : Colors.white;
          border = _pilihanUser == i ? _warnaStage : Colors.grey[300]!;
          textColor = const Color(0xFF2D3436);
        } else if (i == soal.indexBenar) {
          bg = const Color(0xFF2ECC71).withOpacity(0.15);
          border = const Color(0xFF2ECC71);
          textColor = const Color(0xFF27AE60);
        } else if (i == _pilihanUser && _pilihanUser != soal.indexBenar) {
          bg = const Color(0xFFE74C3C).withOpacity(0.12);
          border = const Color(0xFFE74C3C);
          textColor = const Color(0xFFC0392B);
        } else {
          bg = Colors.white;
          border = Colors.grey[200]!;
          textColor = Colors.grey[400]!;
        }

        return GestureDetector(
          onTap: () => _pilihJawaban(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: border.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]),
            child: Row(children: [
              // Nomor pilihan
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: border.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 1.5)),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + i), // A, B, C
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(teks,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
              ),
              if (_sudahJawab && i == soal.indexBenar)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2ECC71), size: 22),
              if (_sudahJawab &&
                  i == _pilihanUser &&
                  _pilihanUser != soal.indexBenar)
                const Icon(Icons.cancel_rounded,
                    color: Color(0xFFE74C3C), size: 22),
            ]),
          ),
        );
      }).toList(),
    );
  }

  // ── TipeB: Susun Kata ──
  List<Widget> _buildTipeB(Soal soal) {
    final panjang = soal.kata?.length ?? 0;
    return [
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
            final ada = i < _jawabanSusun.length;
            Color border, bg;
            if (!_sudahJawab || !ada) {
              border = ada ? _warnaStage : Colors.grey[300]!;
              bg = ada ? _warnaStage.withOpacity(0.12) : Colors.grey[100]!;
            } else if (_statusBenar == true) {
              border = const Color(0xFF2ECC71);
              bg = const Color(0xFF2ECC71).withOpacity(0.12);
            } else {
              border = const Color(0xFFE74C3C);
              bg = const Color(0xFFE74C3C).withOpacity(0.1);
            }
            return GestureDetector(
              onTap: ada ? () => _batalHuruf(_jawabanSusun[i]['id']) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: 2)),
                child: Center(
                  child: ada
                      ? Text(_jawabanSusun[i]['huruf'] as String,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _sudahJawab
                                  ? (_statusBenar == true
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFFC0392B))
                                  : const Color(0xFF2D3436)))
                      : Text('_',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[300],
                              fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 12),

      // Instruksi
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('💡', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text('Ketuk huruf untuk menyusun kata',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7B5200),
                  fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: 12),

      // Huruf acak
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _hurufAcak.map((item) {
          final dipilih = item['dipilih'] as bool;
          return GestureDetector(
            onTap: dipilih
                ? null
                : () => _pilihHuruf(item['id'], item['huruf'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                    dipilih ? Colors.grey[200] : _warnaStage.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: dipilih ? Colors.grey[300]! : _warnaStage, width: 2),
                boxShadow: dipilih
                    ? []
                    : [
                        BoxShadow(
                            color: _warnaStage.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3))
                      ],
              ),
              child: Center(
                child: Text(
                  dipilih ? '' : item['huruf'] as String,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color:
                          dipilih ? Colors.grey[300] : const Color(0xFF2D3436)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  // ── Feedback ──
  Widget _buildFeedback() {
    final benar = _statusBenar == true;
    final poin = _pakaiHint ? '+10' : '+20';
    return ScaleTransition(
      scale: _feedbackAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: (benar ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))
              .withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: benar ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(benar ? '🎉' : '😅', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                benar
                    ? 'Benar! $poin poin${_pakaiHint ? ' (pakai hint)' : ''}'
                    : (_nyawa <= 0 ? 'Waktu/nyawa habis!' : 'Salah! Coba lagi'),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: benar
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFC0392B)),
              ),
              if (!benar && _nyawa > 0)
                Text('Sisa nyawa: $_nyawa',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Tombol Aksi ──
  Widget _buildTombolAksi(Soal soal) {
    final isTipeB = soal.tipe == TipeSoal.tipeB;
    final panjang = soal.kata?.length ?? 0;
    final sudahLengkap = isTipeB ? _jawabanSusun.length == panjang : true;

    return Row(children: [
      // Tombol Hint
      if (!_sudahJawab) ...[
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: _pakaiHint ? null : _pakaiHintAction,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                  color:
                      _pakaiHint ? Colors.grey[300]! : const Color(0xFFFF8C00),
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(Icons.lightbulb_rounded,
                color: _pakaiHint ? Colors.grey[400] : const Color(0xFFFF8C00),
                size: 18),
            label: Text(
              _pakaiHint ? 'Hint Terpakai' : 'Hint',
              style: TextStyle(
                  color:
                      _pakaiHint ? Colors.grey[400] : const Color(0xFFFF8C00),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],

      // Tombol Jawab / Lanjut
      Expanded(
        flex: 3,
        child: ElevatedButton(
          onPressed:
              (!_sudahJawab && isTipeB && !sudahLengkap) ? null : _lanjut,
          style: ElevatedButton.styleFrom(
            backgroundColor: _sudahJawab
                ? (_statusBenar == true
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFE74C3C))
                : (sudahLengkap ? _warnaStage : Colors.grey[300]),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: sudahLengkap ? 4 : 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            _sudahJawab
                ? (_nyawa <= 0 || _soalIndex >= _daftarSoal.length - 1
                    ? 'Lihat Hasil 🏆'
                    : 'Lanjut ▶')
                : (isTipeB ? 'Jawab' : 'Jawab'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ),
    ]);
  }
}
