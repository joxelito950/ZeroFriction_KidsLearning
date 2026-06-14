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
              '¡Ganaste!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Encontraste todas las parejas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star_rounded, key: ValueKey<String>('memory-victory-star-$index'), color: Color(0xFFFFC107), size: 34),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Completado en $moves movimientos',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Seguir jugando'),
            ),
          ],
        ),
      ),
    );
  }
}
