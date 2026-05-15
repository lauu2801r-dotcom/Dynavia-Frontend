import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../emergency/event_summary_screen.dart';

class ActiveRouteMapScreen extends StatefulWidget {
  final String eventId;
  const ActiveRouteMapScreen({super.key, required this.eventId});

  @override
  State<ActiveRouteMapScreen> createState() => _ActiveRouteMapScreenState();
}

class _ActiveRouteMapScreenState extends State<ActiveRouteMapScreen>
    with TickerProviderStateMixin {
  bool _isDeactivating = false;
  double _deactivateProgress = 0.0;
  int _elapsedSeconds = 0;
  int _vehiclesNotified = 0;
  int _semaphoresActivated = 0;
  bool _isLoadingStats = false;

  static const String _baseEmergency = 'http://192.168.56.101:3001';
  static const String _baseNotifications = 'http://192.168.56.101:3003';
  static const String _baseTraffic = 'http://192.168.56.101:3005';

  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rippleAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleController.repeat();
    _startTimer();
    _loadStats();
  }

  // Carga stats reales desde ms-notifications y ms-traffic
  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final notifRes = await http.get(
        Uri.parse('$_baseNotifications/notifications/${widget.eventId}/summary'),
      ).timeout(const Duration(seconds: 3));

      final trafficRes = await http.get(
        Uri.parse('$_baseTraffic/semaphore/${widget.eventId}'),
      ).timeout(const Duration(seconds: 3));

      if (mounted) {
        if (notifRes.statusCode == 200) {
          final data = jsonDecode(notifRes.body);
          final summary = data['summary'] as List;
          int total = 0;
          for (final item in summary) {
            total += int.tryParse(item['total'].toString()) ?? 0;
          }
          setState(() => _vehiclesNotified = total);
        }
        if (trafficRes.statusCode == 200) {
          final data = jsonDecode(trafficRes.body);
          setState(() => _semaphoresActivated = data['count'] ?? 0);
        }
      }
    } catch (_) {
      // Sin conexión, se quedan en 0
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _elapsedSeconds++);
        return true;
      }
      return false;
    });
  }

  String get formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleDeactivateStart() {
    setState(() => _isDeactivating = true);
    _animateDeactivation();
  }

  void _handleDeactivateCancel() {
    setState(() {
      _isDeactivating = false;
      _deactivateProgress = 0.0;
    });
  }

  void _animateDeactivation() async {
    const totalDuration = 2000;
    const updateInterval = 50;
    final steps = totalDuration ~/ updateInterval;
    final increment = 1.0 / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(const Duration(milliseconds: updateInterval));
      if (mounted && _isDeactivating) {
        setState(() => _deactivateProgress += increment);
      } else {
        return;
      }
    }

    if (mounted && _deactivateProgress >= 1.0) {
      await _completeDeactivation();
    }
  }

  // 🔌 Llamada real a ms-emergency para desactivar
  Future<void> _completeDeactivation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseEmergency/emergency/deactivate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': widget.eventId}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EventSummaryScreen(
                    eventId: widget.eventId,
                    totalSeconds: data['total_duration_seconds'] ?? _elapsedSeconds,
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (e) {
      // Si falla la red, navega igual con el tiempo local
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EventSummaryScreen(
                  eventId: widget.eventId,
                  totalSeconds: _elapsedSeconds,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 65,
            child: Stack(
              children: [
                _buildMap(),
                _buildFloatingPill(),
                _buildBackButton(),
              ],
            ),
          ),
          Expanded(
            flex: 35,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark.withOpacity(0.8),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 100,
                    color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('Mapa Mapbox',
                    style: AppTypography.titleMedium
                        .copyWith(color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 8),
                Text('Evento: ${widget.eventId}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          _buildAmbulanceMarker(),
          _buildDestinationMarker(),
          _buildTrafficLights(),
          _buildVehicles(),
        ],
      ),
    );
  }

  Widget _buildAmbulanceMarker() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _rippleAnimation.value,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.emergency1, size: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDestinationMarker() {
    return Positioned(
      left: 100, top: 150,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.emergency1,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.emergency1.withOpacity(0.3), blurRadius: 8)
              ],
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Colors.white, size: 20),
          ),
          Container(width: 2, height: 20, color: AppColors.emergency1),
        ],
      ),
    );
  }

  Widget _buildTrafficLights() {
    final lights = [
      {'top': 100.0, 'left': 200.0, 'status': 0},
      {'top': 200.0, 'left': 150.0, 'status': 1},
      {'top': 300.0, 'left': 220.0, 'status': 0},
      {'top': 400.0, 'left': 180.0, 'status': 2},
    ];
    return Stack(
      children: lights.map((light) {
        final status = light['status'] as int;
        final color = status == 1
            ? AppColors.emergency3
            : status == 2
                ? Colors.white
                : AppColors.emergency1;
        return Positioned(
          top: light['top'] as double,
          left: light['left'] as double,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.traffic, color: color, size: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVehicles() {
    final vehicles = [
      {'top': 80.0, 'left': 280.0},
      {'top': 180.0, 'left': 250.0},
      {'top': 350.0, 'left': 100.0},
    ];
    return Stack(
      children: vehicles.map((vehicle) {
        return Positioned(
          top: vehicle['top'] as double,
          left: vehicle['left'] as double,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.emergency2.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.emergency2.withOpacity(0.5), width: 1),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: AppColors.emergency2, size: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFloatingPill() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency1,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.emergency1.withOpacity(0.5), blurRadius: 6)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('EMERGENCIA ACTIVA',
                style: AppTypography.labelLarge.copyWith(
                    color: AppColors.emergency1, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emergency1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(formattedTime,
                  style: AppTypography.subtitleMedium
                      .copyWith(color: AppColors.emergency1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emergency1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.emergency1, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hospital destino',
                          style: AppTypography.subtitleMedium),
                      const SizedBox(height: 4),
                      Text('ID: ${widget.eventId}',
                          style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.directions_car_rounded,
                    '$_vehiclesNotified', 'vehículos\nnotificados'),
                Container(width: 1, height: 40, color: AppColors.lightGrey),
                _buildStatItem(Icons.traffic_rounded,
                    '$_semaphoresActivated', 'semáforos\nactivados'),
              ],
            ),
            const SizedBox(height: 24),
            _buildDeactivateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(value,
                style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDeactivateButton() {
    if (!_isDeactivating) {
      return DynaviaButton(
        text: 'DESACTIVAR EMERGENCIA',
        type: DynaviaButtonType.danger,
        onPressed: _handleDeactivateStart,
        icon: Icons.stop_circle_outlined,
      );
    }

    return GestureDetector(
      onLongPressEnd: (_) => _handleDeactivateCancel(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.emergency1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.emergency1, width: 2),
        ),
        child: Stack(
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 50),
              widthFactor: _deactivateProgress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.emergency1.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      value: _deactivateProgress,
                      strokeWidth: 2,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.emergency1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Mantén presionado para desactivar',
                      style: AppTypography.buttonText
                          .copyWith(color: AppColors.emergency1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// — AnimatedFractionallySizedBox (sin cambios) —
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
  });

  @override
  AnimatedFractionallySizedBoxState createState() =>
      AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactorTween = visitor(
      _widthFactorTween,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _widthFactorTween?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}