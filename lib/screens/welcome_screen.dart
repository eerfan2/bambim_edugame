import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

/// ============================================================
/// SCREEN: WelcomeScreen (Halaman Pembuka)
/// ============================================================
/// Halaman pertama yang dilihat pengguna saat membuka aplikasi.
/// Berisi logo, tagline, dan tombol MULAI.
///
/// StatelessWidget → tidak ada data yang berubah di halaman ini.
/// ============================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery untuk mengambil ukuran layar
    // Berguna agar layout responsif di berbagai ukuran HP
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Background: gradient kuning-oranye hangat
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF9F0), // Krem sangat terang
              Color(0xFFFFF3DC), // Krem kuning lembut
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // SafeArea agar konten tidak tertutup notch/status bar
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              // Susun konten dari atas ke bawah
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---- BAGIAN ATAS: Bintang dekoratif ----
                const Spacer(flex: 2),

                // Bintang-bintang kecil dekoratif di atas logo
                _buildDecorationStars(),
                const SizedBox(height: 24),

                // ---- LOGO PLACEHOLDER ----
                // Sesuai wireframe: lingkaran besar di tengah
                _buildLogo(size),
                const SizedBox(height: 36),

                // ---- NAMA APLIKASI ----
                _buildAppTitle(),
                const SizedBox(height: 12),

                // ---- TAGLINE ----
                _buildTagline(),

                const Spacer(flex: 3),

                // ---- TOMBOL MULAI ----
                _buildStartButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget bintang dekoratif di atas logo
  Widget _buildDecorationStars() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('⭐', style: TextStyle(fontSize: 20)),
        SizedBox(width: 16),
        Text('✨', style: TextStyle(fontSize: 28)),
        SizedBox(width: 16),
        Text('⭐', style: TextStyle(fontSize: 20)),
      ],
    );
  }

  /// Widget Logo — lingkaran besar dengan inisial aplikasi
  /// Sesuai wireframe: placeholder berbentuk lingkaran
  Widget _buildLogo(Size size) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradient di dalam logo
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFFD93D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Shadow untuk efek melayang
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        // Border putih tipis
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎓', style: TextStyle(fontSize: 60)),
          SizedBox(height: 4),
          Text(
            'EJA YUK!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget nama aplikasi
  Widget _buildAppTitle() {
    return const Text(
      'Eja Yuk!',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFF8C00),
        letterSpacing: 1.5,
      ),
    );
  }

  /// Widget tagline sesuai wireframe
  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C00).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Belajar seru bersama setiap hari!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF7B5200),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  /// Widget tombol MULAI sesuai wireframe
  /// onPressed → navigasi ke RoleSelectionScreen
  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Tombol selebar layar
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          // Navigator.push → buka halaman baru di atas halaman ini
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          // Warna tombol oranye
          backgroundColor: const Color(0xFFFF8C00),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFFFF8C00).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            // Rounded sesuai wireframe
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'MULAI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
