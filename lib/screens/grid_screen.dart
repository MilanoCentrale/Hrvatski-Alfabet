// lib/screens/grid_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/croatian_alphabet.dart';
import 'flashcard_screen.dart';

class GridScreen extends StatefulWidget {
  final Set<String> learnedLetters;

  const GridScreen({super.key, required this.learnedLetters});

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  late Set<String> _learnedLetters;

  @override
  void initState() {
    super.initState();
    _learnedLetters = Set.from(widget.learnedLetters);
  }

  Future<void> _loadLearned() async {
    final prefs = await SharedPreferences.getInstance();
    final learned = prefs.getStringList('learned_letters') ?? [];
    setState(() => _learnedLetters = learned.toSet());
  }

  // Pastel tile colors
  static const List<Color> _tileColors = [
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'All Letters',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_learnedLetters.length}/${croatianAlphabet.length}',
                style: GoogleFonts.poppins(
                  color: Colors.greenAccent.shade200,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: croatianAlphabet.length,
          itemBuilder: (context, index) {
            final letter = croatianAlphabet[index];
            final isLearned = _learnedLetters.contains(letter.upper);
            final tileColor =
                _tileColors[index % _tileColors.length];

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlashcardScreen(
                      initialIndex: index,
                      learnedLetters: _learnedLetters,
                    ),
                  ),
                );
                _loadLearned();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isLearned ? Colors.green.shade100 : tileColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLearned
                        ? Colors.green.shade400
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            letter.upper,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                          Text(
                            letter.lower,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF3949AB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLearned)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
