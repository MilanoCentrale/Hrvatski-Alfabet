import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CroatianAlphabetApp());
}

class CroatianAlphabetApp extends StatelessWidget {
  const CroatianAlphabetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Croatian Alphabet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
