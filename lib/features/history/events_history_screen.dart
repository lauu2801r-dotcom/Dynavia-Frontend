import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_badge.dart';
import 'event_detail_screen.dart';
import 'models/emergency_event.dart';

class EventsHistoryScreen extends StatefulWidget {
  const EventsHistoryScreen({super.key});

  @override
  State<EventsHistoryScreen> createState() => _EventsHistoryScreenState();
}

class _EventsHistoryScreenState extends State<EventsHistoryScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = [
    'Todos',
    'Nivel 1',
    'Nivel 2',
    'Nivel 3',
    'Esta semana',
  ];

  final List<EmergencyEvent> _events = [
    EmergencyEvent(
      level: 1,
      startedAt: DateTime(2026, 5, 14, 9, 14),
      finishedAt: DateTime(2026, 5, 14, 9, 25),
      destination: 'Hospital Santa Fe',
      origin: 'Calle 100 #15-20',
      notifiedVehicles: 14,
      activatedTrafficLights: 5,
      avgVehicleReaction: Duration(seconds: 7),
      avgTrafficLightWait: Duration(minutes: 1, seconds: 18),
      avgLatency: Duration(milliseconds: 1300),
      baselineWithoutSystem: Duration(minutes: 18, seconds: 20),
    ),
    EmergencyEvent(
      level: 2,
      startedAt: DateTime(2026, 5, 13, 15, 42),
      finishedAt: DateTime(2026, 5, 13, 15, 50),
      destination: 'Clínica Reina Sofía',
      origin: 'Carrera 7 #45-12',
      notifiedVehicles: 9,
      activatedTrafficLights: 3,
      avgVehicleReaction: Duration(seconds: 10),
      avgTrafficLightWait: Duration(seconds: 52),
      avgLatency: Duration(milliseconds: 1600),
      baselineWithoutSystem: Duration(minutes: 12, seconds: 10),
    ),
    EmergencyEvent(
      level: 3,
      startedAt: DateTime(2026, 5, 12, 8, 20),
      finishedAt: DateTime(2026, 5, 12, 8, 25),
      destination: 'Hospital Militar Central',
      origin: 'Autopista Norte #56-30',
      notifiedVehicles: 4,
      activatedTrafficLights: 1,
      avgVehicleReaction: Duration(seconds: 14),
      avgTrafficLightWait: Duration(seconds: 20),
      avgLatency: Duration(milliseconds: 1700),
      baselineWithoutSystem: Duration(minutes: 7, seconds: 5),
    ),
    EmergencyEvent(
      level: 1,
      startedAt: DateTime(2026, 5, 11, 18, 55),
      finishedAt: DateTime(2026, 5, 11, 19, 9),
      destination: 'Fundación Cardioinfantil',
      origin: 'Calle 163 #20-45',
      notifiedVehicles: 22,
      activatedTrafficLights: 8,
      avgVehicleReaction: Duration(seconds: 6),
      avgTrafficLightWait: Duration(minutes: 1, seconds: 42),
      avgLatency: Duration(milliseconds: 1100),
      baselineWithoutSystem: Duration(minutes: 21, seconds: 5),
    ),
  ];

  List<EmergencyEvent> get _visibleEvents {
    switch (_selectedFilter) {
      case 'Nivel 1':
        return _events.where((e) => e.level == 1).toList();
      case 'Nivel 2':
        return _events.where((e) => e.level == 2).toList();
      case 'Nivel 3':
        return _events.where((e) => e.level == 3).toList();
      case 'Esta semana':
        final now = DateTime.now();
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - DateTime.monday));
        return _events
            .where((e) => !e.startedAt.isBefore(startOfWeek))
            .toList();
      default:
        return _events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Historial • Dynavia', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _visibleEvents.isEmpty
                ? _buildEmptyState()
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : scheme.outlineVariant,
                ),
              ),
              child: Text(
                filter,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    final data = _visibleEvents;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final event = data[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EmergencyEvent event) {
    final scheme = Theme.of(context).colorScheme;
    final level = event.level;
    final emergencyColor = event.levelColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: emergencyColor, width: 4)),
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
          onTap: () => _openEventDetails(event),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(level: level, text: ''),
                    const Spacer(),
                    Text(event.startedLabel, style: AppTypography.labelSmall),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: emergencyColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.destination,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            '← ${event.origin}',
                            style: AppTypography.bodySmall.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
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
                    _buildMetricChip(
                      Icons.timer_outlined,
                      event.totalDurationLabel,
                    ),
                    _buildMetricChip(
                      Icons.directions_car_outlined,
                      '${event.notifiedVehicles} vehículos',
                    ),
                    _buildMetricChip(
                      Icons.traffic_outlined,
                      '${event.activatedTrafficLights} semáf.',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalle',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(color: scheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin eventos registrados en Dynavia',
            style: AppTypography.titleMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los eventos aparecerán aquí cuando ocurran',
            style: AppTypography.bodySmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _openEventDetails(EmergencyEvent event) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)));
  }
}
