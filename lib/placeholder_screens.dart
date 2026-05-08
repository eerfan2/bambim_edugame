// ============================================================
// placeholder_screens.dart  —  Re-export semua screen nyata
// ============================================================
export 'screens/belajar_huruf_screen.dart';
export 'screens/mengeja_kata_screen.dart';
export 'screens/progress_screen.dart';
export 'screens/teacher_dashboard_screen.dart';
export 'screens/stage_select_screen.dart';
export 'screens/stage1_screen.dart';
export 'screens/stage2_screen.dart';
export 'screens/hasil_screen.dart';

// Dummy GameScreen → arahkan ke StageSelectScreen
import 'package:flutter/material.dart';
import 'screens/stage_select_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Langsung tampilkan StageSelectScreen saat menu "Permainan" diklik
    return const StageSelectScreen();
  }
}
