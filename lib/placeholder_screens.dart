// ============================================================
// placeholder_screens.dart — Re-export semua screen
// ============================================================
export 'screens/belajar_huruf_screen.dart';
export 'screens/mengeja_kata_screen.dart';
export 'screens/progress_screen.dart';
export 'screens/teacher_dashboard_screen.dart';
export 'screens/stage_select_screen.dart';
export 'screens/stage_engine.dart';
export 'screens/hasil_screen.dart';

import 'package:flutter/material.dart';
import 'screens/stage_select_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  @override
  Widget build(BuildContext context) => const StageSelectScreen();
}
