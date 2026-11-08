import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../widgets/neumorphic_text_field.dart';
import '../widgets/neumorphic_button.dart';
import 'student_dashboard_screen.dart';
import 'team_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class ForcePasswordChangeScreen extends StatefulWidget {
  const ForcePasswordChangeScreen({Key? key}) : super(key: key);

  @override
  State<ForcePasswordChangeScreen> createState() => _ForcePasswordChangeScreenState();
}

class _ForcePasswordChangeScreenState extends State<ForcePasswordChangeScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordUpdate() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.length < 8) {
      _showSnack('New password must be at least 8 characters long.');
      return;
    }

    if (newPass != confirmPass) {
      _showSnack('New password and confirmation do not match.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    if (!mounted) return;

    if (success) {
      _showSnack('Password updated successfully! Welcome aboard.');
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      switch (auth.userRole) {
        case 'STUDENT':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const StudentDashboardScreen()),
          );
          break;
        case 'TEAM':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const TeamDashboardScreen()),
          );
          break;
        case 'TEACHER':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const TeacherDashboardScreen()),
          );
          break;
        case 'ADMIN':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const AdminDashboardScreen()),
          );
          break;
      }
    } else {
      _showSnack(auth.errorMessage ?? 'Failed to update password.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surfaceDarkElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.accentRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Security Requirement',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentRed,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update Temporary Password',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are logging in with a temporary password. To safeguard your student records, please set a strong personal password before proceeding.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              NeuTextField(
                controller: _oldPasswordController,
                labelText: 'Current Temporary Password',
                hintText: 'Enter current temporary password',
                prefixIcon: Icons.lock_open_rounded,
                obscureText: _obscure,
              ),
              const SizedBox(height: 16),
              NeuTextField(
                controller: _newPasswordController,
                labelText: 'New Strong Password',
                hintText: 'Minimum 8 characters (letters + numbers)',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscure,
              ),
              const SizedBox(height: 16),
              NeuTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                hintText: 'Re-enter your new password',
                prefixIcon: Icons.check_circle_outline_rounded,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 32),
              NeuButton(
                label: 'Save Password & Enter App  →',
                isLoading: auth.isLoading,
                onPressed: _handlePasswordUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
