import 'package:flutter/material.dart';

/// ============================================================
/// SCREEN: BelajarHurufScreen (Halaman Belajar Huruf)
/// ============================================================
/// Fitur:
///   - Tampilkan huruf besar yang aktif
///   - Gambar contoh (emoji) + nama contoh
///   - Tombol play (dummy TTS)
///   - Grid keyboard A-Z (tap untuk ganti huruf)
///
/// StatefulWidget → state berubah saat huruf diklik
/// ============================================================
class BelajarHurufScreen extends StatefulWidget {
  const BelajarHurufScreen({super.key});

  @override
  State<BelajarHurufScreen> createState() => _BelajarHurufScreenState();
}

class _BelajarHurufScreenState extends State<BelajarHurufScreen>
    with SingleTickerProviderStateMixin {
  // ---- DATA DUMMY: Peta Huruf → Contoh ----
  // Berisi emoji + kata contoh untuk setiap huruf
  // Nanti bisa diperluas atau diambil dari database
  static const Map<String, Map<String, String>> _dataHuruf = {
    'A': {'emoji': '🐔', 'kata': 'Ayam'},
    'B': {'emoji': '⚽', 'kata': 'Bola'},
    'C': {'emoji': '🐛', 'kata': 'Cacing'},
    'D': {'emoji': '🍭', 'kata': 'Donat'},
    'E': {'emoji': '🦅', 'kata': 'Elang'},
    'F': {'emoji': '🛩️', 'kata': 'Feri'},
    'G': {'emoji': '🐘', 'kata': 'Gajah'},
    'H': {'emoji': '🐯', 'kata': 'Harimau'},
    'I': {'emoji': '🐟', 'kata': 'Ikan'},
    'J': {'emoji': '🦒', 'kata': 'Jerapah'},
    'K': {'emoji': '🐰', 'kata': 'Kelinci'},
    'L': {'emoji': '🕷️', 'kata': 'Laba-Laba'},
    'M': {'emoji': '🌹', 'kata': 'Mawar'},
    'N': {'emoji': '🍍', 'kata': 'Nanas'},
    'O': {'emoji': '🦦', 'kata': 'Otter'},
    'P': {'emoji': '🍑', 'kata': 'Persik'},
    'Q': {'emoji': '🦋', 'kata': 'Quail'},
    'R': {'emoji': '🎋', 'kata': 'Rotan'},
    'S': {'emoji': '🐄', 'kata': 'Sapi'},
    'T': {'emoji': '🐅', 'kata': 'Tikus'},
    'U': {'emoji': '🐛', 'kata': 'Ulat'},
    'V': {'emoji': '🎻', 'kata': 'Viola'},
    'W': {'emoji': '🎨', 'kata': 'Warna'},
    'X': {'emoji': '🎸', 'kata': 'Xilofon'},
    'Y': {'emoji': '🏸', 'kata': 'Yoyo'},
    'Z': {'emoji': '🦓', 'kata': 'Zebra'},
  };

  // Huruf yang sedang aktif ditampilkan (default: A)
  String _hurufAktif = 'A';

  // Controller animasi untuk efek ganti huruf
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    // Animasi "pop" saat huruf berganti
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIKA: Ganti huruf aktif
  // ============================================================
  // Dipanggil saat tombol huruf ditekan
  // 1. Update state _hurufAktif
  // 2. Jalankan animasi "pop"
  void _gantiHuruf(String huruf) {
    setState(() => _hurufAktif = huruf);
    _animCtrl.forward(from: 0); // Reset + jalankan animasi
  }

  @override
  Widget build(BuildContext context) {
    final data = _dataHuruf[_hurufAktif]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Belajar Huruf',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ---- AREA ATAS: Huruf besar + gambar ----
            Expanded(
              flex: 5, // Ambil 50% layar
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAreaDisplay(data),
              ),
            ),

            // ---- TOMBOL PLAY ----
            _buildTombolPlay(),
            const SizedBox(height: 12),

            // ---- KEYBOARD HURUF A-Z ----
            // Sisanya 50% layar untuk keyboard
            Expanded(flex: 5, child: _buildKeyboardHuruf()),
          ],
        ),
      ),
    );
  }

  // ---- WIDGET: Area Display (Huruf besar + Gambar) ----
  // Sesuai wireframe: huruf besar di kiri, contoh gambar di kanan
  Widget _buildAreaDisplay(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---- HURUF BESAR (kiri) ----
          Expanded(
            flex: 4,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Text(
                  _hurufAktif,
                  style: TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF6B6B),
                    // Shadow pada huruf
                    shadows: [
                      Shadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Divider vertikal
          Container(
            width: 1.5,
            height: 120,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // ---- GAMBAR CONTOH (kanan) ----
          // Sesuai wireframe: lingkaran dengan teks di bawah
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lingkaran gambar
                AnimatedSwitcher(
                  // AnimatedSwitcher memberikan animasi fade saat konten ganti
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(_hurufAktif), // Key penting untuk animasi!
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B6B).withOpacity(0.35),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        data['emoji']!,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Nama contoh
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    data['kata']!,
                    key: ValueKey('kata_$_hurufAktif'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- WIDGET: Tombol Play ----
  Widget _buildTombolPlay() {
    return GestureDetector(
      onTap: () {
        // TODO: Integrasikan Text-to-Speech di sini
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔊 "$_hurufAktif" untuk "${_dataHuruf[_hurufAktif]!['kata']}"',
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFF6B6B), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up_rounded, color: Color(0xFFFF6B6B), size: 20),
            SizedBox(width: 6),
            Text(
              'Dengarkan',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- WIDGET: Keyboard A-Z ----
  // Sesuai wireframe: grid tombol huruf A sampai Z
  Widget _buildKeyboardHuruf() {
    final semuaHuruf = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    return Container(
      color: const Color(0xFFF0F0F5),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: GridView.builder(
        // Tidak perlu scroll terpisah → physics ini
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 7 tombol per baris
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1, // Tombol persegi
        ),
        itemCount: semuaHuruf.length,
        itemBuilder: (context, index) {
          final huruf = semuaHuruf[index];
          final isAktif = huruf == _hurufAktif;

          return GestureDetector(
            onTap: () => _gantiHuruf(huruf),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                // Warna berbeda untuk huruf aktif
                color: isAktif ? const Color(0xFFFF6B6B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: isAktif
                        ? const Color(0xFFFF6B6B).withOpacity(0.4)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isAktif ? 8 : 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  huruf,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isAktif ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
