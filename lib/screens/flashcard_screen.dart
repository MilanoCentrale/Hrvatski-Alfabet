// lib/screens/flashcard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/croatian_alphabet.dart';
import '../widgets/letter_card.dart';

class FlashcardScreen extends StatefulWidget {
  final int initialIndex;
  final Set<String> learnedLetters;

  const FlashcardScreen({
    super.key,
    required this.initialIndex,
    required this.learnedLetters,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late PageController _pageController;
  late Set<String> _learnedLetters;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _learnedLetters = Set.from(widget.learnedLetters);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleLearned(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_learnedLetters.contains(letter)) {
        _learnedLetters.remove(letter);
      } else {
        _learnedLetters.add(letter);
      }
    });
    await prefs.setStringList('learned_letters', _learnedLetters.toList());
  }

  void _goTo(int index) {
    if (index < 0 || index >= croatianAlphabet.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = croatianAlphabet.length;

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
          'Flashcards',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / $total',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_learnedLetters.length} learned',
                      style: GoogleFonts.poppins(
                        color: Colors.greenAccent.shade200,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / total,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Letter cards PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: total,
              itemBuilder: (context, index) {
                final letter = croatianAlphabet[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: LetterCard(
                    letter: letter,
                    isLearned: _learnedLetters.contains(letter.upper),
                    onToggleLearned: () => _toggleLearned(letter.upper),
                  ),
                );
              },
            ),
          ),

          // Navigation arrows
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous
                _NavButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Prev',
                  enabled: _currentIndex > 0,
                  onTap: () => _goTo(_currentIndex - 1),
                ),

                // Dot indicators (mini)
                Expanded(
                  child: Center(
                    child: _DotRow(
                      total: total,
                      current: _currentIndex,
                    ),
                  ),
                ),

                // Next
                _NavButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Next',
                  enabled: _currentIndex < total - 1,
                  onTap: () => _goTo(_currentIndex + 1),
                  iconFirst: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool iconFirst;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.iconFirst = true,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        enabled ? const Color(0xFF1565C0) : Colors.grey.shade300;
    final content = iconFirst
        ? [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)]
        : [Text(label), const SizedBox(width: 6), Icon(icon, size: 18)];

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color),
        ),
        child: Row(
          children: content
              .map((w) => w is Text
                  ? Text(
                      (w).data ?? '',
                      style: GoogleFonts.poppins(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  : w)
              .toList(),
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  final int total;
  final int current;

  const _DotRow({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    // Show at most 7 dots centered around current
    const maxDots = 7;
    int start = (current - maxDots ~/ 2).clamp(0, (total - maxDots).clamp(0, total));
    int end = (start + maxDots).clamp(0, total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1565C0)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
