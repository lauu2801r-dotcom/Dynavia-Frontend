import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _emergencyAlerts = true;
  bool _trafficLightUpdates = true;
  bool _sound = true;
  bool _vibration = true;
  bool _silentInNight = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notificaciones', style: AppTypography.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: 'Alertas Dynavia',
            children: [
              _Toggle(
                title: 'Emergencias cercanas',
                subtitle: 'Avisos cuando una ambulancia activa Dynavia',
                value: _emergencyAlerts,
                onChanged: (v) => setState(() => _emergencyAlerts = v),
              ),
              _Toggle(
                title: 'Actualizaciones de ruta',
                subtitle: 'Cambios en semáforos y ETA (demo)',
                value: _trafficLightUpdates,
                onChanged: (v) => setState(() => _trafficLightUpdates = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Sonido y vibración',
            children: [
              _Toggle(
                title: 'Sonido',
                subtitle: 'Reproduce alertas audibles',
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
              ),
              _Toggle(
                title: 'Vibración',
                subtitle: 'Vibra cuando hay alertas importantes',
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
              _Toggle(
                title: 'Silencio nocturno',
                subtitle: 'Reduce alertas entre 10:00pm y 6:00am',
                value: _silentInNight,
                onChanged: (v) => setState(() => _silentInNight = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
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
                    'Estas preferencias son locales (demo). En producción se sincronizan con el backend.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.subtitleLarge.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

