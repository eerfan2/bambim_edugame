import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

/// ============================================================
/// SCREEN: ProgressScreen
/// PR #9: Data diambil dari nilai asli penyelesaian stage
/// ============================================================
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _stageMeta = [
    {'nomor': 1, 'nama': 'Stage 1', 'subjudul': 'Tebak Huruf'},
    {'nomor': 2, 'nama': 'Stage 2', 'subjudul': 'Susun Kata'},
    {'nomor': 3, 'nama': 'Stage 3', 'subjudul': 'Ejaan Panjang'},
    {'nomor': 4, 'nama': 'Stage 4', 'subjudul': 'Tantangan'},
    {'nomor': 5, 'nama': 'Stage 5', 'subjudul': 'Master Ejaan'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(builder: (ctx, ds, _) {
      final selesai = _stageMeta
          .where((s) => ds.isStageCompleted(s['nomor'] as int))
          .length;
      final rataSkor = ds.rataSkorSiswa;

      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFA29BFE),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Progres Saya',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header ringkasan
                _buildHeader(selesai, rataSkor),
                const SizedBox(height: 24),

                const Text('📊  Detail Per Stage',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3436))),
                const SizedBox(height: 14),

                // List stage cards
                ..._stageMeta.map((meta) {
                  final nomor = meta['nomor'] as int;
                  final skor = ds.getStageScore(nomor);
                  final selesai = ds.isStageCompleted(nomor);
                  final unlock = ds.isStageUnlocked(nomor);
                  final bintang = ds.getStageBintang(nomor);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _StageCard(
                      nama: meta['nama'] as String,
                      subjudul: meta['subjudul'] as String,
                      skor: skor,
                      selesai: selesai,
                      unlock: unlock,
                      bintang: bintang,
                    ),
                  );
                }),

                // Banner rata-rata skor
                _buildRataSkor(rataSkor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(int selesai, double rataSkor) {
    return Container(
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
        const Text('🏆', style: TextStyle(fontSize: 52)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pencapaianmu',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('$selesai dari ${DataService.totalStage} Stage',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                  value: selesai / DataService.totalStage,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white))),
        ])),
      ]),
    );
  }

  Widget _buildRataSkor(double rataSkor) {
    final skor = rataSkor.round();
    String label;
    Color warna;
    if (skor >= 80) {
      label = 'Luar Biasa! 🌟';
      warna = const Color(0xFF27AE60);
    } else if (skor >= 60) {
      label = 'Bagus 👍';
      warna = const Color(0xFF2980B9);
    } else if (skor >= 40) {
      label = 'Cukup Baik 😊';
      warna = const Color(0xFFFF8C00);
    } else if (skor > 0) {
      label = 'Terus Semangat! 💪';
      warna = const Color(0xFFE74C3C);
    } else {
      label = 'Belum ada data';
      warna = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Column(children: [
        const Text('Rata-rata Skor',
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: rataSkor / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(warna))),
        const SizedBox(height: 12),
        Text('$skor',
            style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900, color: warna)),
        Text(label,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: warna)),
      ]),
    );
  }
}

class _StageCard extends StatelessWidget {
  final String nama, subjudul;
  final int skor, bintang;
  final bool selesai, unlock;
  const _StageCard(
      {required this.nama,
      required this.subjudul,
      required this.skor,
      required this.selesai,
      required this.unlock,
      required this.bintang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: unlock ? Colors.white : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: unlock
                ? const Color(0xFFA29BFE).withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1.5),
        boxShadow: unlock
            ? [
                BoxShadow(
                    color: const Color(0xFFA29BFE).withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        unlock ? const Color(0xFF2D3436) : Colors.grey[500])),
            Text(subjudul,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ]),
          // Skor atau ikon status
          if (unlock && selesai)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFA29BFE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('$skor',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6C63FF))),
            )
          else
            Icon(unlock ? Icons.play_circle_rounded : Icons.lock_rounded,
                color: unlock ? const Color(0xFF4ECDC4) : Colors.grey[400],
                size: 32),
        ]),
        const SizedBox(height: 12),

        // Progress bar (dari skor nyata)
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: selesai ? skor / 100 : 0,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(selesai
                  ? (skor >= 80
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFA29BFE))
                  : Colors.grey[300]!),
            )),
        const SizedBox(height: 10),

        // Bintang
        Row(
            children: List.generate(
                3,
                (i) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(i < bintang ? '⭐' : '☆',
                          style: TextStyle(
                              fontSize: 20,
                              color: i < bintang
                                  ? Colors.amber
                                  : Colors.grey[300])),
                    ))),
      ]),
    );
  }
}
