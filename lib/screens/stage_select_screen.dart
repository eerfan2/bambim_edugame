import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'stage_engine.dart'; // ✅ Semua stage pakai StageEngine
import 'settings_notification_screen.dart';

/// ============================================================
/// SCREEN: StageSelectScreen
/// ✅ UPDATE: Semua stage (1-5) sekarang pakai StageEngine
/// ============================================================
class StageSelectScreen extends StatelessWidget {
  const StageSelectScreen({super.key});

  static const List<Map<String, dynamic>> _stageMeta = [
    {
      'nomor': 1,
      'label': 'Stage 1',
      'subjudul': 'Tebak Huruf',
      'warna': Color(0xFF4ECDC4),
      'emoji': '🔤',
    },
    {
      'nomor': 2,
      'label': 'Stage 2',
      'subjudul': 'Huruf + Kata',
      'warna': Color(0xFFFFD93D),
      'emoji': '✏️',
    },
    {
      'nomor': 3,
      'label': 'Stage 3',
      'subjudul': 'Susun Kata',
      'warna': Color(0xFFFF6B6B),
      'emoji': '🧩',
    },
    {
      'nomor': 4,
      'label': 'Stage 4',
      'subjudul': 'Kata Panjang',
      'warna': Color(0xFFA29BFE),
      'emoji': '📚',
    },
    {
      'nomor': 5,
      'label': 'Stage 5',
      'subjudul': 'Kalimat Pendek',
      'warna': Color(0xFFFF8C00),
      'emoji': '📝',
    },
  ];

  static const List<Alignment> _pos = [
    Alignment(-0.7, 0.85),
    Alignment(0.0, 0.45),
    Alignment(-0.5, 0.05),
    Alignment(0.4, -0.35),
    Alignment(-0.2, -0.72),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (ctx, ds, _) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF6C63FF),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('PILIH STAGE',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(children: [
            _infoSiswa(ds),
            Expanded(child: _peta(ctx, ds)),
          ]),
        ),
        bottomNavigationBar: _bottomNav(context),
      );
    });
  }

  // ── Info siswa + bintang total ──
  Widget _infoSiswa(DataService ds) {
    final bintang = List.generate(DataService.totalStage, (i) => i + 1)
        .fold<int>(0, (s, x) => s + ds.getStageBintang(x));
    final maxBintang = DataService.totalStage * 3;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Text('👦', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(ds.currentStudent,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3436))),
        ]),
        // Total bintang dari semua stage
        Row(children: [
          const Text('⭐ ', style: TextStyle(fontSize: 16)),
          Text(
            '$bintang / $maxBintang',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6C63FF)),
          ),
        ]),
      ]),
    );
  }

  // ── Peta stage ──
  Widget _peta(BuildContext ctx, DataService ds) {
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _PathPainter())),
      ..._stageMeta.asMap().entries.map((e) {
        final i = e.key;
        final meta = e.value;
        final nomor = meta['nomor'] as int;
        final terbuka = ds.isStageUnlocked(nomor);
        final selesai = ds.isStageCompleted(nomor);
        final bintang = ds.getStageBintang(nomor);
        final warna = meta['warna'] as Color;

        return Align(
          alignment: _pos[i],
          child: _Bubble(
            nomor: nomor,
            label: meta['label'] as String,
            subjudul: meta['subjudul'] as String,
            emoji: meta['emoji'] as String,
            terbuka: terbuka,
            selesai: selesai,
            bintang: bintang,
            warna: warna,
            onTap: () {
              if (!terbuka) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Row(children: [
                    const Text('🔒', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Stage $nomor belum dibuka! Minta gurumu untuk membukanya.',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                  backgroundColor: const Color(0xFF6C63FF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ));
                return;
              }
              // ✅ Semua stage pakai StageEngine
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => StageEngine(stageNomor: nomor),
                ),
              );
            },
          ),
        );
      }),
    ]);
  }

  // ── Bottom Nav ──
  Widget _bottomNav(BuildContext ctx) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NBtn(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            onTap: () => Navigator.popUntil(ctx, (r) => r.isFirst)),
        // Logo tengah
        Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: Color(0xFF6C63FF), shape: BoxShape.circle),
            child: const Center(
                child: Text('BM',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5)))),
        _NBtn(
            icon: Icons.settings_rounded,
            label: 'Pengaturan',
            onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ]),
    );
  }
}

// ── Nav Button ──
class _NBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: Colors.grey[400]),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        ]),
      );
}

// ── Bubble Stage ──
class _Bubble extends StatefulWidget {
  final int nomor, bintang;
  final String label, subjudul, emoji;
  final bool terbuka, selesai;
  final Color warna;
  final VoidCallback onTap;

  const _Bubble({
    required this.nomor,
    required this.label,
    required this.subjudul,
    required this.emoji,
    required this.terbuka,
    required this.selesai,
    required this.bintang,
    required this.warna,
    required this.onTap,
  });

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.terbuka ? widget.warna : Colors.grey[400]!;
    return GestureDetector(
      onTapDown: (_) => widget.terbuka ? _c.forward() : null,
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Lingkaran utama stage
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: widget.terbuka
                    ? [
                        BoxShadow(
                            color: c.withOpacity(0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 5))
                      ]
                    : []),
            child: Center(
              child: widget.terbuka
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.emoji,
                            style: const TextStyle(fontSize: 22)),
                        Text(
                          '${widget.nomor}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1),
                        ),
                      ],
                    )
                  : const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 5),
          // Label
          Text(widget.label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: widget.terbuka
                      ? const Color(0xFF2D3436)
                      : Colors.grey[500])),
          // Subjudul
          Text(widget.subjudul,
              style: TextStyle(fontSize: 9, color: Colors.grey[500])),
          // Bintang hasil
          if (widget.selesai)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Text(
                  i < widget.bintang ? '★' : '☆',
                  style: TextStyle(
                      fontSize: 13,
                      color: i < widget.bintang
                          ? const Color(0xFFFFD93D)
                          : Colors.grey[300]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Custom Painter path antar stage ──
class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pts = [
      const Alignment(-0.7, 0.85),
      const Alignment(0.0, 0.45),
      const Alignment(-0.5, 0.05),
      const Alignment(0.4, -0.35),
      const Alignment(-0.2, -0.72),
    ]
        .map((a) =>
            Offset((a.x + 1) / 2 * size.width, (a.y + 1) / 2 * size.height))
        .toList();

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final mid = Offset(
          (pts[i].dx + pts[i + 1].dx) / 2, (pts[i].dy + pts[i + 1].dy) / 2);
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
