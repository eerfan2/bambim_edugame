import 'package:flutter/material.dart';

/// ============================================================
/// SCREEN: HasilScreen
/// ✅ UPDATE: Hapus teks keterangan bintang (80-100=⭐⭐⭐ dst)
/// Siswa hanya lihat: bintang + skor akhir + bonus
/// ============================================================
class HasilScreen extends StatefulWidget {
  final int skor;
  final int stageNomor;
  final bool bonusTanpaSalah;
  final VoidCallback? onMainLagi;

  const HasilScreen({
    super.key,
    required this.skor,
    this.stageNomor = 1,
    this.bonusTanpaSalah = false,
    this.onMainLagi,
  });

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen>
    with TickerProviderStateMixin {
  late AnimationController _bintangCtrl;
  late List<Animation<double>> _bintangAnim;

  @override
  void initState() {
    super.initState();
    _bintangCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // Animasi bintang muncul satu per satu
    _bintangAnim = List.generate(3, (i) {
      final start = i * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _bintangCtrl,
          curve: Interval(start, start + 0.4, curve: Curves.elasticOut),
        ),
      );
    });

    _bintangCtrl.forward();
  }

  @override
  void dispose() {
    _bintangCtrl.dispose();
    super.dispose();
  }

  int get _jumlahBintang {
    if (widget.skor >= 80) return 3;
    if (widget.skor >= 50) return 2;
    return 1;
  }

  String get _labelSkor {
    if (widget.skor >= 80) return 'Luar Biasa! 🌟';
    if (widget.skor >= 50) return 'Bagus Sekali! 👏';
    return 'Terus Semangat! 💪';
  }

  Color get _warnaSkor {
    if (widget.skor >= 80) return const Color(0xFF2ECC71);
    if (widget.skor >= 50) return const Color(0xFF3498DB);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_warnaSkor.withOpacity(0.12), Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _buildAppBar(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dekorasi
                    _buildDekorasi(),
                    const SizedBox(height: 20),

                    // Ikon piala
                    _buildIkonPiala(),
                    const SizedBox(height: 24),

                    // ⭐ Bintang animasi
                    _buildBintang(),
                    const SizedBox(height: 20),

                    // Skor
                    Text('Skor Kamu',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    _buildAngkaSkor(),
                    const SizedBox(height: 8),

                    // Label kategori
                    Text(_labelSkor,
                        style: TextStyle(
                            fontSize: 16,
                            color: _warnaSkor,
                            fontWeight: FontWeight.bold)),

                    // Bonus tanpa salah
                    if (widget.bonusTanpaSalah) ...[
                      const SizedBox(height: 12),
                      _buildBonusBanner(),
                    ],

                    // ✅ DIHAPUS: Keterangan sistem bintang
                    // (80-100=⭐⭐⭐, 50-79=⭐⭐, <50=⭐)

                    const SizedBox(height: 32),
                    _buildTombolAksi(context),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _warnaSkor,
        boxShadow: [
          BoxShadow(
              color: _warnaSkor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Text('Hasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        const SizedBox(width: 48),
      ]),
    );
  }

  Widget _buildDekorasi() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('🎊', style: TextStyle(fontSize: 22)),
        Text('✨', style: TextStyle(fontSize: 16)),
        Text('🎉', style: TextStyle(fontSize: 22)),
        Text('✨', style: TextStyle(fontSize: 16)),
        Text('🎊', style: TextStyle(fontSize: 22)),
      ],
    );
  }

  Widget _buildIkonPiala() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: _warnaSkor.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _warnaSkor.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
              color: _warnaSkor.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: Text(
          widget.skor >= 80
              ? '🏆'
              : widget.skor >= 50
                  ? '🥇'
                  : '🥈',
          style: const TextStyle(fontSize: 70),
        ),
      ),
    );
  }

  // ✅ Bintang animasi — tanpa teks keterangan di bawahnya
  Widget _buildBintang() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final terisi = i < _jumlahBintang;
        return AnimatedBuilder(
          animation: _bintangAnim[i],
          builder: (_, child) => Transform.scale(
            scale: terisi ? _bintangAnim[i].value : 1.0,
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              terisi ? '⭐' : '☆',
              style: TextStyle(
                  fontSize: 42,
                  color: terisi ? Colors.amber : Colors.grey[300]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAngkaSkor() {
    return Text(
      '${widget.skor}',
      style: TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        color: _warnaSkor,
        height: 1,
        shadows: [
          Shadow(
              color: _warnaSkor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(2, 4)),
        ],
      ),
    );
  }

  Widget _buildBonusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD93D).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD93D), width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎁', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'Bonus +10! Tidak ada jawaban salah 🔥',
            style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7B5200),
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildTombolAksi(BuildContext context) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            if (widget.onMainLagi != null) {
              Navigator.pop(context);
              widget.onMainLagi!();
            } else {
              Navigator.pop(context);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: _warnaSkor, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(Icons.replay_rounded, color: _warnaSkor),
          label: Text('Main Lagi',
              style: TextStyle(
                  color: _warnaSkor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.popUntil(
              context, (r) => r.settings.name == '/stage-select' || r.isFirst),
          style: ElevatedButton.styleFrom(
            backgroundColor: _warnaSkor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          icon: const Icon(Icons.home_rounded),
          label: const Text('Kembali',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    ]);
  }
}
