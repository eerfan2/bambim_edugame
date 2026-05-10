import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ============================================================
/// SERVICE: DataService
/// ✅ UPDATE: Login sekarang opsional (mode tamu didukung)
/// - Tanpa login → bisa akses belajar, tidak bisa akses Game
/// - Login siswa via profil / saat buka Game
/// - Login guru via halaman Pengaturan
/// ============================================================
class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;
  DataService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Stage 1 selalu terbuka
    if (!(_prefs!.containsKey('stage_unlocked_1'))) {
      await _prefs!.setBool('stage_unlocked_1', true);
    }
  }

  SharedPreferences get _p {
    assert(_initialized, 'DataService belum diinisialisasi!');
    return _prefs!;
  }

  // ============================================================
  // DATA SISWA
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
  // KREDENSIAL GURU
  // ============================================================
  static const String _guruEmail = 'guru@bambim.com';
  static const String _guruPassword = 'guru123';

  // ============================================================
  // VALIDASI LOGIN
  // ============================================================
  bool validateStudent(String nama) {
    final trimmed = nama.trim();
    return daftarSiswa
        .any((s) => s['nama']!.toLowerCase() == trimmed.toLowerCase());
  }

  Map<String, String>? getStudentData(String nama) {
    try {
      return daftarSiswa.firstWhere(
          (s) => s['nama']!.toLowerCase() == nama.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  bool validateTeacher(String email, String password) {
    return email.trim() == _guruEmail && password == _guruPassword;
  }

  // ============================================================
  // SESI LOGIN
  // ✅ UPDATE: isLoggedIn terpisah dari isGuru
  // ============================================================
  String get currentStudent => _p.getString('current_student') ?? '';
  String get currentRole => _p.getString('current_role') ?? '';

  /// Apakah sudah login sebagai siswa
  bool get isLoggedInSiswa =>
      currentRole == 'siswa' && currentStudent.isNotEmpty;

  /// Apakah sudah login sebagai guru
  bool get isLoggedInGuru => currentRole == 'guru';

  /// Apakah sudah login (siswa atau guru)
  bool get isLoggedIn => isLoggedInSiswa || isLoggedInGuru;

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

  bool isStageUnlocked(int stage) {
    if (stage == 1) return true;
    return _p.getBool('stage_unlocked_$stage') ?? false;
  }

  bool isStageCompleted(int stage) {
    if (!isLoggedInSiswa) return false;
    return _p.getBool('completed_${currentStudent}_$stage') ?? false;
  }

  Future<void> guruUnlockStage(int stage) async {
    final sudahTerbuka = isStageUnlocked(stage);
    await _p.setBool('stage_unlocked_$stage', true);
    if (!sudahTerbuka) {
      await _tambahNotifikasi(
        judul: '🔓 Stage Baru Terbuka!',
        isi: 'Stage $stage sudah dibuka oleh guru. Ayo main!',
        stage: stage,
      );
    }
    notifyListeners();
  }

  Future<void> guruLockStage(int stage) async {
    if (stage == 1) return;
    await _p.setBool('stage_unlocked_$stage', false);
    notifyListeners();
  }

  // ============================================================
  // SKOR SISWA
  // ============================================================
  int getStageScore(int stage) {
    if (!isLoggedInSiswa) return 0;
    return _p.getInt('score_${currentStudent}_$stage') ?? 0;
  }

  int getStageBintang(int stage) {
    if (!isStageCompleted(stage)) return 0;
    final skor = getStageScore(stage);
    if (skor >= 80) return 3;
    if (skor >= 50) return 2;
    return 1;
  }

  Future<void> simpanSkorStage(int stage, int skor) async {
    if (!isLoggedInSiswa) return;
    final keyScore = 'score_${currentStudent}_$stage';
    final keyDone = 'completed_${currentStudent}_$stage';
    final skorLama = getStageScore(stage);
    if (skor > skorLama) await _p.setInt(keyScore, skor);
    await _p.setBool(keyDone, true);
    notifyListeners();
  }

  double get rataSkorSiswa {
    if (!isLoggedInSiswa) return 0;
    final selesai = List.generate(totalStage, (i) => i + 1)
        .where((s) => isStageCompleted(s))
        .toList();
    if (selesai.isEmpty) return 0;
    final total = selesai.fold<int>(0, (sum, s) => sum + getStageScore(s));
    return total / selesai.length;
  }

  int get stageAktifSiswa {
    for (int s = totalStage; s >= 1; s--) {
      if (isStageUnlocked(s)) return s;
    }
    return 1;
  }

  // ============================================================
  // DATA SEMUA SISWA (untuk dashboard guru)
  // ============================================================
  int getSkorSiswaStage(String namaSiswa, int stage) {
    return _p.getInt('score_${namaSiswa}_$stage') ?? 0;
  }

  bool isSiswaSelesaiStage(String namaSiswa, int stage) {
    return _p.getBool('completed_${namaSiswa}_$stage') ?? false;
  }

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
    return (totalSkor / jumlahSelesai) / 100;
  }

  // ============================================================
  // NOTIFIKASI
  // ============================================================
  bool get adaNotifikasiBaru => _p.getBool('notif_unread') ?? false;

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
    await _p.setStringList('notifications', list.take(20).toList());
    await _p.setBool('notif_unread', true);
    notifyListeners();
  }

  Future<void> tandaiNotifikasiDibaca() async {
    await _p.setBool('notif_unread', false);
    final list = getNotifikasi();
    final updated = list.map((n) {
      n['dibaca'] = true;
      return json.encode(n);
    }).toList();
    await _p.setStringList('notifications', updated);
    notifyListeners();
  }

  // ============================================================
  // RESET DATA
  // ============================================================
  Future<void> resetAllData() async {
    await _p.clear();
    await _p.setBool('stage_unlocked_1', true);
    notifyListeners();
  }

  Future<void> resetSkorSiswa() async {
    if (!isLoggedInSiswa) return;
    for (int s = 1; s <= totalStage; s++) {
      await _p.remove('score_${currentStudent}_$s');
      await _p.remove('completed_${currentStudent}_$s');
    }
    notifyListeners();
  }
}
