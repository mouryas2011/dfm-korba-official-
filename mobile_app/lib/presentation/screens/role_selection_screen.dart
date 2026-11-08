import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/language_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';
import 'login_screen.dart';
import 'public_home_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'STUDENT';

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language Switcher & Public Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => lang.toggleLanguage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkInset,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded, size: 16, color: AppColors.accentCyan),
                          const SizedBox(width: 6),
                          Text(
                            lang.isHindi ? 'हिंदी' : 'English',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        SmoothPageRoute(page: const PublicHomeScreen()),
                      );
                    },
                    icon: const Icon(Icons.explore_rounded, size: 16, color: AppColors.accentCyan),
                    label: const Text(
                      'Public Feed',
                      style: TextStyle(color: AppColors.accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // App Logo & Header
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/dfm_korba_logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flight_takeoff_rounded, color: AppColors.primaryOrange, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                'DFM Korba',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentCyan,
                ),
              ),
              const SizedBox(height: 28),
              // 2x2 Grid for the 4 User Roles
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      roleKey: 'STUDENT',
                      title: 'Student',
                      subtitle: 'Learn & Practice',
                      icon: Icons.school_rounded,
                      activeColor: const Color(0xFF00C49F),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildRoleCard(
                      roleKey: 'TEACHER',
                      title: 'Teacher',
                      subtitle: 'Manage & Evaluate',
                      icon: Icons.assignment_ind_rounded,
                      activeColor: const Color(0xFF8F94FB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      roleKey: 'TEAM',
                      title: 'Team',
                      subtitle: 'Collaborate & Compete',
                      icon: Icons.groups_rounded,
                      activeColor: const Color(0xFFFFB800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildRoleCard(
                      roleKey: 'ADMIN',
                      title: 'Admin',
                      subtitle: 'Control & Monitor',
                      icon: Icons.admin_panel_settings_rounded,
                      activeColor: const Color(0xFF00D2FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // Primary CTA Login Button
              NeuButton(
                label: 'Login as $_selectedRole  →',
                onPressed: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(
                      page: LoginScreen(selectedRole: _selectedRole),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'New Student? Contact your Teacher',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedRole == roleKey;

    return NeuCard(
      onTap: () {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      surfaceColor: isSelected ? AppColors.surfaceDarkElevated : AppColors.surfaceDark,
      border: Border.all(
        color: isSelected ? activeColor : AppColors.borderSubtle,
        width: isSelected ? 1.8 : 1.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.18) : AppColors.surfaceDarkInset,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? activeColor : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

