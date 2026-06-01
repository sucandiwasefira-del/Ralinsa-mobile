import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const RalinsaBitesApp());
}

class RalinsaBitesApp extends StatelessWidget {
  const RalinsaBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Serif',
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      ),
      // UBAH BAGIAN INI:
      home: const LoginPage(), 
    );
  }
}