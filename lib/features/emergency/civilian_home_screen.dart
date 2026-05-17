import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/user_type_selection_screen.dart';

class CivilianHomeScreen extends StatefulWidget {
  const CivilianHomeScreen({super.key});

  @override
  State<CivilianHomeScreen> createState() => _CivilianHomeScreenState();
}

class _CivilianHomeScreenState extends State<CivilianHomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _baseMetrics = 'http://10.0.2.2:3004';

  bool _hasEmergencyNearby = false;
  int _emergencyLevel = 1;
  String _eventId = '';
  String _ambulanceId = '';
  bool _isLoading = true;
  Timer? _pollTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    _checkEmergency();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmergency());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkEmergency() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseMetrics/events'),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final events = List<Map<String, dynamic>>.from(data['events'] ?? []);

        // Buscar el evento activo más reciente de nivel 1 o 2
        final activeEvent = events.firstWhere(
          (e) => e['status'] == 'active' && (e['severity_level'] == 1 || e['severity_level'] == 2),
          orElse: () => {},
        );

        setState(() {
          _isLoading = false;
          if (activeEvent.isNotEmpty) {
            _hasEmergencyNearby = true;
            _emergencyLevel = activeEvent['severity_level'] ?? 1;
            _eventId = activeEvent['id'] ?? '';
            _ambulanceId = activeEvent['ambulance_id'] ?? '';
          } else {
            _hasEmergencyNearby = false;
            _eventId = '';
            _ambulanceId = '';
          }
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                _buildMap(),
                if (_hasEmergencyNearby) _buildEmergencyBanner(),
                _buildTopPill(),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildBottomCard(),
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
            AppColors.primary.withOpacity(_hasEmergencyNearby ? 0.3 : 0.1),
            AppColors.background,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasEmergencyNearby ? Icons.warning_amber_rounded : Icons.map_rounded,
              size: 80,
              color: _hasEmergencyNearby
                  ? AppColors.emergency1.withOpacity(0.7)
                  : AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _hasEmergencyNearby ? '¡Emergencia activa!' : 'Mapa conductor civil',
              style: AppTypography.titleMedium.copyWith(
                color: _hasEmergencyNearby
                    ? AppColors.emergency1.withOpacity(0.9)
                    : AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasEmergencyNearby ? 'Ambulancia en camino • $_ambulanceId' : 'Dynavia protege tu zona',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPill() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(
                    _hasEmergencyNearby ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: _hasEmergencyNearby ? AppColors.emergency1 : AppColors.emergency3,
                    size: 20,
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isLoading
                    ? 'Verificando emergencias...'
                    : _hasEmergencyNearby
                        ? 'Emergencia Nivel $_emergencyLevel • Mantente alerta'
                        : 'Sin emergencias en tu zona',
                style: AppTypography.labelLarge.copyWith(
                  color: _hasEmergencyNearby ? AppColors.emergency1 : AppColors.emergency3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                _pollTimer?.cancel();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              color: AppColors.textSecondary,
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.emergency1.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency1.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'EMERGENCIA NIVEL $_emergencyLevel • DYNAVIA',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (_hasEmergencyNearby) _buildEmergencyInstructions() else _buildSafeStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.emergency3.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emergency3.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.emergency3, size: 48),
          const SizedBox(height: 12),
          Text('Dynavia te protege',
              style: AppTypography.subtitleLarge.copyWith(color: AppColors.emergency3)),
          const SizedBox(height: 8),
          Text('Sistema activo — verificando cada 3 segundos',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmergencyInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.emergency1.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emergency1, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.emergency1, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'INSTRUCCIONES • DYNAVIA',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.emergency1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(Icons.arrow_back, 'Cede el carril derecho inmediatamente'),
          const SizedBox(height: 12),
          _buildInstructionItem(Icons.stop_circle_outlined, 'Detente 50m antes de la intersección'),
          const SizedBox(height: 12),
          _buildInstructionItem(Icons.volume_up_outlined, 'Mantén encendidas las luces de emergencia'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.emergency1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.emergency1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unidad activa', style: AppTypography.bodySmall),
                      Text(
                        _ambulanceId.isNotEmpty ? _ambulanceId : 'AMB-2024-001',
                        style: AppTypography.subtitleLarge.copyWith(color: AppColors.emergency1),
                      ),
                      Text(
                        'Evento: ${_eventId.isNotEmpty ? _eventId.substring(0, 16) : ''}...',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.emergency1.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.emergency1, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}