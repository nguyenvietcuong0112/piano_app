import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  runApp(const RealPianoApp());
}

class RealPianoApp extends StatelessWidget {
  const RealPianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Piano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.amber,
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          surface: Color(0xFF1E1E2C),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
