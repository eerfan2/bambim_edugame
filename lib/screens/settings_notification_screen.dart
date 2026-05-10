import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'welcome_screen.dart';
import 'teacher_dashboard_screen.dart';

// ============================================================
// SCREEN: NotificationScreen
// ============================================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataService.instance.tandaiNotifikasiDibaca();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifList = DataService.instance.getNotifikasi();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8C00),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifikasi',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: notifList.isEmpty
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const Text('🔔', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Belum ada notifikasi',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C00))),
                  const SizedBox(height: 8),
                  Text('Nantikan stage baru dari gurumu!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifList.length,
              itemBuilder: (_, i) {
                final n = notifList[i];
                final waktu = DateTime.tryParse(n['waktu'] ?? '');
                final dibaca = n['dibaca'] as bool? ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dibaca ? Colors.white : const Color(0xFFFFF3DC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dibaca
                          ? Colors.grey[200]!
                          : const Color(0xFFFF8C00).withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                              child:
                                  Text('🔓', style: TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(n['judul'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2D3436)))),
                                  if (!dibaca)
                                    Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFFFF8C00),
                                            shape: BoxShape.circle)),
                                ]),
                                const SizedBox(height: 4),
                                Text(n['isi'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.4)),
                                if (waktu != null) ...[
                                  const SizedBox(height: 6),
                                  Text(_formatWaktu(waktu),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[400])),
                                ],
                              ]),
                        ),
                      ]),
                );
              },
            ),
    );
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

// ============================================================
// SCREEN: SettingsScreen
// ✅ UPDATE: Login Guru dipindahkan ke sini
// ============================================================
class SettingsScreen extends StatefulWidget {
  final bool isGuru;
  const SettingsScreen({super.key, this.isGuru = false});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundOn = true;
  bool _musicOn = true;
  bool _notifOn = true;

  @override
  Widget build(BuildContext context) {
    final ds = DataService.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA29BFE),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pengaturan',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profil ──
            _buildProfilCard(ds),
            const SizedBox(height: 24),

            // ── Suara ──
            _buildSectionLabel('🔊  Suara & Musik'),
            const SizedBox(height: 10),
            _buildSwitchCard(
                'Efek Suara',
                'Suara saat menjawab soal',
                Icons.volume_up_rounded,
                _soundOn,
                (v) => setState(() => _soundOn = v)),
            _buildSwitchCard(
                'Musik Latar',
                'Musik saat bermain game',
                Icons.music_note_rounded,
                _musicOn,
                (v) => setState(() => _musicOn = v)),
            _buildSwitchCard(
                'Notifikasi',
                'Pemberitahuan stage baru',
                Icons.notifications_rounded,
                _notifOn,
                (v) => setState(() => _notifOn = v)),
            const SizedBox(height: 24),

            // ── Tentang ──
            _buildSectionLabel('ℹ️  Tentang Aplikasi'),
            const SizedBox(height: 10),
            _buildInfoCard('Nama Aplikasi', 'Bambim Edugame 🎓'),
            _buildInfoCard('Versi', '1.0.0'),
            _buildInfoCard('Dibuat oleh', 'Skripsi Flutter 2024'),
            const SizedBox(height: 24),

            // ── Data siswa ──
            if (!widget.isGuru && ds.isLoggedInSiswa) ...[
              _buildSectionLabel('⚙️  Data'),
              const SizedBox(height: 10),
              _buildActionCard(
                icon: Icons.refresh_rounded,
                label: 'Reset Skor Saya',
                deskripsi: 'Hapus semua skor & mulai ulang',
                warna: const Color(0xFFFF6B6B),
                onTap: () => _confirmReset(context, ds),
              ),
              const SizedBox(height: 12),
            ],

            // ✅ LOGIN GURU — tampil jika bukan dari dashboard guru
            if (!widget.isGuru) ...[
              _buildSectionLabel('👩‍🏫  Akses Guru'),
              const SizedBox(height: 10),
              _buildActionCard(
                icon: Icons.school_rounded,
                label:
                    ds.isLoggedInGuru ? 'Dashboard Guru' : 'Login sebagai Guru',
                deskripsi: ds.isLoggedInGuru
                    ? 'Kelola stage dan pantau siswa'
                    : 'Masuk dengan akun guru',
                warna: const Color(0xFFA29BFE),
                onTap: () {
                  if (ds.isLoggedInGuru) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TeacherDashboardScreen()));
                  } else {
                    _showLoginGuru(context);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            // ── Keluar ──
            if (ds.isLoggedIn)
              _buildActionCard(
                icon: Icons.logout_rounded,
                label: 'Keluar',
                deskripsi: 'Kembali ke halaman awal',
                warna: const Color(0xFF636E72),
                onTap: () => _logout(context, ds),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Kartu profil di pengaturan ──
  Widget _buildProfilCard(DataService ds) {
    final sudahLogin = ds.isLoggedInSiswa || ds.isLoggedInGuru;
    final namaDisplay = ds.isLoggedInGuru
        ? 'Guru'
        : ds.isLoggedInSiswa
            ? ds.currentStudent
            : 'Belum Login';
    final emojiRole = ds.isLoggedInGuru ? '👩‍🏫' : '👦';
    final labelRole = ds.isLoggedInGuru
        ? '👩‍🏫 Guru'
        : ds.isLoggedInSiswa
            ? '🎓 Siswa'
            : '👤 Tamu';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sudahLogin
              ? [const Color(0xFFA29BFE), const Color(0xFF6C63FF)]
              : [const Color(0xFF95A5A6), const Color(0xFFBDC3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: (sudahLogin
                      ? const Color(0xFFA29BFE)
                      : const Color(0xFF95A5A6))
                  .withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5)),
          child: Center(
              child: Text(sudahLogin ? emojiRole : '👤',
                  style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(namaDisplay,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
                sudahLogin
                    ? (ds.isLoggedInGuru ? 'guru@bambim.com' : 'Siswa aktif')
                    : 'Tap profil dashboard untuk login',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12)),
          child: Text(labelRole,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3436)));
  }

  Widget _buildSwitchCard(String judul, String sub, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]),
      child: Row(children: [
        Icon(icon, color: const Color(0xFFA29BFE), size: 24),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(judul,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ]),
        ),
        Switch(
            value: value,
            activeColor: const Color(0xFFA29BFE),
            onChanged: onChanged),
      ]),
    );
  }

  Widget _buildInfoCard(String label, String nilai) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(nilai,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436))),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String deskripsi,
    required Color warna,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: warna.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: warna.withOpacity(0.3), width: 1.5),
        ),
        child: Row(children: [
          Icon(icon, color: warna, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14, color: warna)),
              Text(deskripsi,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: warna.withOpacity(0.5)),
        ]),
      ),
    );
  }

  // ── Login Guru ──
  void _showLoginGuru(BuildContext ctx) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? errorMsg;
    bool showPass = false;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          Future<void> doLogin() async {
            final ds = DataService.instance;
            if (!ds.validateTeacher(emailCtrl.text.trim(), passCtrl.text)) {
              setStateDialog(() => errorMsg = 'Email atau password salah!');
              return;
            }
            await ds.loginGuru();
            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            if (ctx.mounted) {
              // ✅ Langsung ke dashboard guru setelah login
              Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (_) => const TeacherDashboardScreen()));
            }
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: const Row(children: [
              Text('👩‍🏫', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(
                  child: Text('Login Guru',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900))),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'guru@bambim.com',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFFA29BFE)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFA29BFE), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (_, setSt) => TextField(
                    controller: passCtrl,
                    obscureText: !showPass,
                    onSubmitted: (_) => doLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: Color(0xFFA29BFE)),
                      suffixIcon: IconButton(
                        icon: Icon(
                            showPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () => setSt(() => showPass = !showPass),
                      ),
                      errorText: errorMsg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFA29BFE), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child:
                      Text('Batal', style: TextStyle(color: Colors.grey[500]))),
              ElevatedButton(
                onPressed: doLogin,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA29BFE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmReset(BuildContext ctx, DataService ds) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Reset Skor?'),
        content:
            const Text('Semua skor dan progress kamu akan dihapus. Yakin?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ds.resetSkorSiswa();
              if (_.mounted) Navigator.pop(_);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('✅ Skor berhasil direset!'),
                    backgroundColor: Color(0xFF4ECDC4)));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white),
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext ctx, DataService ds) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar?'),
        content: const Text('Sesi login kamu akan diakhiri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ds.logout();
              if (_.mounted) Navigator.pop(_);
              if (ctx.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  ctx,
                  '/',
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF636E72),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
