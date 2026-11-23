import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/play_time/play_time_cubit.dart';

/// Una pantalla para el adulto que no es tiempo de juego (HU-047 P9): mientras
/// está abierta, el tiempo diario no cuenta y la pantalla de descanso no se
/// pone encima (HU-009 R2), como en la Zona de Padres, pero sin desafío ni
/// cierre por inactividad (P8). Sin el tiempo de juego en el árbol (algunos
/// tests), no hace nada.
class OffPlayTime extends StatefulWidget {
  const OffPlayTime({super.key, required this.child});

  final Widget child;

  @override
  State<OffPlayTime> createState() => _OffPlayTimeState();
}

class _OffPlayTimeState extends State<OffPlayTime> {
  PlayTimeCubit? _playTime;

  @override
  void initState() {
    super.initState();
    _playTime = context.read<PlayTimeCubit?>()?..enterAdultArea();
  }

  @override
  void dispose() {
    _playTime?.leaveAdultArea();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
