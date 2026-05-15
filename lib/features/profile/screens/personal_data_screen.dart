import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dynavia_button.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  bool _isEditing = false;

  final _nameController = TextEditingController(text: 'Juan Pérez');
  final _phoneController = TextEditingController(text: '+57 312 555 0199');
  final _emailController = TextEditingController(text: 'juan.perez@dynavia.co');
  final _licenseController = TextEditingController(text: 'C2 • 2028');
  final _bloodController = TextEditingController(text: 'O+');
  final _emergencyContactController =
      TextEditingController(text: 'María Pérez • +57 300 111 2233');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _bloodController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Datos personales', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_outlined),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Información'),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.person_outline,
            label: 'Nombre',
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.mail_outline_rounded,
            label: 'Correo',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Documentos'),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.badge_outlined,
            label: 'Licencia',
            controller: _licenseController,
          ),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.bloodtype_outlined,
            label: 'Grupo sanguíneo',
            controller: _bloodController,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Contacto de emergencia'),
          const SizedBox(height: 12),
          _buildFieldCard(
            context,
            icon: Icons.emergency_outlined,
            label: 'Contacto',
            controller: _emergencyContactController,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isEditing
                ? Column(
                    key: const ValueKey('editing'),
                    children: [
                      Semantics(
                        button: true,
                        label: 'Guardar datos personales',
                        child: DynaviaButton(
                          text: 'Guardar cambios',
                          icon: Icons.check_rounded,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _isEditing = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Cambios guardados (demo)'),
                                backgroundColor: scheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      DynaviaButton(
                        text: 'Cancelar',
                        type: DynaviaButtonType.secondary,
                        icon: Icons.close_rounded,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _isEditing = false);
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('viewing')),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conductor verificado',
                  style: AppTypography.subtitleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AMB-2024-001',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Activo',
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
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.subtitleLarge.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFieldCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
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
            child: _isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: AppTypography.bodyLarge.copyWith(
                      color: scheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      border: InputBorder.none,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.labelSmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.text,
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

