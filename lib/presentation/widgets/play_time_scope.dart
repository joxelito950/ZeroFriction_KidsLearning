import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/play_time/play_time_cubit.dart';
import '../screens/rest_screen.dart';

/// Aplica el tiempo de juego diario a toda la app (HU-009). Va en
/// `MaterialApp.builder`, por encima del navegador:
/// - avisa a [PlayTimeCubit] de si la app está en primer plano (R2);
/// - con el límite alcanzado y sin tablero a medias, deja solo el menú debajo
///   y abre la pantalla de descanso (R4, R5); si entra un adulto, espera a que
///   salga;
/// - la cierra en cuanto vuelve a haber tiempo: 15 minutos más, otro límite o
///   un día nuevo (R6, R7).
class PlayTimeScope extends StatefulWidget {
  const PlayTimeScope({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<PlayTimeScope> createState() => _PlayTimeScopeState();
}

class _PlayTimeScopeState extends State<PlayTimeScope> with WidgetsBindingObserver {
  /// La pantalla de descanso abierta, o `null`. No basta con `Route.isActive`:
  /// una ruta que se está cerrando sigue activa hasta que acaba su animación.
  Route<void>? _restRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Por si el límite ya estaba alcanzado antes de que existiera el navegador.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onState(context, context.read<PlayTimeCubit>().state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    context.read<PlayTimeCubit>().setForeground(lifecycle == AppLifecycleState.resumed);
  }

  void _onState(BuildContext context, PlayTimeState state) {
    final NavigatorState? navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;
    final Route<void>? open = _restRoute;
    if (state.mustRest && open == null) {
      final route = MaterialPageRoute<void>(builder: (_) => const RestScreen());
      _restRoute = route;
      // Si se cierra por otro camino (la Zona de Padres vuelve al menú al pasar
      // a segundo plano, HU-004 R7), se vuelve a mirar si toca descansar.
      route.popped.then((_) => _onRestClosed(route));
      navigator.pushAndRemoveUntil(route, (route) => route.isFirst);
    } else if (!state.limitReached && open != null) {
      _restRoute = null;
      navigator.removeRoute(open);
    }
  }

  void _onRestClosed(Route<void> route) {
    if (!mounted || _restRoute != route) return;
    _restRoute = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onState(context, context.read<PlayTimeCubit>().state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayTimeCubit, PlayTimeState>(
      listenWhen: (previous, current) =>
          previous.mustRest != current.mustRest || previous.limitReached != current.limitReached,
      listener: _onState,
      child: widget.child,
    );
  }
}
