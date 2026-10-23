import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Salida protegida (D-025, HU-001 R19–R20): el primer «atrás» del sistema solo
/// muestra un aviso pequeño, sin botones; únicamente un segundo «atrás» dentro de
/// [window] llama a [onExit]. Mientras tanto, la pantalla sigue funcionando.
class ProtectedExit extends StatefulWidget {
  const ProtectedExit({
    super.key,
    required this.onExit,
    required this.child,
    this.window = const Duration(seconds: 2),
  });

  final VoidCallback onExit;
  final Widget child;
  final Duration window;

  @override
  State<ProtectedExit> createState() => _ProtectedExitState();
}

class _ProtectedExitState extends State<ProtectedExit> {
  Timer? _window;

  bool get _armed => _window?.isActive ?? false;

  void _onBack(bool didPop, Object? result) {
    if (didPop) return;
    if (_armed) {
      _window?.cancel();
      setState(() => _window = null);
      widget.onExit();
      return;
    }
    setState(() {
      _window = Timer(widget.window, () {
        if (mounted) setState(() => _window = null);
      });
    });
  }

  @override
  void dispose() {
    _window?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: Stack(
        children: [
          widget.child,
          if (_armed)
            PositionedDirectional(
              start: 24,
              end: 24,
              bottom: 32,
              child: IgnorePointer(
                child: SafeArea(
                  child: Center(
                    child: DecoratedBox(
                      key: const ValueKey<String>('exit-repeat-hint'),
                      decoration: BoxDecoration(
                        color: const Color(0xE6334155),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Text(
                          AppLocalizations.of(context).exitRepeatHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
