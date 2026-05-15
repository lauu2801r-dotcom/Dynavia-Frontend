import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class VehicleUnitScreen extends StatefulWidget {
  const VehicleUnitScreen({super.key});

  @override
  State<VehicleUnitScreen> createState() => _VehicleUnitScreenState();
}

class _VehicleUnitScreenState extends State<VehicleUnitScreen> {
  bool _oxygenOk = true;
  bool _defibrillatorOk = true;
  bool _gpsOk = true;
  bool _sirensOk = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Unidad vehicular', style: AppTypography.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambulancia UMB-07',
                        style: AppTypography.subtitleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Placa: UMB-123 • Clase B',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.82),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            title: 'Modelo',
            value: 'Toyota Hiace 2023',
            icon: Icons.directions_car_filled_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: 'Capacidad',
            value: '2 paramédicos • 1 camilla',
            icon: Icons.groups_outlined,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            title: 'Identificador interno',
            value: 'AMB-BOG-NORTE-07',
            icon: Icons.qr_code_2_rounded,
          ),
          const SizedBox(height: 16),
          Text(
            'Checklist de equipo (demo)',
            style: AppTypography.subtitleLarge.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ToggleTile(
            title: 'Oxígeno',
            subtitle: 'Cilindro y manómetro',
            value: _oxygenOk,
            onChanged: (v) => setState(() => _oxygenOk = v),
          ),
          const SizedBox(height: 10),
          _ToggleTile(
            title: 'Desfibrilador',
            subtitle: 'Batería y pads',
            value: _defibrillatorOk,
            onChanged: (v) => setState(() => _defibrillatorOk = v),
          ),
          const SizedBox(height: 10),
          _ToggleTile(
            title: 'GPS',
            subtitle: 'Ubicación y red',
            value: _gpsOk,
            onChanged: (v) => setState(() => _gpsOk = v),
          ),
          const SizedBox(height: 10),
          _ToggleTile(
            title: 'Sirenas',
            subtitle: 'Luces y audio',
            value: _sirensOk,
            onChanged: (v) => setState(() => _sirensOk = v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_oxygenOk && _defibrillatorOk && _gpsOk && _sirensOk)
                  ? AppColors.emergency3.withOpacity(0.08)
                  : AppColors.emergency2.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (_oxygenOk && _defibrillatorOk && _gpsOk && _sirensOk)
                    ? AppColors.emergency3.withOpacity(0.25)
                    : AppColors.emergency2.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  (_oxygenOk && _defibrillatorOk && _gpsOk && _sirensOk)
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  color: (_oxygenOk && _defibrillatorOk && _gpsOk && _sirensOk)
                      ? AppColors.emergency3
                      : AppColors.emergency2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (_oxygenOk && _defibrillatorOk && _gpsOk && _sirensOk)
                        ? 'Todo listo para operar.'
                        : 'Revisa el equipo antes de iniciar.',
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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.title,
    required this.value,
    required this.icon,
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
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

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
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
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

