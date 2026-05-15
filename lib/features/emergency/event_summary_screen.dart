import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../../core/widgets/metric_card.dart';

class EventSummaryScreen extends StatefulWidget {
  final String eventId;
  final int totalSeconds;

  const EventSummaryScreen({
    super.key,
    required this.eventId,
    required this.totalSeconds,
  });

  @override
  State<EventSummaryScreen> createState() => _EventSummaryScreenState();
}

class _EventSummaryScreenState extends State<EventSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _metricsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _metricsAnimation;

  static const String _baseMetrics = 'http://10.0.2.2:3004';

  // Datos reales del evento
  int _vehiclesNotified = 0;
  int _semaphoresActivated = 0;
  double _avgLatency = 0.0;
  bool _isLoading = true;
  String? _hospitalName;
  String? _closedAt;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _metricsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _metricsAnimation = CurvedAnimation(
      parent: _metricsController,
      curve: Curves.easeOut,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _metricsController.forward();
    });

    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseMetrics/metrics/${widget.eventId}'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          _vehiclesNotified = data['vehicles_notified'] ?? 0;
          _semaphoresActivated = data['semaphores_activated'] ?? 0;
          _avgLatency = (data['avg_reaction_seconds'] ?? 0.0).toDouble();
          _hospitalName = data['hospital_name'];
          _closedAt = data['closed_at'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get formattedTime {
    final m = widget.totalSeconds ~/ 60;
    final s = widget.totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedHour {
    if (_closedAt != null) {
      try {
        final dt = DateTime.parse(_closedAt!).toLocal();
        final h = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        return '$h:$min hrs';
      } catch (_) {}
    }
    final now = TimeOfDay.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} hrs';
  }

  // Exportar métricas como JSON
  Future<void> _exportMetrics() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseMetrics/metrics/${widget.eventId}/export'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Métricas exportadas correctamente'),
            backgroundColor: AppColors.emergency3,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al exportar — revisa conexión'),
            backgroundColor: AppColors.emergency1,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _metricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetricsGrid(),
                        const SizedBox(height: 32),
                        _buildComparison(),
                        const SizedBox(height: 32),
                        _buildActions(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(opacity: _headerAnimation.value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSuccessCheck(),
                const SizedBox(height: 16),
                Text(
                  'Evento completado',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_hospitalName ?? 'Hospital destino'} • $formattedHour',
                  style: AppTypography.bodyMedium
                      .copyWith(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.eventId}',
                  style: AppTypography.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCheck() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Center(
              child: Container(
                width: 60, height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.emergency3,
                  size: 36,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid() {
    return FadeTransition(
      opacity: _metricsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_metricsAnimation),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            MetricCard(
              value: formattedTime,
              label: 'Tiempo A→B',
              icon: Icons.timer_outlined,
              iconColor: AppColors.primary,
            ),
            MetricCard(
              value: '$_vehiclesNotified',
              label: 'Vehículos notificados',
              icon: Icons.directions_car_outlined,
              iconColor: AppColors.emergency2,
            ),
            MetricCard(
              value: '$_semaphoresActivated',
              label: 'Semáforos activados',
              icon: Icons.traffic_outlined,
              iconColor: AppColors.emergency3,
            ),
            MetricCard(
              value: '${_avgLatency.toStringAsFixed(1)}s',
              label: 'Latencia promedio',
              icon: Icons.speed_outlined,
              iconColor: AppColors.primaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison() {
    // Referencia base sin sistema: 18 min = 1080 seg
    const baselineSeconds = 1080;
    final savedSeconds = baselineSeconds - widget.totalSeconds;
    final savedMin = savedSeconds ~/ 60;
    final savedSec = savedSeconds % 60;
    final dynFactor = widget.totalSeconds / baselineSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comparativa de tiempo', style: AppTypography.subtitleMedium),
          const SizedBox(height: 20),
          _buildComparisonBar(
            label: 'Con Dynavia',
            time: formattedTime,
            color: AppColors.primary,
            widthFactor: dynFactor.clamp(0.1, 1.0),
          ),
          const SizedBox(height: 12),
          _buildComparisonBar(
            label: 'Sin sistema',
            time: '18:00',
            color: AppColors.grey,
            widthFactor: 1.0,
          ),
          const SizedBox(height: 16),
          if (savedSeconds > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.emergency3.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emergency3.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_down_rounded,
                      color: AppColors.emergency3, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '-${savedMin}m ${savedSec}s más rápido',
                      style: AppTypography.subtitleMedium
                          .copyWith(color: AppColors.emergency3),
                    ),
                  ),
                  const Icon(Icons.check_circle,
                      color: AppColors.emergency3, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar({
    required String label,
    required String time,
    required Color color,
    required double widthFactor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text(time,
                style: AppTypography.subtitleMedium.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: widthFactor),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              height: 12,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _exportMetrics,
          icon: const Icon(Icons.download_rounded),
          label: const Text('Exportar métricas'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        const SizedBox(height: 12),
        DynaviaButton(
          text: 'Volver al inicio',
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: Icons.home_rounded,
        ),
      ],
    );
  }
}