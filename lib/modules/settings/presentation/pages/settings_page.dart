import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../../shared/widgets/forms/custom_form_fields.dart';
import '../../../../env.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    String name = '';
    String email = '';
    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      email = authState.user.email;
    }
    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSaveProfile() {
    if (_profileFormKey.currentState!.validate()) {
      GetIt.I<SnackbarService>().showSuccess('Profile details simulated updated successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'System Settings',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure system details, admin profiles, database buckets, and themes.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 32),

            // 1. Admin Profile settings
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Profile Information',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Display Name',
                            controller: _nameController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your display name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomTextField(
                            label: 'Account Email (Read-Only)',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Save Changes',
                      onPressed: _onSaveProfile,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Supabase Integration metadata
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supabase Project Connectivity',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMetaRow(
                    context,
                    label: 'Database API URL',
                    value: Env.supabaseUrl,
                  ),
                  const Divider(height: 24),
                  _buildMetaRow(
                    context,
                    label: 'Active Buckets',
                    value: 'recipe-images, user-avatars (Storage API Public)',
                  ),
                  const Divider(height: 24),
                  _buildMetaRow(
                    context,
                    label: 'Connection Status',
                    value: 'CONNECTED (Client Active)',
                    isStatus: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Theme configuration
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Studio Customizations',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark System Theme Mode',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Toggle between Light and Dark interface modes.',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Switch(
                        value: isDark,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) {
                          GetIt.I<SnackbarService>().showWarning(
                            'Theme updates require main system config. Toggling will follow system settings.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isStatus ? Colors.green : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
