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
  late AudioPlayer _player;
  bool _ipaVisible = false;
  bool _isPlaying = false;
  late AnimationController _ipaController;
  late Animation<double> _ipaAnimation;

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
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
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
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _ipaController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await _player.stop();
        return;
      }
      await _player.stop();
      await _player.play(AssetSource(widget.letter.audioAsset));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio nije dostupan / Audio not available: $e'),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.38;
    final letterSpacing = screenHeight * 0.00;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: _cardColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              // Learned badge
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: widget.onToggleLearned,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
                          color: widget.isLearned
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isLearned
                              ? 'Naučeno / Learned'
                              : 'Označi / Mark',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: widget.isLearned
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Large image (3x original size)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.letter.imageUrl,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          widget.letter.emoji,
                          style: TextStyle(fontSize: imageHeight * 0.4),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              // Word label
              Text(
                '${widget.letter.wordHr} / ${widget.letter.wordEn}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade700,
                ),
              ),

              // Spacer pushing letter down ~20% of screen
              SizedBox(height: letterSpacing),

              // Large uppercase letter
              Text(
                widget.letter.upper,
                style: GoogleFonts.poppins(
                  fontSize: 192,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                  height: 1.0,
                ),
              ),

              // Lowercase letter
              Text(
                widget.letter.lower,
                style: GoogleFonts.poppins(
                  fontSize: 112,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF3949AB),
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 8),

              // IPA reveal (animated)
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

              const SizedBox(height: 8),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: _isPlaying
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                    label: _isPlaying
                        ? 'Stani / Stop'
                        : 'Slušaj / Listen',
                    color: Colors.indigo.shade400,
                    onTap: _playAudio,
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: _ipaVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    label: _ipaVisible
                        ? 'Sakrij / Hide'
                        : 'Pokaži / Show',
                    color: Colors.purple.shade400,
                    onTap: _toggleIpa,
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
