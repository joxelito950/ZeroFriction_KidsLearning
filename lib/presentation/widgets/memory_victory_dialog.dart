import 'package:flutter/material.dart';

class MemoryVictoryDialog extends StatelessWidget {
  const MemoryVictoryDialog({
    super.key,
    required this.moves,
  });

  final int moves;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey<String>('memory-victory-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF3C4)],
          ),
          border: Border.all(color: const Color(0xFFF6C453), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFFFC107),
              child: Icon(Icons.emoji_events_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Lo lograste!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encontraste todas las parejas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _AnimatedStar(index: index),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Completado en $moves movimientos',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFB7185),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text(
                'Volver al menú',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  const _AnimatedStar({required this.index});

  final int index;

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Curve curve = [Curves.easeInOut, Curves.easeInOutCubic, Curves.easeInOutBack][widget.index % 3];
    final double beginScale = [0.9, 0.82, 0.88][widget.index % 3];

    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = animation.value;
        final double scale = beginScale + (1 - beginScale) * t;
        final double dy = (1 - t) * 6;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.star_rounded,
        key: ValueKey<String>('memory-victory-star-${widget.index}'),
        color: const Color(0xFFFFC107),
        size: 56,
      ),
    );
  }
}
