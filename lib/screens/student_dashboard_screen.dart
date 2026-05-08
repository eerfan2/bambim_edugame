import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../placeholder_screens.dart';
import 'settings_notification_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});
  @override
  State<StudentDashboardScreen> createState() => _State();
}

class _State extends State<StudentDashboardScreen> {
  int _nav = 0;
  final _menus = [
    {'label': 'Belajar Huruf', 'emoji': '🔤', 'color': const Color(0xFFFF6B6B)},
    {'label': 'Mengeja Kata', 'emoji': '✏️', 'color': const Color(0xFF4ECDC4)},
    {'label': 'Permainan', 'emoji': '🎮', 'color': const Color(0xFFFFD93D)},
    {'label': 'Progres Saya', 'emoji': '🏆', 'color': const Color(0xFFA29BFE)},
  ];

  void _tap(BuildContext ctx, int i) {
    final screens = [
      BelajarHurufScreen(),
      MengejaKataScreen(),
      GameScreen(),
      ProgressScreen(),
    ];
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screens[i]));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
        builder: (ctx, ds, _) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              appBar: AppBar(
                backgroundColor: const Color(0xFFFF8C00),
                automaticallyImplyLeading: false,
                title: const Text('Eja Yuk! 🌟',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22)),
                actions: [
                  Stack(children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () async {
                        await Navigator.push(
                            ctx,
                            MaterialPageRoute(
                                builder: (_) => const NotificationScreen()));
                        setState(() {});
                      },
                    ),
                    if (ds.adaNotifikasiBaru)
                      Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                          )),
                  ]),
                ],
              ),
              body: SafeArea(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header profil
                      _profileCard(ds),
                      const SizedBox(height: 24),
                      const Text('📚  Menu Belajar',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3436))),
                      const SizedBox(height: 14),
                      // Grid 2x2
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.0),
                        itemCount: _menus.length,
                        itemBuilder: (ctx, i) => _MenuCard(
                          label: _menus[i]['label'] as String,
                          emoji: _menus[i]['emoji'] as String,
                          color: _menus[i]['color'] as Color,
                          onTap: () => _tap(ctx, i),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Progres banner
                      _progressBanner(ds),
                      if (ds.adaNotifikasiBaru) ...[
                        const SizedBox(height: 14),
                        _notifBanner(ctx, ds)
                      ],
                      const SizedBox(height: 8),
                    ]),
              )),
              bottomNavigationBar: _bottomNav(context),
            ));
  }

  Widget _profileCard(DataService ds) {
    final bintang = List.generate(DataService.totalStage, (i) => i + 1)
        .fold<int>(0, (s, x) => s + ds.getStageBintang(x));
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF8C00), Color(0xFFFFB347)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF8C00).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3)),
            child: const Center(
                child: Text('👦', style: TextStyle(fontSize: 30)))),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Halo, Ayo Belajar! 👋',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 2),
          Text(DataService.instance.currentStudent,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12)),
            child: Text('⭐ $bintang Bintang',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ])),
      ]),
    );
  }

  Widget _progressBanner(DataService ds) {
    final selesai = List.generate(DataService.totalStage, (i) => i + 1)
        .where((s) => ds.isStageCompleted(s))
        .length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF90CAF9), width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('🎯', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Progres Stage',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0)))
        ]),
        const SizedBox(height: 10),
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: selesai / DataService.totalStage,
                minHeight: 12,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF42A5F5)))),
        const SizedBox(height: 6),
        Text('$selesai dari ${DataService.totalStage} stage selesai  🌟',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _notifBanner(BuildContext ctx, DataService ds) {
    final n = ds.getNotifikasi().first;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            ctx, MaterialPageRoute(builder: (_) => const NotificationScreen()));
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF3DC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFFFF8C00).withOpacity(0.5), width: 1.5)),
        child: Row(children: [
          const Text('🔓', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(n['judul'] ?? '🔔 Stage Baru!',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7B5200))),
                Text(n['isi'] ?? 'Guru telah membuka stage baru!',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Color(0xFFFF8C00)),
        ]),
      ),
    );
  }

  // PR #1: Bottom nav tengah = Logo EJ (bukan search)
  Widget _bottomNav(BuildContext ctx) {
    return Container(
      height: 70,
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
        _NavBtn(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            aktif: _nav == 0,
            warna: const Color(0xFFFF8C00),
            onTap: () => setState(() => _nav = 0)),
        // Logo app di tengah (bukan search)
        GestureDetector(
          onTap: () => setState(() => _nav = 0),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFD93D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF8C00).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: const Center(
                child: Text('EJ',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1))),
          ),
        ),
        _NavBtn(
            icon: Icons.settings_rounded,
            label: 'Pengaturan',
            aktif: false,
            warna: const Color(0xFFFF8C00),
            onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool aktif;
  final Color warna;
  final VoidCallback onTap;
  const _NavBtn(
      {required this.icon,
      required this.label,
      required this.aktif,
      required this.warna,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: aktif ? warna.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: aktif ? 28 : 24, color: aktif ? warna : Colors.grey[400]),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                    color: aktif ? warna : Colors.grey[400])),
          ]),
        ),
      );
}

class _MenuCard extends StatefulWidget {
  final String label, emoji;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard(
      {required this.label,
      required this.emoji,
      required this.color,
      required this.onTap});
  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: ScaleTransition(
            scale: _s,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: widget.color.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ]),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: widget.color.withOpacity(0.3),
                                width: 2)),
                        child: Center(
                            child: Text(widget.emoji,
                                style: const TextStyle(fontSize: 30)))),
                    const SizedBox(height: 12),
                    Text(widget.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D3436).withOpacity(0.85),
                            height: 1.3)),
                  ]),
            )),
      );
}
