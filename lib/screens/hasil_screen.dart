import 'package:flutter/material.dart';

/// ============================================================
/// SCREEN: HasilScreen (Halaman Hasil)
/// ============================================================
/// Ditampilkan setelah siswa menyelesaikan satu stage.
/// Sesuai wireframe:
///   - Ikon piala besar di tengah
///   - Teks "Skor Anda" + angka skor
///   - Tombol "Main Lagi" dan "Kembali"
///
/// Parameter:
///   - skor        : nilai yang diraih (0–100)
///   - stageNomor  : stage berapa yang baru diselesaikan
///   - onMainLagi  : callback tombol "Main Lagi" → kembali ke stage
///
/// StatelessWidget → tidak ada state internal
/// ============================================================
class HasilScreen extends StatelessWidget {
  final int skor;
  final int stageNomor;

  /// Callback untuk tombol "Main Lagi"
  /// Jika null, tombol akan pop 2 kali (kembali ke stage)
  final VoidCallback? onMainLagi;

  const HasilScreen({
    super.key,
    required this.skor,
    this.stageNomor = 1,
    this.onMainLagi,
  });

  // ---- HELPER: Tentukan label skor ----
  String get _labelSkor {
    if (skor >= 90) return 'Luar Biasa! 🌟';
    if (skor >= 70) return 'Bagus Sekali! 👏';
    if (skor >= 50) return 'Cukup Baik! 😊';
    return 'Terus Semangat! 💪';
  }

  // ---- HELPER: Hitung jumlah bintang (1–3) ----
  int get _jumlahBintang {
    if (skor >= 90) return 3;
    if (skor >= 60) return 2;
    return 1;
  }

  // ---- HELPER: Warna berdasarkan skor ----
  Color get _warnaSkor {
    if (skor >= 90) return const Color(0xFF2ECC71);
    if (skor >= 70) return const Color(0xFF3498DB);
    if (skor >= 50) return const Color(0xFFFF8C00);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- BACKGROUND GRADIENT ----
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_warnaSkor.withOpacity(0.15), Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- APP BAR CUSTOM ----
              _buildAppBar(context),

              // ---- KONTEN UTAMA ----
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Confetti dekoratif
                      _buildDekorasi(),
                      const SizedBox(height: 20),

                      // Ikon piala besar (sesuai wireframe)
                      _buildIkonPiala(),
                      const SizedBox(height: 28),

                      // Bintang hasil
                      _buildBintang(),
                      const SizedBox(height: 20),

                      // Label skor
                      Text(
                        'Skor Anda',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Angka skor besar (sesuai wireframe)
                      _buildAngkaSkor(),
                      const SizedBox(height: 8),

                      // Label kategori skor
                      Text(
                        _labelSkor,
                        style: TextStyle(
                          fontSize: 16,
                          color: _warnaSkor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Tombol aksi
                      _buildTombolAksi(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- APP BAR CUSTOM (tanpa Scaffold AppBar) ----
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _warnaSkor,
        boxShadow: [
          BoxShadow(
            color: _warnaSkor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Hasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer agar judul benar-benar center
        ],
      ),
    );
  }

  // ---- Emoji dekoratif ----
  Widget _buildDekorasi() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('🎊', style: TextStyle(fontSize: 22)),
        Text('✨', style: TextStyle(fontSize: 18)),
        Text('🎉', style: TextStyle(fontSize: 22)),
        Text('✨', style: TextStyle(fontSize: 18)),
        Text('🎊', style: TextStyle(fontSize: 22)),
      ],
    );
  }

  // ---- Ikon Piala Besar ----
  // Sesuai wireframe: lingkaran besar berisi ikon penghargaan
  Widget _buildIkonPiala() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: _warnaSkor.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _warnaSkor.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: _warnaSkor.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        // Pilih emoji berdasarkan skor
        child: Text(
          skor >= 90
              ? '🏆'
              : skor >= 70
              ? '🥇'
              : skor >= 50
              ? '🥈'
              : '🥉',
          style: const TextStyle(fontSize: 72),
        ),
      ),
    );
  }

  // ---- Bintang hasil ----
  Widget _buildBintang() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final terisi = i < _jumlahBintang;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (i * 100)),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            terisi ? '⭐' : '☆',
            style: TextStyle(
              fontSize: 36,
              color: terisi ? Colors.amber : Colors.grey[300],
            ),
          ),
        );
      }),
    );
  }

  // ---- Angka skor besar ----
  Widget _buildAngkaSkor() {
    return Text(
      '$skor',
      style: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        color: _warnaSkor,
        height: 1,
        // Efek shadow pada angka
        shadows: [
          Shadow(
            color: _warnaSkor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
    );
  }

  // ---- Tombol "Main Lagi" dan "Kembali" ----
  // Sesuai wireframe: 2 tombol berdampingan
  Widget _buildTombolAksi(BuildContext context) {
    return Row(
      children: [
        // Tombol MAIN LAGI
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              if (onMainLagi != null) {
                Navigator.pop(context); // Tutup HasilScreen
                onMainLagi!();
              } else {
                // Default: pop HasilScreen, lalu stage otomatis restart
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: _warnaSkor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(Icons.replay_rounded, color: _warnaSkor),
            label: Text(
              'Main Lagi',
              style: TextStyle(
                color: _warnaSkor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Tombol KEMBALI (ke StageSelect)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // popUntil → kembali ke halaman StageSelectScreen
              // Ini menutup HasilScreen DAN StageScreen sekaligus
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == '/stage-select' || route.isFirst,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _warnaSkor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.home_rounded),
            label: const Text(
              'Kembali',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
