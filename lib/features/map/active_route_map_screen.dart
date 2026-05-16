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

  static const String _baseEmergency = 'http://10.0.2.2:3001';
  static const String _baseNotifications = 'http://10.0.2.2:3003';
  static const String _baseTraffic = 'http://10.0.2.2:3005';

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
    if (widget.eventId.isNotEmpty) _loadStats();
  }

  Future<void> _loadStats() async {
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
    } catch (_) {}
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

  Future<void> _completeDeactivation() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseEmergency/emergency/deactivate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': widget.eventId}),
      ).timeout(const Duration(seconds: 5));

      if (mounted) {
        int totalSeconds = _elapsedSeconds;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          totalSeconds = data['total_duration_seconds'] ?? _elapsedSeconds;
        }
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EventSummaryScreen(
                  eventId: widget.eventId,
                  totalSeconds: totalSeconds,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMap(),
                  _buildFloatingPill(),
                  _buildBackButton(),
                ],
              ),
            ),
            _buildBottomPanel(),
          ],
        ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_rounded, size: 80,
                    color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text('Mapa en tiempo real',
                    style: AppTypography.titleMedium
                        .copyWith(color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text('Evento: ${widget.eventId.isEmpty ? "Sin ID" : widget.eventId.substring(0, 12)}...',
                    style: AppTypography.bodySmall
                        .copyWith(color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          _buildAmbulanceMarker(),
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

  Widget _buildFloatingPill() {
    return Positioned(
      top: 16,
      left: 70, right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      top: 8, left: 16,
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emergency1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: AppColors.emergency1, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hospital destino', style: AppTypography.subtitleMedium),
                    Text(
                      widget.eventId.isEmpty ? 'Sin evento' : widget.eventId,
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildDeactivateButton(),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
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