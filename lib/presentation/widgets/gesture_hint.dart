import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Gesto que enseña la mano (HU-022 R1).
enum HintGesture {
  /// Tocar el objetivo (juego de memoria).
  tap,

  /// Llevar algo desde el objetivo hasta [GestureHint.dragTo] (Sombras, HU-007).
  drag,
}

/// Tutorial visual sin texto ni sonido (HU-022, D-034): si el niño no toca nada
/// en [firstDelay], una mano repite el gesto del juego sobre [target] cada
/// [repeatEvery]. Se va con un fundido al primer toque en cualquier parte de
/// [child] y no vuelve hasta el siguiente tablero ([boardId]). No captura
/// toques ni cambia el juego (R4): el toque llega a [child] como si no estuviera.
class GestureHint extends StatefulWidget {
  const GestureHint({
    super.key,
    required this.boardId,
    required this.target,
    required this.child,
    this.gesture = HintGesture.tap,
    this.dragTo,
    this.dragGhost,
    this.enabled = true,
    this.firstDelay = defaultFirstDelay,
    this.repeatEvery = defaultRepeatEvery,
  }) : assert(gesture == HintGesture.tap || dragTo != null);

  static const Duration defaultFirstDelay = Duration(seconds: 4);
  static const Duration defaultRepeatEvery = Duration(seconds: 8);

  /// Lo que dura una demostración del gesto.
  static const Duration cycle = Duration(milliseconds: 2000);

  static const Duration _fadeOut = Duration(milliseconds: 150);
  static const double handSize = 56;

  /// Cambia con cada tablero: la mano vuelve a estar disponible (R3).
  final Object boardId;

  /// El elemento que señala la mano, dentro de [child].
  final GlobalKey target;

  /// Destino del arrastre, dentro de [child]. Obligatorio con [HintGesture.drag].
  final GlobalKey? dragTo;

  /// Copia del objeto que acompaña al dedo en el arrastre, semitransparente:
  /// el objeto real no se mueve (R4).
  final Widget? dragGhost;

  final HintGesture gesture;

  /// Falso mientras no hay un tablero en juego (cargando, celebraciones, avisos).
  final bool enabled;

  final Duration firstDelay;
  final Duration repeatEvery;
  final Widget child;

  @override
  State<GestureHint> createState() => _GestureHintState();
}

class _GestureHintState extends State<GestureHint> with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(vsync: this, duration: GestureHint.cycle);
  Timer? _timer;

  /// El niño ya tocó en este tablero (R3).
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(GestureHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.boardId != oldWidget.boardId) {
      _touched = false;
      _arm();
    } else if (widget.enabled != oldWidget.enabled) {
      _arm();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cycle.dispose();
    super.dispose();
  }

  /// Programa la primera demostración, o la cancela si no toca mostrarla.
  void _arm() {
    _timer?.cancel();
    _cycle.reset();
    if (!widget.enabled || _touched) return;
    _timer = Timer(widget.firstDelay, _play);
  }

  void _play() {
    if (!mounted || !widget.enabled || _touched) return;
    _cycle.forward(from: 0);
    _timer = Timer(widget.repeatEvery, _play);
  }

  void _onPointerDown(PointerDownEvent _) {
    if (_touched) return;
    _timer?.cancel();
    setState(() => _touched = true);
  }

  /// Rectángulo de [key] en las coordenadas de este widget.
  Rect? _rectOf(GlobalKey? key) {
    final target = key?.currentContext?.findRenderObject() as RenderBox?;
    final self = context.findRenderObject() as RenderBox?;
    if (target == null || self == null || !target.attached || !target.hasSize) return null;
    final Offset topLeft = self.globalToLocal(target.localToGlobal(Offset.zero));
    return topLeft & target.size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(behavior: HitTestBehavior.translucent, onPointerDown: _onPointerDown, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: AnimatedOpacity(
                opacity: _touched ? 0 : 1,
                duration: GestureHint._fadeOut,
                child: AnimatedBuilder(
                  animation: _cycle,
                  builder: (context, _) => _buildHand(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHand(BuildContext context) {
    final double t = _cycle.value;
    if (!_cycle.isAnimating || t == 0) return const SizedBox.shrink();
    final Rect? from = _rectOf(widget.target);
    if (from == null) return const SizedBox.shrink();
    final Rect? to = widget.gesture == HintGesture.drag ? _rectOf(widget.dragTo) : null;
    final bool still = MediaQuery.disableAnimationsOf(context);

    final HandPose pose = handPoseAt(
      t,
      gesture: widget.gesture,
      from: from.center,
      to: to?.center ?? from.center,
      still: still,
    );
    final Widget? ghost = widget.dragGhost;
    return Stack(
      children: [
        if (ghost != null && widget.gesture == HintGesture.drag)
          Positioned(
            left: pose.fingertip.dx - from.width / 2,
            top: pose.fingertip.dy - from.height / 2,
            width: from.width,
            height: from.height,
            child: Opacity(
              key: const ValueKey<String>('gesture-hint-ghost'),
              opacity: 0.5 * pose.opacity,
              child: ghost,
            ),
          ),
        if (pose.ripple > 0)
          Positioned(
            left: pose.fingertip.dx - _rippleRadius(from) * pose.ripple,
            top: pose.fingertip.dy - _rippleRadius(from) * pose.ripple,
            child: Container(
              key: const ValueKey<String>('gesture-hint-ripple'),
              width: _rippleRadius(from) * 2 * pose.ripple,
              height: _rippleRadius(from) * 2 * pose.ripple,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.amber.withValues(alpha: 0.45 * (1 - pose.ripple)),
              ),
            ),
          ),
        Positioned(
          // La punta del dedo del icono está arriba y algo a la izquierda del centro.
          left: pose.fingertip.dx - GestureHint.handSize * 0.42,
          top: pose.fingertip.dy - GestureHint.handSize * 0.12,
          child: Opacity(
            opacity: pose.opacity,
            child: Transform.scale(
              scale: pose.scale,
              child: const _Hand(key: ValueKey<String>('gesture-hint-hand')),
            ),
          ),
        ),
      ],
    );
  }

  double _rippleRadius(Rect target) => math.min(target.shortestSide * 0.35, 48);
}

/// Dónde y cómo está la mano en el instante [t] (de 0 a 1) de una demostración.
final class HandPose {
  const HandPose({required this.fingertip, required this.opacity, required this.scale, required this.ripple});

  final Offset fingertip;
  final double opacity;
  final double scale;

  /// Avance del círculo del toque (0 = sin círculo).
  final double ripple;
}

/// La mano entra, hace el gesto y se va. Con [still] (movimiento reducido, R7)
/// aparece quieta sobre el objetivo y solo cambia su opacidad.
HandPose handPoseAt(
  double t, {
  required HintGesture gesture,
  required Offset from,
  required Offset to,
  bool still = false,
}) {
  double phase(double start, double end) => ((t - start) / (end - start)).clamp(0.0, 1.0);
  final double fadeIn = phase(0, 0.12);
  final double fadeOut = 1 - phase(0.85, 1);
  final double opacity = math.min(fadeIn, fadeOut);

  if (still) return HandPose(fingertip: from, opacity: opacity, scale: 1, ripple: 0);

  switch (gesture) {
    case HintGesture.tap:
      // Llega desde abajo a la derecha, presiona y suelta.
      final Offset start = from + const Offset(36, 48);
      final double approach = Curves.easeOut.transform(phase(0.12, 0.45));
      final double press = phase(0.45, 0.55) - phase(0.6, 0.7);
      return HandPose(
        fingertip: Offset.lerp(start, from, approach)!,
        opacity: opacity,
        scale: 1 - 0.15 * press,
        ripple: t >= 0.5 && t < 0.85 ? phase(0.5, 0.85) : 0,
      );
    case HintGesture.drag:
      // Presiona en el origen, lleva el dedo hasta el destino y suelta.
      final double press = phase(0.12, 0.22) - phase(0.8, 0.88);
      final double travel = Curves.easeInOut.transform(phase(0.22, 0.8));
      return HandPose(
        fingertip: Offset.lerp(from, to, travel)!,
        opacity: opacity,
        scale: 1 - 0.15 * press,
        ripple: 0,
      );
  }
}

/// La mano: icono de Material blanco con contorno teal profundo (R8, P4),
/// hasta que la identidad de HU-013 tenga la suya. Blanca para verse sobre las
/// cartas en azul petróleo (6,16:1); el contorno la separa del fondo crema.
class _Hand extends StatelessWidget {
  const _Hand({super.key});

  @override
  Widget build(BuildContext context) {
    const double outline = 2;
    return const Icon(
      Icons.touch_app,
      size: GestureHint.handSize,
      color: AppPalette.white,
      shadows: [
        Shadow(color: AppPalette.deepTeal, offset: Offset(outline, 0)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(-outline, 0)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(0, outline)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(0, -outline)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(outline, outline)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(-outline, -outline)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(outline, -outline)),
        Shadow(color: AppPalette.deepTeal, offset: Offset(-outline, outline)),
      ],
    );
  }
}
