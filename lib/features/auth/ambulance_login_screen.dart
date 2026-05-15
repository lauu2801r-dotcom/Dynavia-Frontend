import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/dynavia_button.dart';
import 'ambulance_shift_start_screen.dart';

class AmbulanceLoginScreen extends StatefulWidget {
  const AmbulanceLoginScreen({super.key});

  @override
  State<AmbulanceLoginScreen> createState() => _AmbulanceLoginScreenState();
}

class _AmbulanceLoginScreenState extends State<AmbulanceLoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _idError;
  String? _passwordError;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    setState(() {
      _idError = null;
      _passwordError = null;
    });

    bool hasError = false;
    final id = _idController.text.trim().toUpperCase();
    final password = _passwordController.text.trim();

    if (id.isEmpty) {
      setState(() => _idError = 'Por favor ingresa tu ID institucional');
      hasError = true;
    } else if (!id.startsWith('AMB-')) {
      setState(() => _idError = 'Formato inválido. Ej: AMB-2024-001');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Por favor ingresa tu contraseña');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'La contraseña debe tener al menos 6 caracteres');
      hasError = true;
    }

    if (!hasError) {
      _performLogin(id);
    }
  }

  Future<void> _performLogin(String id) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AmbulanceShiftStartScreen(
          driverName: 'Juan Pérez',
          driverId: 'ID: $id',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dynavia',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Acceso institucional',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildAmbulanceIllustration(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido, conductor',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa con tu ID institucional y contraseña.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildIdField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      Semantics(
                        button: true,
                        label: 'Iniciar sesión como conductor de ambulancia',
                        child: DynaviaButton(
                          text: 'Iniciar sesión',
                          onPressed: _validateAndLogin,
                          isLoading: _isLoading,
                          icon: Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DynaviaButton(
                        text: 'Volver',
                        type: DynaviaButtonType.ghost,
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceIllustration() {
    return Semantics(
      label: 'Ilustración de ambulancia',
      image: true,
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.local_hospital_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            Positioned(
              bottom: 20,
              child: Icon(
                Icons.directions_car_rounded,
                size: 60,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _idController,
          decoration: InputDecoration(
            hintText: 'Ej: AMB-2024-001',
            prefixIcon: const Icon(Icons.badge_outlined),
            errorText: _idError,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
            ),
            errorText: _passwordError,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _validateAndLogin(),
        ),
      ],
    );
  }
}
