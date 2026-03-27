// lib/widgets/letter_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/croatian_alphabet.dart';

class LetterCard extends StatefulWidget {
  final LetterData letter;
  final bool isLearned;
  final VoidCallback onToggleLearned;

  const LetterCard({
    super.key,
    required this.letter,
    required this.isLearned,
    required this.onToggleLearned,
  });

  @override
  State<LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<LetterCard>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _ipaVisible = false;
  bool _isPlaying = false;
  late AnimationController _ipaController;
  late Animation<double> _ipaAnimation;

  // Pastel card color palette — cycles by letter index
  static const List<Color> _cardColors = [
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
  ];

  Color get _cardColor {
    final idx = widget.letter.upper.codeUnitAt(0) % _cardColors.length;
    return _cardColors[idx];
  }

  @override
  void initState() {
    super.initState();
    _ipaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _ipaAnimation = CurvedAnimation(
      parent: _ipaController,
      curve: Curves.easeInOut,
    );
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _ipaController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    try {
      await _player.play(UrlSource(widget.letter.audioUrl));
    } catch (_) {
      setState(() => _isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio not available for this letter.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleIpa() {
    setState(() {
      _ipaVisible = !_ipaVisible;
      if (_ipaVisible) {
        _ipaController.forward();
      } else {
        _ipaController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Learned badge
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: widget.onToggleLearned,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.isLearned
                        ? Colors.green.shade400
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isLearned
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: widget.isLearned ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isLearned ? 'Learned' : 'Mark learned',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              widget.isLearned ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Upper + Lower letters
            Text(
              widget.letter.upper,
              style: GoogleFonts.poppins(
                fontSize: 96,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
                height: 1.0,
              ),
            ),
            Text(
              widget.letter.lower,
              style: GoogleFonts.poppins(
                fontSize: 56,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF3949AB),
                height: 1.1,
              ),
            ),

            const SizedBox(height: 24),

            // IPA reveal
            AnimatedBuilder(
              animation: _ipaAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _ipaAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - _ipaAnimation.value)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.letter.ipa,
                        style: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            if (_ipaVisible) const SizedBox(height: 16),

            const SizedBox(height: 8),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Audio button
                _ActionButton(
                  icon: _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                  label: _isPlaying ? 'Stop' : 'Listen',
                  color: Colors.indigo.shade400,
                  onTap: _playAudio,
                ),
                const SizedBox(width: 16),
                // IPA reveal button
                _ActionButton(
                  icon: _ipaVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  label: _ipaVisible ? 'Hide IPA' : 'Show IPA',
                  color: Colors.purple.shade400,
                  onTap: _toggleIpa,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
