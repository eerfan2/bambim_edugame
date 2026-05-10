import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.instance.init();
  runApp(
    ChangeNotifierProvider<DataService>.value(
      value: DataService.instance,
      child: const BambimEdugameApp(),
    ),
  );
}

class BambimEdugameApp extends StatelessWidget {
  const BambimEdugameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bambim Edugame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C00),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF8C00),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 32),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      // ✅ Langsung ke WelcomeScreen (auto redirect ke Dashboard Murid)
      home: const WelcomeScreen(),
    );
  }
}
