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
import 'force_password_change_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedRole;

  const LoginScreen({Key? key, required this.selectedRole}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill development bootstrap credentials for seamless testing
    if (widget.selectedRole == 'ADMIN') {
      _identifierController.text = 'admin';
      _passwordController.text = 'Admin@123';
    } else if (widget.selectedRole == 'TEACHER') {
      _identifierController.text = '9876500001';
      _passwordController.text = 'Teacher@123';
    } else if (widget.selectedRole == 'TEAM') {
      _identifierController.text = 'TM_VEERVAAN';
      _passwordController.text = 'Veervaan@123';
    } else {
      _identifierController.text = '9876543210';
      _passwordController.text = 'Student@123';
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both your identifier and password.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      identifier: identifier,
      password: password,
      loginType: widget.selectedRole,
    );

    if (!mounted) return;

    if (success) {
      if (auth.isTempPassword) {
        Navigator.of(context).pushReplacement(
          SmoothPageRoute(page: const ForcePasswordChangeScreen()),
        );
        return;
      }

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
      _showErrorDialog(auth.errorMessage ?? 'Invalid credentials or login locked.');
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentRed, size: 24),
            SizedBox(width: 8),
            Text('Login Notice', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordModal() {
    final mobileCtrl = TextEditingController(text: _identifierController.text);
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Password via OTP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your registered mobile and email to receive a 6-digit verification code.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            NeuTextField(
              controller: mobileCtrl,
              hintText: 'Registered Mobile Number',
              prefixIcon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: 12),
            NeuTextField(
              controller: emailCtrl,
              hintText: 'Registered Email Address',
              prefixIcon: Icons.email_rounded,
            ),
            const SizedBox(height: 20),
            NeuButton(
              label: 'Send Verification OTP',
              onPressed: () async {
                Navigator.of(ctx).pop();
                final auth = context.read<AuthProvider>();
                final ok = await auth.requestOtpReset(
                  mobileNumber: mobileCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
                if (mounted) {
                  _showErrorDialog(ok ? 'OTP sent successfully! Check your inbox.' : (auth.errorMessage ?? 'Error'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('${widget.selectedRole} Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.4)),
                ),
                child: Text(
                  'PORTAL: ${widget.selectedRole}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryOrange,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter Credentials',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.selectedRole == 'TEAM'
                    ? 'Use your dedicated Team ID and password.'
                    : 'Use your registered mobile number and password.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              NeuTextField(
                controller: _identifierController,
                labelText: widget.selectedRole == 'TEAM' ? 'Team ID' : 'Mobile Number',
                hintText: widget.selectedRole == 'TEAM' ? 'e.g. TM_VEERVAAN' : '10-digit mobile number',
                prefixIcon: widget.selectedRole == 'TEAM' ? Icons.groups_rounded : Icons.phone_android_rounded,
              ),
              const SizedBox(height: 18),
              NeuTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordModal,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              NeuButton(
                label: 'Sign In  →',
                isLoading: auth.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Max 3 attempts before temporary account protection.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
