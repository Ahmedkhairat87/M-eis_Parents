import 'dart:math';
import 'package:flutter/material.dart';

class LiquidGlassController extends ChangeNotifier {
  final TickerProvider vsync;
  late AnimationController _mainController;
  
  Offset _pointerPosition = Offset.zero;
  Offset _targetPointerPosition = Offset.zero;
  double _time = 0.0;
  
  // Oscillators for organic motion
  final List<double> _phases = List.generate(5, (_) => Random().nextDouble() * pi * 2);
  final List<double> _frequencies = [1.1, 0.7, 1.3, 0.5, 0.9];
  final List<double> _amplitudes = [0.2, 0.15, 0.1, 0.25, 0.05];

  LiquidGlassController({required this.vsync}) {
    _mainController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 60),
    )..addListener(_update)
     ..repeat();
  }

  void _update() {
    _time = _mainController.value * pi * 2 * 10;
    
    // Smooth pointer tracking (simulated spring)
    _pointerPosition = Offset.lerp(_pointerPosition, _targetPointerPosition, 0.1)!;
    
    notifyListeners();
  }

  void updatePointer(Offset position, Size size) {
    // Normalize to -1 to 1
    _targetPointerPosition = Offset(
      (position.dx / size.width) * 2 - 1,
      (position.dy / size.height) * 2 - 1,
    );
  }

  double get time => _time;
  Offset get pointerPosition => _pointerPosition;

  // Get composite organic value for specific oscillator
  double getOrganicValue(int index) {
    if (index >= _phases.length) return 0.0;
    return sin(_time * _frequencies[index] + _phases[index]) * _amplitudes[index];
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }
}
