import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ============================================================
/// SERVICE: DataService (Database Lokal)
/// ============================================================
/// Singleton yang mengelola SEMUA data persisten aplikasi
/// menggunakan SharedPreferences (penyimpanan lokal di HP).
///
/// Cara pakai: DataService.instance.namaMethod()
///
/// Data yang disimpan:
///   - Sesi login (nama siswa / role)
///   - Status unlock setiap stage
///   - Skor setiap stage per siswa
///   - Notifikasi
///
/// Cara migrasi ke Firebase nanti:
///   Cukup ganti implementasi setiap method, interface tetap sama.
/// ============================================================
class DataService extends ChangeNotifier {
  // ---- SINGLETON PATTERN ----
  // Satu instance untuk seluruh app
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;
  DataService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // ============================================================
  // INISIALISASI — panggil di main() sebelum runApp()
  // ============================================================
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Pastikan Stage 1 selalu terbuka (default)
    if (!(_prefs!.containsKey('stage_unlocked_1'))) {
      await _prefs!.setBool('stage_unlocked_1', true);
    }
  }

  SharedPreferences get _p {
    assert(
      _initialized,
      'DataService belum diinisialisasi! Panggil await DataService.instance.init() dulu.',
    );
    return _prefs!;
  }

  // ============================================================
  // DATA SISWA (Hardcoded — nanti bisa dari database server)
  // ============================================================
  static const List<Map<String, String>> daftarSiswa = [
    {'nama': 'Asep Mahmudin', 'kelas': 'TK A'},
    {'nama': 'Budi Santoso', 'kelas': 'TK A'},
    {'nama': 'Siti Rahayu', 'kelas': 'TK B'},
    {'nama': 'Andi Wijaya', 'kelas': 'TK A'},
    {'nama': 'Dewi Lestari', 'kelas': 'TK B'},
    {'nama': 'Reza Pratama', 'kelas': 'TK A'},
    {'nama': 'Nina Safitri', 'kelas': 'TK B'},
  ];

  // ============================================================
  // KREDENSIAL GURU (Hardcoded)
  // ============================================================
  static const String _guruEmail = 'guru@ejayuk.com';
  static const String _guruPassword = 'guru123';

  // ============================================================
  // VALIDASI LOGIN
  // ============================================================

  /// Validasi nama siswa → true jika ada di daftarSiswa
  bool validateStudent(String nama) {
    final trimmed = nama.trim();
    return daftarSiswa.any(
      (s) => s['nama']!.toLowerCase() == trimmed.toLowerCase(),
    );
  }

  /// Ambil data siswa berdasarkan nama
  Map<String, String>? getStudentData(String nama) {
    try {
      return daftarSiswa.firstWhere(
        (s) => s['nama']!.toLowerCase() == nama.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Validasi login guru
  bool validateTeacher(String email, String password) {
    return email.trim() == _guruEmail && password == _guruPassword;
  }

  // ============================================================
  // SESI LOGIN
  // ============================================================
  String get currentStudent => _p.getString('current_student') ?? '';
  String get currentRole => _p.getString('current_role') ?? '';
  bool get isLoggedIn => currentStudent.isNotEmpty || currentRole == 'guru';

  Future<void> loginSiswa(String nama) async {
    await _p.setString('current_student', nama.trim());
    await _p.setString('current_role', 'siswa');
    notifyListeners();
  }

  Future<void> loginGuru() async {
    await _p.setString('current_role', 'guru');
    notifyListeners();
  }

  Future<void> logout() async {
    await _p.remove('current_student');
    await _p.remove('current_role');
    notifyListeners();
  }

  // ============================================================
  // STATUS STAGE
  // ============================================================
  static const int totalStage = 5;

  /// Apakah stage X sudah terbuka?
  bool isStageUnlocked(int stage) {
    if (stage == 1) return true; // Stage 1 selalu terbuka
    return _p.getBool('stage_unlocked_$stage') ?? false;
  }

  /// Apakah stage X sudah diselesaikan siswa ini?
  bool isStageCompleted(int stage) {
    final key = 'completed_${currentStudent}_$stage';
    return _p.getBool(key) ?? false;
  }

  /// Guru membuka stage baru
  Future<void> guruUnlockStage(int stage) async {
    final sudahTerbuka = isStageUnlocked(stage);
    await _p.setBool('stage_unlocked_$stage', true);

    // Hanya buat notifikasi jika belum pernah dibuka sebelumnya
    if (!sudahTerbuka) {
      await _tambahNotifikasi(
        judul: '🔓 Stage Baru Terbuka!',
        isi: 'Stage $stage sudah dibuka oleh guru. Ayo main!',
        stage: stage,
      );
    }
    notifyListeners();
  }

  /// Guru menutup stage kembali (toggle)
  Future<void> guruLockStage(int stage) async {
    if (stage == 1) return; // Stage 1 tidak bisa dikunci
    await _p.setBool('stage_unlocked_$stage', false);
    notifyListeners();
  }

  // ============================================================
  // SKOR SISWA
  // ============================================================

  /// Ambil skor stage X untuk siswa yang sedang login
  int getStageScore(int stage) {
    final key = 'score_${currentStudent}_$stage';
    return _p.getInt(key) ?? 0;
  }

  /// Jumlah bintang stage X (0–3)
  int getStageBintang(int stage) {
    if (!isStageCompleted(stage)) return 0;
    final skor = getStageScore(stage);
    if (skor >= 80) return 3;
    if (skor >= 50) return 2;
    return 1;
  }

  /// Simpan skor setelah menyelesaikan stage
  Future<void> simpanSkorStage(int stage, int skor) async {
    final keyScore = 'score_${currentStudent}_$stage';
    final keyDone = 'completed_${currentStudent}_$stage';

    // Simpan skor tertinggi saja (tidak overwrite jika skor lebih rendah)
    final skorLama = getStageScore(stage);
    if (skor > skorLama) {
      await _p.setInt(keyScore, skor);
    }
    await _p.setBool(keyDone, true);
    notifyListeners();
  }

  /// Rata-rata skor semua stage yang selesai
  double get rataSkorSiswa {
    final stageSelesai = List.generate(
      totalStage,
      (i) => i + 1,
    ).where((s) => isStageCompleted(s)).toList();
    if (stageSelesai.isEmpty) return 0;
    final total = stageSelesai.fold<int>(0, (sum, s) => sum + getStageScore(s));
    return total / stageSelesai.length;
  }

  /// Stage terakhir yang bisa dimainkan (sudah selesai stage sebelumnya)
  int get stageAktifSiswa {
    for (int s = totalStage; s >= 1; s--) {
      if (isStageUnlocked(s)) return s;
    }
    return 1;
  }

  // ============================================================
  // DATA SEMUA SISWA (untuk dashboard guru)
  // ============================================================

  /// Ambil skor stage X untuk siswa tertentu
  int getSkorSiswaStage(String namaSiswa, int stage) {
    final key = 'score_${namaSiswa}_$stage';
    return _p.getInt(key) ?? 0;
  }

  bool isSiswaSelesaiStage(String namaSiswa, int stage) {
    final key = 'completed_${namaSiswa}_$stage';
    return _p.getBool(key) ?? false;
  }

  /// Persentase penyelesaian gabungan untuk seorang siswa (0.0–1.0)
  double persentaseSiswa(String namaSiswa) {
    int totalSkor = 0;
    int jumlahSelesai = 0;
    for (int s = 1; s <= totalStage; s++) {
      if (isSiswaSelesaiStage(namaSiswa, s)) {
        totalSkor += getSkorSiswaStage(namaSiswa, s);
        jumlahSelesai++;
      }
    }
    if (jumlahSelesai == 0) return 0;
    // Rata-rata skor / 100 sebagai persentase
    return (totalSkor / jumlahSelesai) / 100;
  }

  // ============================================================
  // NOTIFIKASI
  // ============================================================

  /// Apakah ada notifikasi belum dibaca?
  bool get adaNotifikasiBaru {
    return _p.getBool('notif_unread') ?? false;
  }

  /// Ambil semua notifikasi (list JSON)
  List<Map<String, dynamic>> getNotifikasi() {
    final raw = _p.getStringList('notifications') ?? [];
    return raw
        .map((s) {
          try {
            return Map<String, dynamic>.from(json.decode(s));
          } catch (_) {
            return <String, dynamic>{};
          }
        })
        .where((m) => m.isNotEmpty)
        .toList();
  }

  Future<void> _tambahNotifikasi({
    required String judul,
    required String isi,
    int? stage,
  }) async {
    final notif = {
      'judul': judul,
      'isi': isi,
      'stage': stage,
      'waktu': DateTime.now().toIso8601String(),
      'dibaca': false,
    };
    final list = _p.getStringList('notifications') ?? [];
    list.insert(0, json.encode(notif));
    // Simpan maksimal 20 notifikasi
    await _p.setStringList('notifications', list.take(20).toList());
    await _p.setBool('notif_unread', true);
    notifyListeners();
  }

  Future<void> tandaiNotifikasiDibaca() async {
    await _p.setBool('notif_unread', false);
    // Tandai semua notifikasi sebagai dibaca
    final list = getNotifikasi();
    final updated = list.map((n) {
      n['dibaca'] = true;
      return json.encode(n);
    }).toList();
    await _p.setStringList('notifications', updated);
    notifyListeners();
  }

  // ============================================================
  // RESET / CLEAR DATA (untuk testing)
  // ============================================================
  Future<void> resetAllData() async {
    await _p.clear();
    await _p.setBool('stage_unlocked_1', true);
    notifyListeners();
  }

  Future<void> resetSkorSiswa() async {
    for (int s = 1; s <= totalStage; s++) {
      await _p.remove('score_${currentStudent}_$s');
      await _p.remove('completed_${currentStudent}_$s');
    }
    notifyListeners();
  }
}
