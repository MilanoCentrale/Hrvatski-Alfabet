// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/croatian_alphabet.dart';
import 'flashcard_screen.dart';
import 'grid_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<String> _learnedLetters = {};

  @override
  void initState() {
    super.initState();
    _loadLearned();
  }

  Future<void> _loadLearned() async {
    final prefs = await SharedPreferences.getInstance();
    final learned = prefs.getStringList('learned_letters') ?? [];
    setState(() => _learnedLetters = learned.toSet());
  }

  int get _learnedCount => _learnedLetters.length;
  int get _totalCount => croatianAlphabet.length;
  double get _progress => _learnedCount / _totalCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Flag + Title
                Row(
                  children: [
                    const Text('🇭🇷', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Croatian',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Alphabet',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Progress card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_learnedCount / $_totalCount letters learned',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white24,
                          color: Colors.greenAccent.shade400,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Start Learning button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.school_rounded, size: 24),
                    label: Text(
                      'Start Learning',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardScreen(
                            initialIndex: 0,
                            learnedLetters: _learnedLetters,
                          ),
                        ),
                      );
                      _loadLearned();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Browse All Letters button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 22),
                    label: Text(
                      'Browse All Letters',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GridScreen(
                            learnedLetters: _learnedLetters,
                          ),
                        ),
                      );
                      _loadLearned();
                    },
                  ),
                ),

                const Spacer(),

                // Footer
                Center(
                  child: Text(
                    '30 letters • Audio • IPA pronunciation',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
