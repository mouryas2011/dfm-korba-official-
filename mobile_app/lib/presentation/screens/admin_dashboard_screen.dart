import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import 'admin_register_student_screen.dart';
import 'admin_course_management_screen.dart';
import 'admin_chat_moderation_screen.dart';
import 'role_selection_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      context.read<DashboardProvider>().fetchAdminDashboard(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dash = context.watch<DashboardProvider>();
    final data = dash.adminDashboardData ?? {};

    final coursesCount = data['courses_count'] ?? 8;
    final teachersCount = data['teachers_count'] ?? 12;
    final studentsCount = data['students_count'] ?? 248;
    final teamsCount = data['teams_count'] ?? 28;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('System Administrator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  SmoothPageRoute(page: const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Health Banner
              NeuCard(
                padding: const EdgeInsets.all(16),
                surfaceColor: AppColors.surfaceDarkElevated,
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.4)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0x2200D2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppColors.accentCyan, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'DFM Korba System Core',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Google Sheets Database • Drive Storage Active',
                            style: TextStyle(fontSize: 11, color: AppColors.accentTeal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Admin 4 Metrics (8 Courses, 12 Teachers, 248 Students, 28 Teams)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatTile('Courses', '$coursesCount', Icons.layers_rounded, AppColors.accentCyan),
                  _buildStatTile('Teachers', '$teachersCount', Icons.assignment_ind_rounded, const Color(0xFF8F94FB)),
                  _buildStatTile('Students', '$studentsCount', Icons.school_rounded, AppColors.accentTeal),
                  _buildStatTile('Teams', '$teamsCount', Icons.groups_rounded, AppColors.primaryOrange),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Administrative Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),

              _buildActionItem(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Register Student & WhatsApp Onboard',
                subtitle: 'Issue Student ID, temp credentials & WhatsApp invite',
                color: AppColors.accentTeal,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const AdminRegisterStudentScreen()),
                  );
                },
              ),
              _buildActionItem(
                icon: Icons.add_circle_outline_rounded,
                title: 'Manage Skill Courses',
                subtitle: 'Drone Film Making, Mobile Repair, Front Office',
                color: AppColors.accentCyan,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const AdminCourseManagementScreen()),
                  );
                },
              ),
              _buildActionItem(
                icon: Icons.security_rounded,
                title: 'Chat Moderation & Safety',
                subtitle: 'Review flagged messages, mute violations',
                color: AppColors.accentRed,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const AdminChatModerationScreen()),
                  );
                },
              ),
              _buildActionItem(
                icon: Icons.campaign_rounded,
                title: 'Publish System Notices',
                subtitle: 'General Notices & Common Task Advisories',
                color: AppColors.primaryOrange,
                onTap: () {},
              ),
              _buildActionItem(
                icon: Icons.history_rounded,
                title: 'Security & Activity Logs',
                subtitle: 'Audit trail for logins, grade edits, and moderation',
                color: AppColors.textMuted,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return NeuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Icon(icon, color: color.withOpacity(0.6), size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

