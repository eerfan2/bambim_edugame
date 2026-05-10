import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';

/// ============================================================
/// SCREEN: WelcomeScreen (Splash Screen)
/// - Tampil otomatis 3 detik
/// - Langsung masuk ke Dashboard Murid (tanpa tombol Mulai)
/// - Tidak perlu login dulu
/// ============================================================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animasi fade + scale saat splash muncul
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _scaleAnim = Tween(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));

    _animCtrl.forward();
    _startProgress();

    // ✅ Otomatis pindah ke Dashboard Murid setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const StudentDashboardScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  // Progress bar naik dari 0 → 1 selama 3 detik
  void _startProgress() {
    const totalMs = 3000;
    const intervalMs = 50;
    int elapsed = 0;

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: intervalMs));
      elapsed += intervalMs;
      if (mounted) setState(() => _progress = elapsed / totalMs);
      return elapsed < totalMs && mounted;
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9F0), Color(0xFFFFF3DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Bintang dekoratif
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 16),
                      Text('✨', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 16),
                      Text('⭐', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Logo
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8C00), Color(0xFFFFD93D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎓', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 4),
                        Text(
                          'BAMBIM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nama aplikasi
                  const Text(
                    'Bambim Edugame',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF8C00),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Belajar mengeja seru setiap hari!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B5200),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Progress bar loading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 7,
                            backgroundColor:
                                const Color(0xFFFF8C00).withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFFFF8C00)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Memuat...',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}