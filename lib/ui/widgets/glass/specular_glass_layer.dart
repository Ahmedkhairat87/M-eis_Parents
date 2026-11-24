import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SpecularGlassLayer extends StatefulWidget {
  final BorderRadiusGeometry borderRadius;
  final double blurIntensity;
  final double frostAmount;
  final double transparency;
  final double borderOpacity;
  final double highlightIntensity;
  final bool isDarkMode;
  final double? height;
  final double? width;

  // Diagnostic A/B test flag
  static const bool forceSensorsPlusFallback = false;

  const SpecularGlassLayer({
    super.key,
    required this.borderRadius,
    this.blurIntensity = 20.0,
    this.frostAmount = 0.6,
    this.transparency = 0.16,
    this.borderOpacity = 0.20,
    this.highlightIntensity = 0.15,
    required this.isDarkMode,
    this.height,
    this.width,
  });

  @override
  State<SpecularGlassLayer> createState() => _SpecularGlassLayerState();
}

class _SpecularGlassLayerState extends State<SpecularGlassLayer>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const EventChannel _rotationVectorChannel = EventChannel('com.meis.parents/rotation_vector');
  StreamSubscription? _rotationSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  late final Ticker _ticker;
  late final ValueNotifier<Offset> _motionNotifier;
  Offset _targetOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;

  // Relative Orientation Filter state
  double? _basePitch;
  double? _baseRoll;
  double _filteredX = 0.0;
  double _filteredY = 6.5; // Default holding posture gravity reference (~6.5 m/s^2)
  double _gyroBiasX = 0.0;
  double _gyroBiasY = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _motionNotifier = ValueNotifier<Offset>(Offset.zero);
    _ticker = createTicker(_onTick);
    _startSensorSubscriptions();
  }

  void _onTick(Duration elapsed) {
    final double distSq = (_currentOffset - _targetOffset).distanceSquared;
    if (distSq > 0.00001) {
      _currentOffset = Offset.lerp(_currentOffset, _targetOffset, 0.08)!;
      _motionNotifier.value = _currentOffset;
      debugPrint('[SpecularGlassSensor] Painter repaint: currentOffset=$_currentOffset');
    } else {
      if (_currentOffset != _targetOffset) {
        _currentOffset = _targetOffset;
        _motionNotifier.value = _currentOffset;
      }
      if (_ticker.isTicking) {
        _ticker.stop();
      }
    }
  }

  void _updateTargetOffset(Offset newTarget) {
    if ((newTarget - _targetOffset).distanceSquared > 0.0001) {
      _targetOffset = newTarget;
      if (!_ticker.isTicking && mounted) {
        _ticker.start();
      }
    }
  }

  void _startSensorSubscriptions() {
    _cancelSubscriptions();
    _basePitch = null;
    _baseRoll = null;

    if (SpecularGlassLayer.forceSensorsPlusFallback) {
      debugPrint('[SpecularGlassSensor] A/B Test: forceSensorsPlusFallback is true. Activating sensors_plus fallback.');
      _startSensorsPlusFallback();
      return;
    }

    Timer? watchdogTimer;

    // Priority 1: Android Native Rotation Vector EventChannel (Hardware Sensor Fusion)
    try {
      bool receivedFirstNativeEvent = false;

      // Watchdog timer: If no native event arrives within 1.5 seconds, automatically fall back to sensors_plus!
      watchdogTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!receivedFirstNativeEvent && mounted) {
          debugPrint('[SpecularGlassSensor] Native rotation vector watchdog timeout, switching to sensors_plus fallback.');
          _startSensorsPlusFallback();
        }
      });

      _rotationSubscription = _rotationVectorChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is List || event is Float64List) {
            final List<double> values = List<double>.from(event);
            if (values.length >= 2) {
              receivedFirstNativeEvent = true;
              watchdogTimer?.cancel();

              final double pitch = values[0]; // Radians
              final double roll = values[1];  // Radians

              if (_basePitch == null) {
                debugPrint('[SpecularGlassSensor] First native event received: pitch=$pitch, roll=$roll');
              }

              _basePitch ??= pitch;
              _baseRoll ??= roll;

              final double deltaRoll = roll - _baseRoll!;
              final double deltaPitch = pitch - _basePitch!;

              final double tiltX = (deltaRoll / 0.5).clamp(-1.0, 1.0);
              final double tiltY = (-deltaPitch / 0.5).clamp(-1.0, 1.0);

              final double clampedX = tiltX.abs() < 0.015 ? 0.0 : tiltX;
              final double clampedY = tiltY.abs() < 0.015 ? 0.0 : tiltY;

              final newOffset = Offset(clampedX, clampedY);
              if ((newOffset - _targetOffset).distanceSquared > 0.0001) {
                debugPrint('[SpecularGlassSensor] Native offset changed: pitch=$pitch, roll=$roll (dP=$deltaPitch, dR=$deltaRoll) -> targetOffset=$newOffset');
              }

              _updateTargetOffset(newOffset);
              return;
            }
          }
        },
        onError: (error) {
          debugPrint('[SpecularGlassSensor] Native rotation vector error ($error), switching to sensors_plus fallback.');
          watchdogTimer?.cancel();
          _startSensorsPlusFallback();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[SpecularGlassSensor] Native rotation vector exception ($e), switching to sensors_plus fallback.');
      watchdogTimer?.cancel();
      _startSensorsPlusFallback();
    }
  }

  void _startSensorsPlusFallback() {
    debugPrint('[SpecularGlassSensor] Activating sensors_plus fallback stream...');
    _rotationSubscription?.cancel();
    _rotationSubscription = null;

    // Priority 2: Accelerometer Low-Pass Gravity Filter + Gyroscope Fusion
    try {
      _accelSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          const double alpha = 0.85;
          _filteredX = alpha * _filteredX + (1 - alpha) * event.x;
          _filteredY = alpha * _filteredY + (1 - alpha) * event.y;

          _updateFallbackTargetOffset();
        },
        onError: (e) {
          debugPrint('[SpecularGlassSensor] Accelerometer stream error: $e');
          _updateTargetOffset(Offset.zero);
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[SpecularGlassSensor] Accelerometer stream exception: $e');
      _updateTargetOffset(Offset.zero);
    }

    try {
      _gyroSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          _gyroBiasX = (_gyroBiasX + event.y * 0.08).clamp(-0.3, 0.3);
          _gyroBiasY = (_gyroBiasY - event.x * 0.08).clamp(-0.3, 0.3);
          
          _gyroBiasX *= 0.92;
          _gyroBiasY *= 0.92;

          _updateFallbackTargetOffset();
        },
        onError: (e) {
          debugPrint('[SpecularGlassSensor] Gyroscope stream error: $e');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[SpecularGlassSensor] Gyroscope stream exception: $e');
    }
  }

  void _updateFallbackTargetOffset() {
    final double tiltX = ((-_filteredX / 4.5) + _gyroBiasX).clamp(-1.0, 1.0);
    final double tiltY = (((6.5 - _filteredY) / 4.5) + _gyroBiasY).clamp(-1.0, 1.0);

    final double clampedX = tiltX.abs() < 0.015 ? 0.0 : tiltX;
    final double clampedY = tiltY.abs() < 0.015 ? 0.0 : tiltY;

    final newOffset = Offset(clampedX, clampedY);
    if ((newOffset - _targetOffset).distanceSquared > 0.0001) {
      debugPrint('[SpecularGlassSensor] Fallback offset changed: accelX=$_filteredX, accelY=$_filteredY -> targetOffset=$newOffset');
    }

    _updateTargetOffset(newOffset);
  }

  void _cancelSubscriptions() {
    _rotationSubscription?.cancel();
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    _rotationSubscription = null;
    _accelSubscription = null;
    _gyroSubscription = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _cancelSubscriptions();
      if (_ticker.isTicking) _ticker.stop();
    } else if (state == AppLifecycleState.resumed) {
      _startSensorSubscriptions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSubscriptions();
    _ticker.dispose();
    _motionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sigma = (widget.blurIntensity * widget.frostAmount).clamp(10.0, 24.0);
    final BorderRadius resolvedRadius = widget.borderRadius.resolve(Directionality.of(context));

    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.30 : 0.06),
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: Stack(
          children: [
            // Layer 1: Backdrop Blur & Translucent Glass Tint
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: sigma,
                  sigmaY: sigma,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: (widget.isDarkMode 
                        ? const Color(0xFF101820) 
                        : const Color(0xFFF8FAFC)).withValues(
                      alpha: widget.isDarkMode ? 0.32 : 0.15,
                    ),
                    borderRadius: resolvedRadius,
                    border: Border.all(
                      color: (widget.isDarkMode 
                          ? Colors.white.withValues(alpha: widget.borderOpacity) 
                          : Colors.blueGrey.shade100.withValues(alpha: 0.40)),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),

            // Layer 2: Physically Responsive Multi-Layer Specular Reflection (Visual Only)
            Positioned.fill(
              child: CustomPaint(
                painter: _SpecularHighlightPainter(
                  motionNotifier: _motionNotifier,
                  isDarkMode: widget.isDarkMode,
                  highlightIntensity: widget.highlightIntensity,
                  borderRadius: resolvedRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecularHighlightPainter extends CustomPainter {
  final ValueNotifier<Offset> motionNotifier;
  final bool isDarkMode;
  final double highlightIntensity;
  final BorderRadius borderRadius;

  _SpecularHighlightPainter({
    required this.motionNotifier,
    required this.isDarkMode,
    required this.highlightIntensity,
    required this.borderRadius,
  }) : super(repaint: motionNotifier);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset motion = motionNotifier.value;
    final RRect rrect = borderRadius.toRRect(Offset.zero & size);

    canvas.save();
    canvas.clipRRect(rrect);

    final double hFactor = (highlightIntensity * 6.5).clamp(0.2, 2.0);

    // Calculate light source position: Stationary baseline resting position (0.35, 0.30) + motion shift
    final double lightX = size.width * (0.35 + motion.dx * 0.45);
    final double lightY = size.height * (0.30 + motion.dy * 0.45);

    // Layer 3: Broad Soft Reflected Ambient Light across full-width glass
    final Paint broadAmbientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (lightX / size.width) * 2 - 1,
          (lightY / size.height) * 2 - 1,
        ),
        radius: 1.2,
        colors: [
          Colors.white.withValues(alpha: ((isDarkMode ? 0.22 : 0.35) * hFactor).clamp(0.0, 0.8)),
          Colors.white.withValues(alpha: ((isDarkMode ? 0.06 : 0.12) * hFactor).clamp(0.0, 0.4)),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size)
      ..blendMode = isDarkMode ? BlendMode.screen : BlendMode.overlay;

    canvas.drawRect(Offset.zero & size, broadAmbientPaint);

    // Layer 4: Concentrated Directional / Elongated Specular Lobe
    canvas.save();
    canvas.translate(lightX, lightY);
    canvas.rotate(0.2 + motion.dx * 0.15);
    canvas.scale(1.4, 0.7);

    final Paint specularLobePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0),
        radius: size.height * 0.8,
        colors: [
          Colors.white.withValues(alpha: ((isDarkMode ? 0.42 : 0.58) * hFactor).clamp(0.0, 0.9)),
          Colors.white.withValues(alpha: ((isDarkMode ? 0.16 : 0.24) * hFactor).clamp(0.0, 0.5)),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.height * 0.8))
      ..blendMode = isDarkMode ? BlendMode.plus : BlendMode.softLight;

    canvas.drawCircle(Offset.zero, size.height * 0.8, specularLobePaint);
    canvas.restore();

    // Layer 5: Soft Diagonal Optical Sheen Band across full-width glass
    final double sheenAngle = 0.5 + motion.dx * 0.25;
    final Paint sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(cos(sheenAngle + pi), sin(sheenAngle + pi)),
        end: Alignment(cos(sheenAngle), sin(sheenAngle)),
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: ((isDarkMode ? 0.12 : 0.22) * hFactor).clamp(0.0, 0.5)),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.30, 0.50, 0.70],
      ).createShader(Offset.zero & size)
      ..blendMode = isDarkMode ? BlendMode.screen : BlendMode.overlay;

    canvas.drawRect(Offset.zero & size, sheenPaint);

    // Layer 6: Optical Glass Rim / Edge Lighting (Catches ambient light along top border)
    final double rimAngle = atan2(motion.dy - 0.5, motion.dx - 0.5);
    final Paint rimBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = LinearGradient(
        begin: Alignment(cos(rimAngle), sin(rimAngle)),
        end: Alignment(-cos(rimAngle), -sin(rimAngle)),
        colors: [
          Colors.white.withValues(alpha: ((isDarkMode ? 0.65 : 0.80) * hFactor).clamp(0.0, 1.0)),
          Colors.white.withValues(alpha: ((isDarkMode ? 0.20 : 0.35) * hFactor).clamp(0.0, 0.6)),
          Colors.white.withValues(alpha: 0.04),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(rrect, rimBorderPaint);

    // Layer 7: Material Depth Gradient (Top highlight to subtle bottom shadow)
    final Paint depthGradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: ((isDarkMode ? 0.12 : 0.18) * hFactor).clamp(0.0, 0.4)),
          Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.06),
        ],
      ).createShader(Offset.zero & size)
      ..blendMode = isDarkMode ? BlendMode.overlay : BlendMode.multiply;

    canvas.drawRect(Offset.zero & size, depthGradientPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpecularHighlightPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.highlightIntensity != highlightIntensity ||
        oldDelegate.borderRadius != borderRadius;
  }
}
