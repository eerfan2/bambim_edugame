import 'package:flutter/material.dart';

/// ============================================================
/// SCREEN: BelajarHurufScreen
/// ✅ UPDATE: Tampilkan huruf BESAR dan kecil sekaligus (Aa, Bb, dst)
/// ============================================================
class BelajarHurufScreen extends StatefulWidget {
  const BelajarHurufScreen({super.key});
  @override
  State<BelajarHurufScreen> createState() => _BelajarHurufScreenState();
}

class _BelajarHurufScreenState extends State<BelajarHurufScreen>
    with SingleTickerProviderStateMixin {
  static const Map<String, Map<String, String>> _dataHuruf = {
    'A': {'emoji': '🐔', 'kata': 'Ayam'},
    'B': {'emoji': '⚽', 'kata': 'Bola'},
    'C': {'emoji': '🐛', 'kata': 'Cacing'},
    'D': {'emoji': '🍭', 'kata': 'Donat'},
    'E': {'emoji': '🦅', 'kata': 'Elang'},
    'F': {'emoji': '🐸', 'kata': 'Kodok'},
    'G': {'emoji': '🐘', 'kata': 'Gajah'},
    'H': {'emoji': '🐯', 'kata': 'Harimau'},
    'I': {'emoji': '🐟', 'kata': 'Ikan'},
    'J': {'emoji': '🦒', 'kata': 'Jerapah'},
    'K': {'emoji': '🐰', 'kata': 'Kelinci'},
    'L': {'emoji': '🕷️', 'kata': 'Laba-laba'},
    'M': {'emoji': '🌹', 'kata': 'Mawar'},
    'N': {'emoji': '🍍', 'kata': 'Nanas'},
    'O': {'emoji': '🐒', 'kata': 'Orangutan'},
    'P': {'emoji': '🍌', 'kata': 'Pisang'},
    'Q': {'emoji': '👑', 'kata': 'Queen'},
    'R': {'emoji': '🦁', 'kata': 'Rusa'},
    'S': {'emoji': '🐄', 'kata': 'Sapi'},
    'T': {'emoji': '🐭', 'kata': 'Tikus'},
    'U': {'emoji': '🐛', 'kata': 'Ulat'},
    'V': {'emoji': '🎻', 'kata': 'Viola'},
    'W': {'emoji': '🎨', 'kata': 'Warna'},
    'X': {'emoji': '🎸', 'kata': 'Xilofon'},
    'Y': {'emoji': '🏸', 'kata': 'Yoyo'},
    'Z': {'emoji': '🦓', 'kata': 'Zebra'},
  };

  String _hurufAktif = 'A';

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _gantiHuruf(String huruf) {
    setState(() => _hurufAktif = huruf);
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final data = _dataHuruf[_hurufAktif]!;
    final hurufBesar = _hurufAktif.toUpperCase();
    final hurufKecil = _hurufAktif.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Belajar Huruf',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAreaDisplay(data, hurufBesar, hurufKecil),
              ),
            ),
            Expanded(flex: 5, child: _buildKeyboard()),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaDisplay(
      Map<String, String> data, String besar, String kecil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // ── Huruf BESAR dan kecil (kiri) ──
                Expanded(
                  flex: 4,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        key: ValueKey(_hurufAktif),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Huruf Besar
                          Text(
                            besar,
                            style: TextStyle(
                              fontSize: 76,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF6B6B),
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFFFF6B6B).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                          ),
                          // Garis pemisah
                          Container(
                            width: 40,
                            height: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Huruf Kecil
                          Text(
                            kecil,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF8C00),
                              height: 1.0,
                              shadows: [
                                Shadow(
                                  color:
                                      const Color(0xFFFF8C00).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _labelTag('Besar', const Color(0xFFFF6B6B)),
                              const SizedBox(width: 6),
                              _labelTag('Kecil', const Color(0xFFFF8C00)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Divider
                Container(
                    width: 1.5,
                    height: double.infinity,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(horizontal: 8)),

                // ── Gambar + kata contoh (kanan) ──
                Expanded(
                  flex: 5,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey('img_$_hurufAktif'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    const Color(0xFFFF6B6B).withOpacity(0.35),
                                width: 2.5),
                          ),
                          child: Center(
                              child: Text(data['emoji']!,
                                  style: const TextStyle(fontSize: 40))),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['kata']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3436)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$besar dalam ${data['kata']}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Pasangan huruf "Aa" ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFFFF6B6B).withOpacity(0.07),
                const Color(0xFFFF8C00).withOpacity(0.07),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFFF8C00).withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pasangan huruf: ',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF636E72),
                        fontWeight: FontWeight.w500)),
                Text(besar,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF6B6B))),
                const Text(' — ',
                    style: TextStyle(fontSize: 18, color: Color(0xFF636E72))),
                Text(kecil,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF8C00))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildKeyboard() {
    final semuaHuruf = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    return Container(
      color: const Color(0xFFF0F0F5),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
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
              // ✅ Tombol keyboard tampilkan "A" besar + "a" kecil
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    huruf.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isAktif ? Colors.white : const Color(0xFF2D3436),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    huruf.toLowerCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isAktif
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey[500],
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
