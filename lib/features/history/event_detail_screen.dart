import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../../core/widgets/metric_card.dart';
import 'models/emergency_event.dart';

class EventDetailScreen extends StatefulWidget {
  final EmergencyEvent event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _metricsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _metricsAnimation;

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
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _metricsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _metricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricsGrid(),
                  const SizedBox(height: 20),
                  _buildComparison(context),
                  const SizedBox(height: 20),
                  _buildQualityRow(context),
                  const SizedBox(height: 28),
                  _buildActions(context, scheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = widget.event;
    final levelColor = e.levelColor;

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      tooltip: 'Volver',
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_rounded, color: levelColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Nivel ${e.level}',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Detalle del evento',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.destination,
                  style: AppTypography.subtitleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '← ${e.origin}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.78),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HeaderStat(
                          label: 'Inicio',
                          value: e.startedLabel,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _HeaderStat(
                          label: 'Fin',
                          value: e.finishedLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final e = widget.event;
    return FadeTransition(
      opacity: _metricsAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(_metricsAnimation),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            MetricCard(
              value: e.totalDurationLabel,
              label: 'Tiempo A→B',
              icon: Icons.timer_outlined,
              iconColor: AppColors.primary,
            ),
            MetricCard(
              value: '${e.notifiedVehicles}',
              label: 'Vehículos notificados',
              icon: Icons.directions_car_outlined,
              iconColor: AppColors.emergency2,
            ),
            MetricCard(
              value: '${e.activatedTrafficLights}',
              label: 'Semáforos activados',
              icon: Icons.traffic_outlined,
              iconColor: AppColors.emergency3,
            ),
            MetricCard(
              value: e.avgVehicleReactionLabel,
              label: 'Reacción vehicular',
              icon: Icons.touch_app_outlined,
              iconColor: AppColors.primaryLight,
            ),
            MetricCard(
              value: e.avgTrafficLightWaitLabel,
              label: 'Espera en semáforos',
              icon: Icons.pause_circle_outline,
              iconColor: AppColors.emergency1,
            ),
            MetricCard(
              value: e.avgLatencyLabel,
              label: 'Latencia promedio',
              icon: Icons.network_check_rounded,
              iconColor: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = widget.event;
    final baseline = e.baselineWithoutSystem;
    final withSystem = e.totalDuration;

    final maxSeconds = baseline.inSeconds == 0 ? 1 : baseline.inSeconds;
    final withFactor = (withSystem.inSeconds / maxSeconds).clamp(0.05, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparativa de tiempo (RF-12)',
            style: AppTypography.subtitleMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonBar(
            label: 'Con Dynavia',
            time: e.totalDurationLabel,
            color: AppColors.primary,
            widthFactor: withFactor,
          ),
          const SizedBox(height: 12),
          _buildComparisonBar(
            label: 'Sin sistema',
            time: e.baselineWithoutSystemLabel,
            color: scheme.onSurfaceVariant,
            widthFactor: 1.0,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.emergency3.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.emergency3.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_down_rounded,
                  color: AppColors.emergency3,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${e.savingsLabel} más rápido',
                    style: AppTypography.subtitleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.emergency3,
                  size: 18,
                ),
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
            Text(
              time,
              style: AppTypography.subtitleMedium.copyWith(color: color),
            ),
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
                color: color.withOpacity(0.18),
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

  Widget _buildQualityRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'En producción, este detalle incluye GPS 1/s (RNF-02) y latencia <2s (RNF-01) calculadas por backend.',
              style: AppTypography.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Exportación lista para conectar al backend'),
                backgroundColor: scheme.primary,
              ),
            );
          },
          icon: const Icon(Icons.download_rounded),
          label: const Text('Exportar métricas (RF-10)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        const SizedBox(height: 12),
        DynaviaButton(
          text: 'Ver historial',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icons.history_rounded,
        ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

