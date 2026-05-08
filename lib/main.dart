import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'services/data_service.dart';

/// ============================================================
/// ENTRY POINT APLIKASI
/// ============================================================
void main() async {
  // Wajib ada sebelum memanggil plugin/service apapun
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi DataService (SharedPreferences) sebelum runApp
  await DataService.instance.init();

  runApp(
    // ✅ Daftarkan DataService sebagai Provider agar bisa dipakai
    // Consumer<DataService> di seluruh widget tree
    ChangeNotifierProvider<DataService>.value(
      value: DataService.instance,
      child: const BambimEduGameApp(),
    ),
  );
}

/// Widget root aplikasi (tidak berubah / Stateless).
class BambimEduGameApp extends StatelessWidget {
  const BambimEduGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi (muncul di app switcher)
      title: 'Eja Yuk!',

      // Hilangkan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,

      // ---- TEMA GLOBAL ----
      theme: ThemeData(
        // Skema warna utama: oranye cerah (ramah anak)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C00),
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Warna AppBar default
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF8C00),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // Gaya teks global — besar agar mudah dibaca anak
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w900,
            fontSize: 32,
          ),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),

      // Halaman pertama: Welcome → RoleSelection → Dashboard
      home: const WelcomeScreen(),
    );
  }
}
