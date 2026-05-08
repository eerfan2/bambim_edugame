import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'student_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';

/// ============================================================
/// SCREEN: RoleSelectionScreen — Pilih Pengguna
/// PR #6: Klik Siswa → popup nama → validasi data
/// PR #7: Klik Guru  → popup email + password
/// ============================================================
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFFFF8C00)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('PILIH PENGGUNA',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3436),
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Siapakah kamu?',
                  style: TextStyle(fontSize: 15, color: Colors.grey[500])),
              const SizedBox(height: 48),
              _RoleCard(
                emoji: '🧒',
                label: 'Siswa',
                description: 'Aku mau belajar mengeja!',
                color: const Color(0xFF4ECDC4),
                onTap: () => _showLoginSiswa(context),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                emoji: '👩‍🏫',
                label: 'Guru',
                description: 'Aku mau kelola materi!',
                color: const Color(0xFFA29BFE),
                onTap: () => _showLoginGuru(context),
              ),
              const Spacer(),
              Text('🌟  Semangat belajar hari ini!  🌟',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400])),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---- POPUP SISWA (PR #6) ----
  void _showLoginSiswa(BuildContext pageCtx) {
    final ctrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: pageCtx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          Future<void> doLogin() async {
            final ds = DataService.instance;
            final nama = ctrl.text.trim();

            if (nama.isEmpty) {
              setState(() => errorMsg = 'Nama tidak boleh kosong');
              return;
            }
            if (!ds.validateStudent(nama)) {
              setState(() => errorMsg = 'Nama tidak terdaftar. Cek ejaan!');
              return;
            }

            await ds.loginSiswa(nama);

            // ✅ Simpan navigator SEBELUM pop dialog agar context tetap valid
            final nav = Navigator.of(pageCtx);
            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            nav.pushReplacement(
              MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
            );
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: const Row(children: [
              Text('🧒', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(
                  child: Text('Masuk sebagai Siswa',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900))),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ketik nama lengkap kamu:',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 10),
                TextField(
                  controller: ctrl,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => doLogin(),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Asep Mahmudin',
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: Color(0xFF4ECDC4)),
                    errorText: errorMsg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tampilkan daftar nama sebagai referensi
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: dialogCtx,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('📋 Daftar Nama Siswa',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: DataService.daftarSiswa
                              .map((s) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(children: [
                                      const Text('👤',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Text(s['nama']!,
                                          style: const TextStyle(fontSize: 14)),
                                    ]),
                                  ))
                              .toList(),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(_),
                              child: const Text('Tutup'))
                        ],
                      ),
                    );
                  },
                  child: const Text('Lihat daftar nama siswa →',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4ECDC4),
                          decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Batal', style: TextStyle(color: Colors.grey[500])),
              ),
              ElevatedButton(
                onPressed: doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- POPUP GURU (PR #7) ----
  void _showLoginGuru(BuildContext pageCtx) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? errorMsg;
    bool showPass = false;

    showDialog(
      context: pageCtx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) {
          Future<void> doLogin() async {
            final ds = DataService.instance;
            if (!ds.validateTeacher(emailCtrl.text.trim(), passCtrl.text)) {
              setState(() => errorMsg = 'Email atau password salah!');
              return;
            }

            await ds.loginGuru();

            // ✅ Simpan navigator SEBELUM pop dialog agar context tetap valid
            final nav = Navigator.of(pageCtx);
            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            nav.pushReplacement(
              MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
            );
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: const Row(children: [
              Text('👩‍🏫', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Expanded(
                  child: Text('Masuk sebagai Guru',
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
                    hintText: 'guru@ejayuk.com',
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
                TextField(
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
                      onPressed: () => setState(() => showPass = !showPass),
                    ),
                    errorText: errorMsg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFA29BFE), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Batal', style: TextStyle(color: Colors.grey[500])),
              ),
              ElevatedButton(
                onPressed: doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA29BFE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---- _RoleCard widget ----
class _RoleCard extends StatefulWidget {
  final String emoji, label, description;
  final Color color;
  final VoidCallback onTap;
  const _RoleCard(
      {required this.emoji,
      required this.label,
      required this.description,
      required this.color,
      required this.onTap});
  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.color.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]),
                child: Center(
                    child: Text(widget.emoji,
                        style: const TextStyle(fontSize: 38))),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: widget.color.withOpacity(0.85))),
                      const SizedBox(height: 4),
                      Text(widget.description,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Pilih  ▶',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
