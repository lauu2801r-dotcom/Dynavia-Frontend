import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../metrics/shift_metrics_screen.dart';
import '../auth/user_type_selection_screen.dart';
import '../history/event_detail_screen.dart';
import '../history/events_history_screen.dart';
import '../history/models/emergency_event.dart';
import 'screens/institution_screen.dart';
import 'screens/notifications_settings_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/security_password_screen.dart';
import 'screens/vehicle_unit_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(child: _buildDashboard(context)),
          SliverToBoxAdapter(child: _buildProfileContent(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modo demo: estas pantallas usan datos de ejemplo. Se conectan al backend cuando lo tengas listo.',
                        style: AppTypography.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.emergency3,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Juan Pérez',
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: AMB-2024-001',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: AppColors.emergency3,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Verificado por Dynavia',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.emergency3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      _buildStat(label: 'Eventos', value: '4'),
                      Container(
                        width: 1,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _buildStat(label: 'Turno', value: 'Activo'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 18,
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

  Widget _buildProfileContent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(context, 'CUENTA'),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Datos personales',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.local_hospital_outlined,
            title: 'Institución asignada',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InstitutionScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.medical_services_outlined,
            title: 'Unidad vehicular',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VehicleUnitScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Estadísticas del mes',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShiftMetricsScreen()),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionLabel(context, 'SISTEMA'),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Configurar notificaciones',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsSettingsScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.security_outlined,
            title: 'Seguridad y contraseña',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SecurityPasswordScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Preferencias de Dynavia',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PreferencesScreen()),
            ),
          ),
          const SizedBox(height: 32),
          DynaviaButton(
            text: 'Cerrar sesión',
            type: DynaviaButtonType.secondary,
            onPressed: () => _confirmLogout(context),
            icon: Icons.logout_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const eventsToday = 3;
    const avgAB = '10:42';
    const bestAB = '08:35';
    const mostUsedLevel = 1;
    const avgVehicles = 14;
    const avgTrafficLights = 5;
    const avgWaitLights = '01:18';
    const avgLatency = '1.3s';
    const gpsRate = '1.0/s';

    final levelDistribution = <int, double>{1: 0.55, 2: 0.25, 3: 0.20};
    final lastEvent = EmergencyEvent(
      level: 1,
      startedAt: DateTime(2026, 5, 14, 9, 14),
      finishedAt: DateTime(2026, 5, 14, 9, 25),
      destination: 'Hospital Santa Fe',
      origin: 'Calle 100 #15-20',
      notifiedVehicles: 14,
      activatedTrafficLights: 5,
      avgVehicleReaction: const Duration(seconds: 7),
      avgTrafficLightWait: const Duration(minutes: 1, seconds: 18),
      avgLatency: const Duration(milliseconds: 1300),
      baselineWithoutSystem: const Duration(minutes: 18, seconds: 20),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Hoy'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _MetricTile(
                title: 'Eventos hoy',
                value: '$eventsToday',
                subtitle: 'Activaciones',
                icon: Icons.bolt_rounded,
                color: AppColors.primary,
              ),
              _MetricTile(
                title: 'Promedio A→B',
                value: avgAB,
                subtitle: 'Trayecto',
                icon: Icons.timer_outlined,
                color: AppColors.primaryLight,
              ),
              _MetricTile(
                title: 'Mejor A→B',
                value: bestAB,
                subtitle: 'Hoy',
                icon: Icons.emoji_events_outlined,
                color: AppColors.emergency3,
              ),
              _MetricTile(
                title: 'Nivel más usado',
                value: 'Nivel $mostUsedLevel',
                subtitle: 'Gravedad',
                icon: Icons.warning_amber_rounded,
                color: AppColors.getEmergencyColor(mostUsedLevel),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Impacto del despeje'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _MetricTile(
                title: 'Vehículos notificados',
                value: '$avgVehicles',
                subtitle: 'Promedio/evento',
                icon: Icons.directions_car_outlined,
                color: AppColors.emergency2,
              ),
              _MetricTile(
                title: 'Semáforos activados',
                value: '$avgTrafficLights',
                subtitle: 'Promedio/evento',
                icon: Icons.traffic_outlined,
                color: AppColors.primary,
              ),
              _MetricTile(
                title: 'Espera en semáforos',
                value: avgWaitLights,
                subtitle: 'Promedio',
                icon: Icons.pause_circle_outline,
                color: AppColors.emergency1,
              ),
              _MetricTile(
                title: 'Latencia promedio',
                value: avgLatency,
                subtitle: 'Objetivo < 2s',
                icon: Icons.speed_rounded,
                color: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Calidad del sistema'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: _MetricTile(title: 'Eventos hoy', value: '$eventsToday', subtitle: 'Activaciones', icon: Icons.bolt_rounded, color: AppColors.primary),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: _MetricTile(title: 'Promedio A→B', value: avgAB, subtitle: 'Trayecto', icon: Icons.timer_outlined, color: AppColors.primaryLight),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: _MetricTile(title: 'Mejor A→B', value: bestAB, subtitle: 'Hoy', icon: Icons.emoji_events_outlined, color: AppColors.emergency3),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: _MetricTile(title: 'Nivel más usado', value: 'Nivel $mostUsedLevel', subtitle: 'Gravedad', icon: Icons.warning_amber_rounded, color: AppColors.getEmergencyColor(mostUsedLevel)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Distribución por niveles'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.35),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 42,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: levelDistribution[1]!,
                          color: AppColors.emergency1,
                          showTitle: false,
                          radius: 18,
                        ),
                        PieChartSectionData(
                          value: levelDistribution[2]!,
                          color: AppColors.emergency2,
                          showTitle: false,
                          radius: 18,
                        ),
                        PieChartSectionData(
                          value: levelDistribution[3]!,
                          color: AppColors.emergency3,
                          showTitle: false,
                          radius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LevelLegendRow(
                        label: 'Nivel 1',
                        value: '55%',
                        color: AppColors.emergency1,
                      ),
                      const SizedBox(height: 10),
                      _LevelLegendRow(
                        label: 'Nivel 2',
                        value: '25%',
                        color: AppColors.emergency2,
                      ),
                      const SizedBox(height: 10),
                      _LevelLegendRow(
                        label: 'Nivel 3',
                        value: '20%',
                        color: AppColors.emergency3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Basado en eventos recientes (demo).',
                        style: AppTypography.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Último evento'),
          const SizedBox(height: 12),
          _LastEventCard(
            destination: 'Hospital Santa Fe',
            origin: 'Calle 100 #15-20',
            level: 1,
            duration: '11:20',
            vehicles: 14,
            trafficLights: 5,
            onOpenHistory: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: lastEvent),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EventsHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded, color: AppColors.primary),
              label: Text(
                'Ver historial completo',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: AppTypography.subtitleLarge.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.subtitleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen()),
        (route) => false,
      );
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelSmall.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.subtitleLarge.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelLegendRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LevelLegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LastEventCard extends StatelessWidget {
  final String destination;
  final String origin;
  final int level;
  final String duration;
  final int vehicles;
  final int trafficLights;
  final VoidCallback onOpenHistory;

  const _LastEventCard({
    required this.destination,
    required this.origin,
    required this.level,
    required this.duration,
    required this.vehicles,
    required this.trafficLights,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final levelColor = AppColors.getEmergencyColor(level);

    return Semantics(
      button: true,
      label: 'Último evento. Nivel $level. Duración $duration.',
      child: InkWell(
        onTap: onOpenHistory,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded, color: levelColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Nivel $level',
                          style: AppTypography.labelLarge.copyWith(
                            color: levelColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                destination,
                style: AppTypography.bodyLarge.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '← $origin',
                style: AppTypography.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MiniPill(icon: Icons.timer_outlined, text: duration, color: AppColors.primary),
                  const SizedBox(width: 8),
                  _MiniPill(icon: Icons.directions_car_outlined, text: '$vehicles vehículos', color: AppColors.emergency2),
                  const SizedBox(width: 8),
                  _MiniPill(icon: Icons.traffic_outlined, text: '$trafficLights semáf.', color: AppColors.primaryDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
