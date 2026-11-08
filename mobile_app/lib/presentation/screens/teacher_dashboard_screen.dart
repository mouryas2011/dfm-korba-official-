import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_daily_review_screen.dart';
import 'teacher_ai_quiz_screen.dart';
import 'role_selection_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      context.read<DashboardProvider>().fetchTeacherDashboard(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dash = context.watch<DashboardProvider>();
    final data = dash.teacherDashboardData ?? {};

    final teacherName = data['full_name'] ?? auth.userName ?? 'Vikram Sharma';
    final batchesCount = data['batches_count'] ?? 4;
    final studentsCount = data['students_count'] ?? 68;
    final tasksCount = data['tasks_count'] ?? 12;
    final competitionsCount = data['competitions_count'] ?? 6;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Teacher Command Center'),
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
              // Teacher Profile Banner
              NeuCard(
                padding: const EdgeInsets.all(16),
                surfaceColor: AppColors.surfaceDarkElevated,
                border: Border.all(color: AppColors.accentPurple.withOpacity(0.5)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.teacherPurpleGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Head Flight Instructor • Drone Film Making',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Overview Metrics Grid (4 Batches, 68 Students, 12 Tasks, 6 Competitions)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard('Batches', '$batchesCount', Icons.folder_shared_rounded, AppColors.accentCyan),
                  _buildMetricCard('Students', '$studentsCount', Icons.people_alt_rounded, AppColors.accentTeal),
                  _buildMetricCard('Tasks', '$tasksCount', Icons.assignment_rounded, AppColors.primaryOrange),
                  _buildMetricCard('Competitions', '$competitionsCount', Icons.emoji_events_rounded, AppColors.accentGold),
                ],
              ),

              const SizedBox(height: 24),

              // Operational Tools Section
              const Text(
                'Faculty Operations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),

              _buildOperationTile(
                icon: Icons.how_to_reg_rounded,
                title: 'Mark Batch Attendance',
                subtitle: 'Sync with project attendance Google Sheet',
                color: AppColors.accentTeal,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const TeacherAttendanceScreen()),
                  );
                },
              ),
              _buildOperationTile(
                icon: Icons.rate_review_rounded,
                title: 'Daily Company Review',
                subtitle: 'Submit mandatory 8-field operational log',
                color: AppColors.primaryOrange,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const TeacherDailyReviewScreen()),
                  );
                },
              ),
              _buildOperationTile(
                icon: Icons.auto_awesome_rounded,
                title: 'AI Quiz Generator (Gemini)',
                subtitle: 'Generate and approve fortnightly evaluations',
                color: AppColors.accentCyan,
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const TeacherAiQuizScreen()),
                  );
                },
              ),
              _buildOperationTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Submissions Review Queue',
                subtitle: 'Award individual & team marks',
                color: const Color(0xFF8F94FB),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All current submissions evaluated.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return NeuCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
              ),
              Icon(icon, color: color.withOpacity(0.7), size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOperationTile({
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
