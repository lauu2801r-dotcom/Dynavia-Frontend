import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import 'activate_emergency_screen.dart';
import '../map/active_route_map_screen.dart';
import '../history/events_history_screen.dart';
import '../metrics/shift_metrics_screen.dart';
import '../profile/driver_profile_screen.dart';

class HomeAmbulanceScreen extends StatefulWidget {
  const HomeAmbulanceScreen({super.key});

  @override
  State<HomeAmbulanceScreen> createState() => _HomeAmbulanceScreenState();
}

class _HomeAmbulanceScreenState extends State<HomeAmbulanceScreen> {
  int _selectedIndex = 0;
  final bool _hasAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          _buildMapPlaceholder(),
          const ActivateEmergencyScreen(),
          const ShiftMetricsScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const ProfileAvatar(
                  name: 'Juan Pérez',
                  isOnline: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hola,',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        'Juan Pérez',
                        style: AppTypography.subtitleMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Dynavia',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.textPrimary,
                    ),
                    if (_hasAlerts)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.emergency1,
                            shape: BoxShape.circle,
                          ),
                        ),
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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildLastEvent(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergency3,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergency3.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sin emergencia activa',
                  style: AppTypography.subtitleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DynaviaButton(
            text: 'ACTIVAR EMERGENCIA',
            type: DynaviaButtonType.primary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ActiveRouteMapScreen(eventId: ''),
                ),
              );
            },
            icon: Icons.warning_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Acciones rápidas'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              icon: Icons.warning_rounded,
              title: 'Activar\nEmergencia',
              subtitle: 'Protocolo rápido',
              color: AppColors.emergency1,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ActivateEmergencyScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.map_rounded,
              title: 'Ver Ruta\nActiva',
              subtitle: 'Mapa en tiempo real',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ActiveRouteMapScreen(eventId: ''),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.analytics_rounded,
              title: 'Métricas\ndel Turno',
              subtitle: 'Estadísticas hoy',
              color: AppColors.primaryLight,
              onTap: () {
                setState(() => _selectedIndex = 3);
              },
            ),
            _buildActionCard(
              icon: Icons.history_rounded,
              title: 'Historial\nde Eventos',
              subtitle: 'Eventos anteriores',
              color: AppColors.textSecondary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EventsHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const Spacer(),
                Text(
                  title,
                  style: AppTypography.subtitleMedium.copyWith(
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Último evento'),
        const SizedBox(height: 12),
        Container(
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
              Row(
                children: [
                  const StatusBadge(level: 1, text: 'Nivel 1'),
                  const Spacer(),
                  Text(
                    'Hace 2 horas',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hospital Santa Fe ← Calle 100 #15-20',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('12:43', 'Tiempo A→B'),
                  _buildMetricItem('14', 'Vehículos notif.'),
                  _buildMetricItem('5', 'Semáforos'),
                  _buildMetricItem('Nivel 1', 'Protocolo'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.subtitleLarge.copyWith(
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_rounded,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Mapa en tiempo real',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Activa una emergencia para ver la ruta',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Inicio'),
              _buildNavItem(1, Icons.map_rounded, 'Mapa'),
              _buildEmergencyButton(),
              _buildNavItem(3, Icons.analytics_rounded, 'Métricas'),
              _buildNavItem(4, Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActivateEmergencyScreen(),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.emergency1,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.emergency1.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.warning_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
