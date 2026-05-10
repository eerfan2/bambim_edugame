/// ============================================================
/// MODEL: StageSoalModel
/// Berisi semua data soal untuk Stage 1–5
///
/// TIPE SOAL:
///   TipeA → Tebak Huruf (Pilihan Ganda)
///   TipeB → Susun Kata  (Tap Huruf)
///   TipeC → Soal tambahan (Mengenal huruf, bunyi, suku kata, dst)
///
/// STRUKTUR PER STAGE (total 5 soal):
///   Stage 1 → 3 TipeA + 2 TipeC (Mengenal bentuk & bunyi huruf)
///   Stage 2 → 2 TipeA + 1 TipeB + 2 TipeC (Hubungkan huruf & gambar)
///   Stage 3 → 1 TipeA + 2 TipeB + 2 TipeC (Suku kata)
///   Stage 4 → 3 TipeB + 2 TipeC (Membaca kata utuh)
///   Stage 5 → 1 TipeB + 2 TipeC berat (Kalimat pendek)
///
/// SISTEM POIN:
///   Benar pertama kali → +20
///   Benar setelah hint → +10
///   Salah              → -1 nyawa
///   Selesai tanpa salah→ bonus +10
/// ============================================================

enum TipeSoal { tipeA, tipeB, tipeC }

enum TipeC {
  mengenalBentukHuruf, // Stage 1   → identifikasi bentuk huruf
  mengenalBunyiHuruf, // Stage 1-2 → pilih huruf dari bunyi
  hubungkanHurufGambar, // Stage 2   → cocokkan huruf ke gambar
  menyusunKata, // Stage 2-3 → susun suku kata
  membacaSukuKata, // Stage 3-4 → baca suku kata yang tepat
  membacaKataUtuh, // Stage 4-5 → pilih kata yang sesuai gambar
  membacaKalimatPendek, // Stage 5   → pilih kalimat yang benar
}

// ── Model untuk satu soal ──
class Soal {
  final TipeSoal tipe;
  final TipeC? tipeC; // Hanya diisi jika tipe == tipeC
  final String pertanyaan; // Teks instruksi/pertanyaan
  final String? huruf; // Untuk TipeA
  final String? emoji; // Gambar pendukung
  final String? contoh; // Kata contoh
  final List<String> pilihan; // Pilihan jawaban (TipeA & TipeC)
  final int? indexBenar; // Index jawaban benar (TipeA & TipeC)
  final String? kata; // Kata yang disusun (TipeB)

  const Soal({
    required this.tipe,
    this.tipeC,
    required this.pertanyaan,
    this.huruf,
    this.emoji,
    this.contoh,
    this.pilihan = const [],
    this.indexBenar,
    this.kata,
  });
}

// ============================================================
// DATA SOAL STAGE 1
// Kata 2-3 huruf, fokus huruf vokal & konsonan dasar
// 3 TipeA + 2 TipeC (Mengenal bentuk + bunyi huruf)
// ============================================================
const List<Soal> soalStage1 = [
  // ── TipeA: Tebak Huruf ──
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'A',
    emoji: '🐔',
    contoh: 'Ayam',
    pilihan: ['A', 'B', 'C'],
    indexBenar: 0,
  ),
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'I',
    emoji: '🐟',
    contoh: 'Ikan',
    pilihan: ['H', 'I', 'J'],
    indexBenar: 1,
  ),
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'U',
    emoji: '🐛',
    contoh: 'Ulat',
    pilihan: ['U', 'V', 'W'],
    indexBenar: 0,
  ),

  // ── TipeC: Mengenal Bentuk Huruf ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.mengenalBentukHuruf,
    pertanyaan: 'Pilih huruf yang SAMA dengan ini:',
    huruf: 'B',
    pilihan: ['D', 'B', 'P'],
    indexBenar: 1,
  ),

  // ── TipeC: Mengenal Bunyi Huruf ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.mengenalBunyiHuruf,
    pertanyaan: 'Gambar ini diawali dengan huruf apa?',
    emoji: '🐘',
    contoh: 'Gajah',
    pilihan: ['A', 'G', 'J'],
    indexBenar: 1,
  ),
];

// ============================================================
// DATA SOAL STAGE 2
// Kata 3-4 huruf, mulai susun kata
// 2 TipeA + 1 TipeB + 2 TipeC
// ============================================================
const List<Soal> soalStage2 = [
  // ── TipeA ──
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'D',
    emoji: '🍭',
    contoh: 'Donat',
    pilihan: ['B', 'D', 'E'],
    indexBenar: 1,
  ),
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'K',
    emoji: '🐰',
    contoh: 'Kelinci',
    pilihan: ['K', 'L', 'M'],
    indexBenar: 0,
  ),

  // ── TipeB: Susun Kata ──
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '⚽',
    contoh: 'Bola',
    kata: 'BOLA',
  ),

  // ── TipeC: Mengenal Bunyi Huruf ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.mengenalBunyiHuruf,
    pertanyaan: 'Gambar ini diawali dengan huruf apa?',
    emoji: '🐰',
    contoh: 'Kelinci',
    pilihan: ['B', 'K', 'M'],
    indexBenar: 1,
  ),

  // ── TipeC: Hubungkan Huruf & Gambar ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.hubungkanHurufGambar,
    pertanyaan: 'Gambar 🐟 cocok dengan kata apa?',
    pilihan: ['BOLA', 'IKAN', 'APEL'],
    indexBenar: 1,
  ),
];

// ============================================================
// DATA SOAL STAGE 3
// Kata 4-5 huruf, suku kata
// 1 TipeA + 2 TipeB + 2 TipeC
// ============================================================
const List<Soal> soalStage3 = [
  // ── TipeA ──
  Soal(
    tipe: TipeSoal.tipeA,
    pertanyaan: 'Huruf apakah ini?',
    huruf: 'S',
    emoji: '🐄',
    contoh: 'Sapi',
    pilihan: ['R', 'S', 'T'],
    indexBenar: 1,
  ),

  // ── TipeB ──
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🍎',
    contoh: 'Apel',
    kata: 'APEL',
  ),
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🦆',
    contoh: 'Bebek',
    kata: 'BEBEK',
  ),

  // ── TipeC: Menyusun Kata ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.menyusunKata,
    pertanyaan: 'Suku kata mana yang melengkapi: SA-...',
    pilihan: ['PI', 'BA', 'KU'],
    indexBenar: 0,
    emoji: '🐄',
    contoh: 'Sapi',
  ),

  // ── TipeC: Membaca Suku Kata ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaSukuKata,
    pertanyaan: 'Pilih suku kata yang benar untuk gambar ini 🍌',
    pilihan: ['PI-SANG', 'BA-TU', 'SA-PI'],
    indexBenar: 0,
  ),
];

// ============================================================
// DATA SOAL STAGE 4
// Kata 5-6 huruf, TipeB dominan
// 3 TipeB + 2 TipeC
// ============================================================
const List<Soal> soalStage4 = [
  // ── TipeB ──
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🐰',
    contoh: 'Kelinci',
    kata: 'KELINCI',
  ),
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🌹',
    contoh: 'Mawar',
    kata: 'MAWAR',
  ),
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🍍',
    contoh: 'Nanas',
    kata: 'NANAS',
  ),

  // ── TipeC: Membaca Suku Kata ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaSukuKata,
    pertanyaan: 'Suku kata mana yang benar untuk 🐰?',
    pilihan: ['KE-LIN-CI', 'SA-PI', 'BE-BEK'],
    indexBenar: 0,
  ),

  // ── TipeC: Membaca Kata Utuh ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaKataUtuh,
    pertanyaan: 'Pilih kata yang sesuai gambar 🌹',
    pilihan: ['NANAS', 'MAWAR', 'KELINCI'],
    indexBenar: 1,
  ),
];

// ============================================================
// DATA SOAL STAGE 5
// Kata 6-8 huruf, TipeB + kalimat pendek
// 1 TipeA + 2 TipeB + 2 TipeC
// ============================================================
const List<Soal> soalStage5 = [
  // ── TipeB ──
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🐯',
    contoh: 'Harimau',
    kata: 'HARIMAU',
  ),
  Soal(
    tipe: TipeSoal.tipeB,
    pertanyaan: 'Susun huruf menjadi kata!',
    emoji: '🦒',
    contoh: 'Jerapah',
    kata: 'JERAPAH',
  ),

  // ── TipeC: Membaca Kata Utuh ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaKataUtuh,
    pertanyaan: 'Pilih kata yang sesuai gambar 🦒',
    pilihan: ['HARIMAU', 'JERAPAH', 'KELINCI'],
    indexBenar: 1,
  ),

  // ── TipeC: Membaca Kalimat Pendek ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaKalimatPendek,
    pertanyaan: 'Pilih kalimat yang benar:',
    emoji: '🐯',
    pilihan: [
      'Harimau makan rumput',
      'Harimau adalah hewan buas',
      'Harimau bisa terbang',
    ],
    indexBenar: 1,
  ),

  // ── TipeC: Membaca Kalimat Pendek ──
  Soal(
    tipe: TipeSoal.tipeC,
    tipeC: TipeC.membacaKalimatPendek,
    pertanyaan: 'Kalimat yang tepat untuk 🦒 adalah:',
    pilihan: [
      'Jerapah punya leher panjang',
      'Jerapah hidup di laut',
      'Jerapah bisa berbicara',
    ],
    indexBenar: 0,
  ),
];
