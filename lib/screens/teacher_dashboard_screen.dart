import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'settings_notification_screen.dart';

/// ============================================================
/// SCREEN: TeacherDashboardScreen
/// PR #8: Progress anak = persentase gabungan + detail per stage saat diklik
/// PR: Buka Level → toggle via DataService
/// ============================================================
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});
  @override
  State<TeacherDashboardScreen> createState() => _TeacherState();
}

class _TeacherState extends State<TeacherDashboardScreen> {
  int _nav = 0;

  static const _menu = [
    {
      'emoji': '🔓',
      'judul': 'Buka Level',
      'deskripsi': 'Buka stage baru untuk anak',
      'warna': Color(0xFF4ECDC4),
      'ikonKanan': false
    },
    {
      'emoji': '📊',
      'judul': 'Lihat Progres Anak',
      'deskripsi': 'Lihat hasil belajar setiap anak',
      'warna': Color(0xFFA29BFE),
      'ikonKanan': true
    },
    {
      'emoji': '👧',
      'judul': 'Daftar Anak',
      'deskripsi': 'Data anak yang menggunakan aplikasi',
      'warna': Color(0xFFFF6B6B),
      'ikonKanan': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
        builder: (ctx, ds, _) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              appBar: _appBar(ds),
              body: SafeArea(
                  child: IndexedStack(index: _nav, children: [
                _body(ctx),
                const _PlaceholderTab(
                    emoji: '🔔', label: 'Notifikasi', color: Color(0xFFFFD93D)),
                const _PlaceholderTab(
                    emoji: '⚙️', label: 'Pengaturan', color: Color(0xFFA29BFE)),
              ])),
              bottomNavigationBar: _bottomNav(context),
            ));
  }

  PreferredSizeWidget _appBar(DataService ds) => AppBar(
        backgroundColor: const Color(0xFFA29BFE),
        automaticallyImplyLeading: false,
        title: const Text('Dashboard Guru',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        actions: [
          Stack(children: [
            IconButton(
                icon: const Icon(Icons.notifications_rounded,
                    color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()));
                  setState(() {});
                }),
            if (ds.adaNotifikasiBaru)
              Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5)))),
          ]),
        ],
      );

  Widget _body(BuildContext ctx) {
    final ds = DataService.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _headerGuru(),
        const SizedBox(height: 20),
        _statsRow(ds),
        const SizedBox(height: 24),
        const Text('🛠️  Menu Guru',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3436))),
        const SizedBox(height: 14),
        ..._menu.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child:
                  _MenuCard(data: e.value, onTap: () => _navigasi(ctx, e.key)),
            )),
      ]),
    );
  }

  Widget _headerGuru() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFA29BFE), Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFA29BFE).withOpacity(0.4),
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
                  child: Text('👩‍🏫', style: TextStyle(fontSize: 30)))),
          const SizedBox(width: 16),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Halo, Bu Guru! 👋',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Pantau perkembangan anak-anak di sini.',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.4)),
              ])),
        ]),
      );

  Widget _statsRow(DataService ds) {
    final jumlahSiswa = DataService.daftarSiswa.length;
    final stageAktif = List.generate(DataService.totalStage, (i) => i + 1)
        .where((s) => ds.isStageUnlocked(s))
        .length;
    // Rata skor seluruh siswa
    double totalPersen = 0;
    for (final s in DataService.daftarSiswa) {
      totalPersen += ds.persentaseSiswa(s['nama']!);
    }
    final rataPersen =
        jumlahSiswa > 0 ? (totalPersen / jumlahSiswa * 100).round() : 0;

    final stats = [
      {
        'label': 'Total Anak',
        'nilai': '$jumlahSiswa',
        'emoji': '👧',
        'warna': const Color(0xFFFF6B6B)
      },
      {
        'label': 'Stage Aktif',
        'nilai': '$stageAktif',
        'emoji': '🏆',
        'warna': const Color(0xFF4ECDC4)
      },
      {
        'label': 'Rata Kelas',
        'nilai': '$rataPersen%',
        'emoji': '⭐',
        'warna': const Color(0xFFFFD93D)
      },
    ];
    return Row(
        children: stats.asMap().entries.map((e) {
      final s = e.value;
      return Expanded(
          child: Container(
        margin: EdgeInsets.only(right: e.key < 2 ? 10 : 0),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: (s['warna'] as Color).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(children: [
          Text(s['emoji'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(s['nilai'] as String,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: s['warna'] as Color)),
          Text(s['label'] as String,
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ]),
      ));
    }).toList());
  }

  void _navigasi(BuildContext ctx, int i) {
    final screens = [
      const _BukaLevelScreen(),
      const _ProgressAnakScreen(),
      const _DaftarAnakScreen(),
    ];
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => screens[i]));
  }

  Widget _bottomNav(BuildContext ctx) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Dashboard'},
      {'icon': Icons.notifications_rounded, 'label': 'Notifikasi'},
      {'icon': Icons.settings_rounded, 'label': 'Pengaturan'},
    ];
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final aktif = _nav == i;
          return GestureDetector(
            onTap: () {
              if (i == 2) {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen(isGuru: true)));
              } else {
                setState(() => _nav = i);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                  color: aktif
                      ? const Color(0xFFA29BFE).withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i]['icon'] as IconData,
                    size: aktif ? 28 : 24,
                    color: aktif ? const Color(0xFFA29BFE) : Colors.grey[400]),
                const SizedBox(height: 2),
                Text(items[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                        color: aktif
                            ? const Color(0xFFA29BFE)
                            : Colors.grey[400])),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ---- Menu Card ----
class _MenuCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _MenuCard({required this.data, required this.onTap});
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
    _s = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warna = widget.data['warna'] as Color;
    final ikonKanan = widget.data['ikonKanan'] as bool;
    final bulat = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            color: warna.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: warna.withOpacity(0.35), width: 2)),
        child: Center(
            child: Text(widget.data['emoji'] as String,
                style: const TextStyle(fontSize: 26))));
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
          scale: _s,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: warna.withOpacity(0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: warna.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]),
            child: Row(children: [
              if (!ikonKanan) ...[bulat, const SizedBox(width: 16)],
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.data['judul'] as String,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3436))),
                    const SizedBox(height: 4),
                    Text(widget.data['deskripsi'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            height: 1.3)),
                  ])),
              if (ikonKanan) ...[
                const SizedBox(width: 16),
                bulat
              ] else ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey[400])
              ],
            ]),
          )),
    );
  }
}

// ============================================================
// SUB-SCREEN: Buka Level (Toggle via DataService)
// ============================================================
class _BukaLevelScreen extends StatefulWidget {
  const _BukaLevelScreen();
  @override
  State<_BukaLevelScreen> createState() => _BukaLevelState();
}

class _BukaLevelState extends State<_BukaLevelScreen> {
  static const _meta = [
    {'nomor': 1, 'nama': 'Stage 1 — Tebak Huruf'},
    {'nomor': 2, 'nama': 'Stage 2 — Susun Kata'},
    {'nomor': 3, 'nama': 'Stage 3 — Ejaan Panjang'},
    {'nomor': 4, 'nama': 'Stage 4 — Tantangan'},
    {'nomor': 5, 'nama': 'Stage 5 — Master Ejaan'},
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
        builder: (ctx, ds, _) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              appBar: AppBar(
                  backgroundColor: const Color(0xFF4ECDC4),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text('Buka Level',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              body: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _meta.length,
                itemBuilder: (_, i) {
                  final nomor = _meta[i]['nomor'] as int;
                  final terbuka = ds.isStageUnlocked(nomor);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: terbuka
                                ? const Color(0xFF4ECDC4).withOpacity(0.4)
                                : Colors.grey[300]!)),
                    child: Row(children: [
                      Icon(
                          terbuka
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          color: terbuka
                              ? const Color(0xFF4ECDC4)
                              : Colors.grey[400],
                          size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Text(_meta[i]['nama'] as String,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: terbuka
                                      ? const Color(0xFF2D3436)
                                      : Colors.grey[400]))),
                      Switch(
                        value: terbuka,
                        activeColor: const Color(0xFF4ECDC4),
                        onChanged: nomor == 1
                            ? null
                            : (val) async {
                                if (val)
                                  await ds.guruUnlockStage(nomor);
                                else
                                  await ds.guruLockStage(nomor);
                                if (context.mounted) setState(() {});
                              },
                      ),
                    ]),
                  );
                },
              ),
            ));
  }
}

// ============================================================
// SUB-SCREEN: Progress Anak (PR #8)
// ============================================================
class _ProgressAnakScreen extends StatelessWidget {
  const _ProgressAnakScreen();
  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
        builder: (ctx, ds, _) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FC),
              appBar: AppBar(
                  backgroundColor: const Color(0xFFA29BFE),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text('Progres Anak',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
              body: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: DataService.daftarSiswa.length,
                itemBuilder: (_, i) {
                  final siswa = DataService.daftarSiswa[i];
                  final nama = siswa['nama']!;
                  final persen = ds.persentaseSiswa(nama); // 0.0–1.0
                  final persenInt = (persen * 100).round();
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) =>
                                _DetailProgressSiswa(namaSiswa: nama))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]),
                      child: Row(children: [
                        Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xFFA29BFE).withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(i % 2 == 0 ? '👦' : '👧',
                                    style: const TextStyle(fontSize: 24)))),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              Text('Kelas ${siswa['kelas']}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                              const SizedBox(height: 6),
                              // Progress bar gabungan semua stage
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                      value: persen,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                          persenInt >= 75
                                              ? const Color(0xFF2ECC71)
                                              : const Color(0xFFA29BFE)))),
                              const SizedBox(height: 3),
                              Text('Rata-rata: $persenInt%',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[500])),
                            ])),
                        const SizedBox(width: 10),
                        Text('$persenInt%',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF6C63FF))),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: Colors.grey[400]),
                      ]),
                    ),
                  );
                },
              ),
            ));
  }
}

// Detail progress satu siswa (per stage)
class _DetailProgressSiswa extends StatelessWidget {
  final String namaSiswa;
  const _DetailProgressSiswa({required this.namaSiswa});

  static const _stageMeta = [
    {'nomor': 1, 'nama': 'Stage 1', 'subjudul': 'Tebak Huruf'},
    {'nomor': 2, 'nama': 'Stage 2', 'subjudul': 'Susun Kata'},
    {'nomor': 3, 'nama': 'Stage 3', 'subjudul': 'Ejaan Panjang'},
    {'nomor': 4, 'nama': 'Stage 4', 'subjudul': 'Tantangan'},
    {'nomor': 5, 'nama': 'Stage 5', 'subjudul': 'Master Ejaan'},
  ];

  @override
  Widget build(BuildContext context) {
    final ds = DataService.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
          backgroundColor: const Color(0xFFA29BFE),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(namaSiswa,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Ringkasan atas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFA29BFE), Color(0xFF6C63FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Text('📊', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(namaSiswa,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                        'Rata-rata: ${(ds.persentaseSiswa(namaSiswa) * 100).round()}%',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                  ])),
            ]),
          ),
          const SizedBox(height: 20),

          ..._stageMeta.map((meta) {
            final nomor = meta['nomor'] as int;
            final selesai = ds.isSiswaSelesaiStage(namaSiswa, nomor);
            final skor = ds.getSkorSiswaStage(namaSiswa, nomor);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: selesai
                          ? const Color(0xFFA29BFE).withOpacity(0.3)
                          : Colors.grey[200]!,
                      width: 1.5)),
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: selesai
                            ? const Color(0xFFA29BFE).withOpacity(0.15)
                            : Colors.grey[100],
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(selesai ? '✅' : '⏳',
                            style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(meta['nama'] as String,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: selesai
                                  ? const Color(0xFF2D3436)
                                  : Colors.grey[500])),
                      Text(meta['subjudul'] as String,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                      if (selesai) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                                value: skor / 100,
                                minHeight: 7,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(skor >= 80
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFFA29BFE)))),
                      ],
                    ])),
                if (selesai) ...[
                  const SizedBox(width: 10),
                  Text('$skor',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6C63FF))),
                ],
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// Daftar anak
class _DaftarAnakScreen extends StatelessWidget {
  const _DaftarAnakScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
            backgroundColor: const Color(0xFFFF6B6B),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Daftar Anak',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: DataService.daftarSiswa.length,
          itemBuilder: (_, i) {
            final a = DataService.daftarSiswa[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.12),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text(i % 2 == 0 ? '👦' : '👧',
                            style: const TextStyle(fontSize: 24)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(a['nama']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('Kelas ${a['kelas']}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ])),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey[400]),
              ]),
            );
          },
        ),
      );
}

class _PlaceholderTab extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _PlaceholderTab(
      {required this.emoji, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(label,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text('Segera hadir!',
            style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      ]));
}
