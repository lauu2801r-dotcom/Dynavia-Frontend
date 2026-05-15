import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import '../map/active_route_map_screen.dart';

class ActivateEmergencyScreen extends StatefulWidget {
  const ActivateEmergencyScreen({super.key});

  @override
  State<ActivateEmergencyScreen> createState() => _ActivateEmergencyScreenState();
}

class _ActivateEmergencyScreenState extends State<ActivateEmergencyScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  int _selectedLevel = 0;
  bool _isLoading = false;
  String? _eventId;
  String? _errorMessage;

  // 🔧 Cambia esta IP por la de tu VM Ubuntu
  static const String _baseUrl = 'http://192.168.56.101:3001';

  late AnimationController _stepController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepController, curve: Curves.easeIn),
    );
    _stepController.forward();
  }

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _stepController.reset();
      _stepController.forward();
    }
  }

  // 🔌 Llamada real a ms-emergency
  Future<void> _activateEmergency() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emergency/activate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ambulance_id': 'AMB-2024-001',
          'severity_level': _selectedLevel,
          'punto_b': {'lat': 4.7110, 'lng': -74.0721},
          'origen': {'lat': 4.6900, 'lng': -74.0550},
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _eventId = data['event_id'];
          _isLoading = false;
        });
        _nextStep();
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sin conexión con el servidor';
        _isLoading = false;
      });
    }
  }

  void _goToMap() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ActiveRouteMapScreen(eventId: _eventId ?? ''),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (_currentStep == 0) _buildOverlay(),
            _buildCurrentStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _currentStep == 0
            ? _buildIdentityConfirmation()
            : _currentStep == 1
                ? _buildLevelSelection()
                : _buildSuccessScreen(),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(color: Colors.black.withOpacity(0.7));
  }

  Widget _buildIdentityConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Confirmar activación de emergencia',
                  style: AppTypography.titleSmall, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.emergency3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emergency3.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('AMB-2024-001',
                        style: AppTypography.subtitleMedium
                            .copyWith(color: AppColors.emergency3)),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: AppColors.emergency3, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: DynaviaButton(
                      text: 'Cancelar',
                      type: DynaviaButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DynaviaButton(text: 'Confirmar', onPressed: _nextStep),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text('Selecciona el nivel de gravedad',
              style: AppTypography.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          _buildLevelCard(
            level: 1,
            title: 'NIVEL 1 — CRÍTICO',
            description: 'Sincronización total\nNotificación obligatoria',
            color: AppColors.emergency1,
            icon: Icons.warning_rounded,
          ),
          const SizedBox(height: 16),
          _buildLevelCard(
            level: 2,
            title: 'NIVEL 2 — URGENTE',
            description: 'Semáforos parciales\nAlertas activas',
            color: AppColors.emergency2,
            icon: Icons.priority_high_rounded,
          ),
          const SizedBox(height: 16),
          _buildLevelCard(
            level: 3,
            title: 'NIVEL 3 — PREVENTIVO',
            description: 'Solo alertas\nSin intervención semafórica',
            color: AppColors.emergency3,
            icon: Icons.info_rounded,
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_errorMessage!,
                  style: TextStyle(color: AppColors.emergency1),
                  textAlign: TextAlign.center),
            ),
          if (_selectedLevel > 0)
            _isLoading
                ? const CircularProgressIndicator()
                : DynaviaButton(
                    text: 'Activar Nivel $_selectedLevel',
                    onPressed: _activateEmergency,
                    icon: Icons.check_circle_outline,
                  ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required int level,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(title,
                          style: AppTypography.subtitleLarge.copyWith(
                              color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(description,
                    style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuccessAnimation(),
            const SizedBox(height: 40),
            Text('¡Dynavia activado!',
                style: AppTypography.titleLarge.copyWith(color: AppColors.emergency3)),
            const SizedBox(height: 16),
            Text(
              'Nivel $_selectedLevel • Protocolo completo iniciado\n${TimeOfDay.now().format(context)} hrs',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (_eventId != null) ...[
              const SizedBox(height: 8),
              Text(
                'ID: $_eventId',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 48),
            DynaviaButton(
              text: 'Ver trayecto en mapa',
              onPressed: _goToMap,
              icon: Icons.map_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emergency3.withOpacity(0.1),
              border: Border.all(
                color: AppColors.emergency3.withOpacity(1 - value),
                width: 4,
              ),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergency3.withOpacity(0.2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.emergency3, size: 64),
              ),
            ),
          ),
        );
      },
    );
  }
}