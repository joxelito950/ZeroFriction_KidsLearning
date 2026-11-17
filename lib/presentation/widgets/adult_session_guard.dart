import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/play_time/play_time_cubit.dart';

/// Mínima exposición de las pantallas de adultos (HU-004 R7, S4): vuelve al menú
/// principal tras [inactivity] sin ningún toque, o al pasar la app a segundo
/// plano o apagar la pantalla. Cada nueva entrada exige un desafío nuevo.
/// Mientras está abierta, el tiempo de juego diario no cuenta (HU-009 R2).
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
  /// Los guardianes abiertos: la Zona de Padres y la pantalla de configuración
  /// que haya encima (HU-046). Un toque en cualquiera reinicia el minuto de
  /// todos; si no, al volver de una pantalla la Zona de Padres se cerraba con
  /// el tiempo que le quedaba (visto en el moto g55 el 2026-11-16).
  static final Set<_AdultSessionGuardState> _open = {};

  Timer? _idle;
  bool _closed = false;
  PlayTimeCubit? _playTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playTime = context.read<PlayTimeCubit?>()?..enterAdultArea();
    _open.add(this);
    _restartIdle();
  }

  @override
  void dispose() {
    _open.remove(this);
    _playTime?.leaveAdultArea();
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

  static void _onActivity() {
    for (final _AdultSessionGuardState guard in _open) {
      guard._restartIdle();
    }
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
      onPointerDown: (_) => _onActivity(),
      child: widget.child,
    );
  }
}
