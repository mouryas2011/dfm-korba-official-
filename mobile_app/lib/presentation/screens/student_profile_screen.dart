import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_text_field.dart';
import 'role_selection_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeuTextField(
                controller: oldPassCtrl,
                label: 'Current Password',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 12),
              NeuTextField(
                controller: newPassCtrl,
                label: 'New Password',
                obscureText: true,
                prefixIcon: Icons.lock_rounded,
              ),
              const SizedBox(height: 12),
              NeuTextField(
                controller: confirmPassCtrl,
                label: 'Confirm New Password',
                obscureText: true,
                prefixIcon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (newPassCtrl.text.length >= 8 && newPassCtrl.text == confirmPassCtrl.text) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password updated successfully.'),
                    backgroundColor: AppColors.accentTeal,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords must match and be at least 8 characters.'),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            child: const Text('Save Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Are you sure you want to end your current session?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  SmoothPageRoute(page: const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final isHindi = lang.locale.languageCode == 'hi';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              NeuCard(
                padding: const EdgeInsets.all(20),
                surfaceColor: AppColors.surfaceDarkElevated,
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.3)),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceDarkInset,
                        border: Border.all(color: AppColors.accentCyan, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, size: 36, color: AppColors.accentCyan),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.userName ?? 'Aman Verma',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Student ID: STU_DFM_001',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentTeal),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Course: Drone Film Making • Batch 01',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Enrolled Squad Info
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_rounded, color: AppColors.primaryOrange, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Team Veervaan (#1 Ranked Squad)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 2),
                          Text('Squad Leader • 6 Squad Members', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Application Preferences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),

              // Language Selector Tile
              NeuCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.translate_rounded, color: AppColors.accentCyan, size: 20),
                        SizedBox(width: 12),
                        Text('Language / भाषा', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => lang.setLanguage('en'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: !isHindi ? AppColors.accentCyan : AppColors.surfaceDarkInset,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'English',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: !isHindi ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => lang.setLanguage('hi'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isHindi ? AppColors.accentCyan : AppColors.surfaceDarkInset,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'हिन्दी',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isHindi ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Change Password Tile
              NeuCard(
                onTap: _showChangePasswordDialog,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.lock_reset_rounded, color: AppColors.accentTeal, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Change Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Strict No-Certificate Disclaimer
              NeuCard(
                padding: const EdgeInsets.all(14),
                surfaceColor: const Color(0xFF1A1215),
                border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppColors.accentRed, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DFM Korba is a 100% free practical learning system. We strictly do not issue or sell certificates.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              NeuButton(
                text: 'Logout from App',
                onPressed: () => _showLogoutDialog(context, auth),
                color: const Color(0xFF2D151B),
                textColor: AppColors.accentRed,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

