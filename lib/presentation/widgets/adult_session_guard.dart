import 'dart:async';

import 'package:flutter/material.dart';

/// Mínima exposición de las pantallas de adultos (HU-004 R7, S4): vuelve al menú
/// principal tras [inactivity] sin ningún toque, o al pasar la app a segundo
/// plano o apagar la pantalla. Cada nueva entrada exige un desafío nuevo.
class AdultSessionGuard extends StatefulWidget {
  const AdultSessionGuard({
    super.key,
    required this.child,
    this.inactivity = defaultInactivity,
  });

  static const Duration defaultInactivity = Duration(minutes: 1);

  final Widget child;
  final Duration inactivity;

  @override
  State<AdultSessionGuard> createState() => _AdultSessionGuardState();
}

class _AdultSessionGuardState extends State<AdultSessionGuard> with WidgetsBindingObserver {
  Timer? _idle;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restartIdle();
  }

  @override
  void dispose() {
    _idle?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// «inactive» no cuenta: también salta al bajar la barra de notificaciones.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.hidden || lifecycle == AppLifecycleState.paused) _close();
  }

  void _restartIdle() {
    _idle?.cancel();
    _idle = Timer(widget.inactivity, _close);
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    _idle?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Cualquier toque en la pantalla cuenta como actividad.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restartIdle(),
      child: widget.child,
    );
  }
}
