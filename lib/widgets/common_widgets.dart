import 'package:flutter/material.dart';

/// ============================================================
/// common_widgets.dart — Widget yang Dipakai di Banyak Halaman
/// ============================================================
/// Kumpulan widget kecil yang sering dipakai ulang.
/// Dengan memisahkannya ke sini, setiap halaman tidak perlu
/// menduplikasi kode yang sama.
/// ============================================================

// ---------------------------------------------------------------
// 1. LoadingOverlay — tampilan loading di atas halaman
// ---------------------------------------------------------------
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? pesan;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.pesan,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFF8C00)),
                    ),
                    if (pesan != null) ...[
                      const SizedBox(height: 12),
                      Text(pesan!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// 2. EjaAppBar — AppBar standar aplikasi
// ---------------------------------------------------------------
class EjaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  final Color warna;
  final bool showBack;
  final List<Widget>? actions;

  const EjaAppBar({
    super.key,
    required this.judul,
    this.warna = const Color(0xFFFF8C00),
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: warna,
      automaticallyImplyLeading: showBack,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(judul,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      centerTitle: true,
      actions: actions,
    );
  }
}

// ---------------------------------------------------------------
// 3. EjaCard — Card umum dengan shadow
// ---------------------------------------------------------------
class EjaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double radius;
  final Color? shadowColor;

  const EjaCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 18,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? Colors.black).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------
// 4. EjaButton — Tombol utama aplikasi
// ---------------------------------------------------------------
class EjaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool outlined;
  final double? width;

  const EjaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.outlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? const Color(0xFFFF8C00);

    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: btnColor, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Icon(icon ?? Icons.check, color: btnColor),
          label: Text(label,
              style: TextStyle(
                  color: btnColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? btnColor : Colors.grey[300],
          foregroundColor: textColor ?? Colors.white,
          elevation: onPressed != null ? 4 : 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 5. NyawaIndicator — Indikator nyawa (3 bulatan)
// ---------------------------------------------------------------
class NyawaIndicator extends StatelessWidget {
  final int nyawa;
  final int maxNyawa;

  const NyawaIndicator({super.key, required this.nyawa, this.maxNyawa = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          maxNyawa,
          (i) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: i < nyawa
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              )),
    );
  }
}

// ---------------------------------------------------------------
// 6. ProgressBarStage — Progress bar dengan label soal
// ---------------------------------------------------------------
class ProgressBarStage extends StatelessWidget {
  final int soalSaat;
  final int totalSoal;
  final double progress;

  const ProgressBarStage({
    super.key,
    required this.soalSaat,
    required this.totalSoal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Soal $soalSaat/$totalSoal',
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------
// 7. FeedbackWidget — Kotak "Benar!" / "Salah!"
// ---------------------------------------------------------------
class FeedbackWidget extends StatelessWidget {
  final bool benar;
  final String? pesanTambahan;

  const FeedbackWidget({super.key, required this.benar, this.pesanTambahan});

  @override
  Widget build(BuildContext context) {
    final warna = benar ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    final warnaText = benar ? const Color(0xFF27AE60) : const Color(0xFFC0392B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna, width: 1.5),
      ),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(benar ? '🎉' : '😅', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(benar ? 'Benar! +20 poin' : 'Coba Lagi!',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: warnaText)),
              if (pesanTambahan != null)
                Text(pesanTambahan!,
                    style: TextStyle(fontSize: 11, color: warnaText)),
            ]),
          ]),
    );
  }
}

// ---------------------------------------------------------------
// 8. EmptyState — Tampilan halaman kosong
// ---------------------------------------------------------------
class EmptyState extends StatelessWidget {
  final String emoji;
  final String judul;
  final String? deskripsi;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.judul,
    this.deskripsi,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(judul,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436))),
            if (deskripsi != null) ...[
              const SizedBox(height: 8),
              Text(deskripsi!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[500], height: 1.5)),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
