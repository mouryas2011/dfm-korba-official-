import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/floating_bubble_nav.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import 'submit_work_screen.dart';
import 'student_quiz_screen.dart';
import 'chat_screen.dart';
import 'role_selection_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      context.read<DashboardProvider>().fetchStudentDashboard(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dash = context.watch<DashboardProvider>();
    final data = dash.studentDashboardData ?? {};

    final studentName = data['full_name'] ?? auth.userName ?? 'Aman';
    final batchName = data['batch_name'] ?? 'DFM Batch 01';
    final courseName = data['course_name'] ?? 'Drone Film Making';
    final performancePct = data['performance_pct'] ?? 92.0;
    final tasks = (data['tasks'] as List<dynamic>?) ?? [];
    final activeQuizzes = (data['active_quizzes'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => dash.fetchStudentDashboard(auth.sessionToken),
                color: AppColors.primaryOrange,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Student Profile & Drone Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accentCyan, width: 1.5),
                                  color: AppColors.surfaceDarkInset,
                                ),
                                child: const Icon(Icons.person_rounded, color: AppColors.accentCyan, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $studentName',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Student • $batchName',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDarkInset,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: const Icon(
                              Icons.flight_takeoff_rounded,
                              color: AppColors.accentCyan,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // My Progress Chart Card (92% Performance)
                      NeuCard(
                        padding: const EdgeInsets.all(18),
                        surfaceColor: AppColors.surfaceDarkElevated,
                        border: Border.all(color: AppColors.accentCyan.withOpacity(0.3)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'My Progress',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTeal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.accentTeal),
                                  ),
                                  child: Text(
                                    '${performancePct.toString()}% Performance',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accentTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Stylized telemetry wave progress bar
                            Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDarkInset,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: (performancePct / 100).clamp(0.0, 1.0),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.accentCyan, AppColors.accentTeal],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cumulative: ${data['cumulative_marks'] ?? 490} pts',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('Attendance: ${data['attendance_pct'] ?? 98.5}%',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                Text('Rank: #${data['rank_in_batch'] ?? 1}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.accentGold, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2x3 Grid (My Course, My Tasks, Study Material, AI Quiz, My Team, Attendance)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.45,
                        children: [
                          _buildDashboardTile(
                            icon: Icons.flight_rounded,
                            title: 'My Course',
                            subtitle: courseName,
                            iconColor: AppColors.accentCyan,
                            onTap: () {},
                          ),
                          _buildDashboardTile(
                            icon: Icons.task_alt_rounded,
                            title: 'My Tasks',
                            subtitle: '${tasks.length} Assigned',
                            iconColor: AppColors.primaryOrange,
                            badgeCount: tasks.length,
                            onTap: () {
                              Navigator.of(context).push(
                                SmoothPageRoute(page: const SubmitWorkScreen()),
                              );
                            },
                          ),
                          _buildDashboardTile(
                            icon: Icons.menu_book_rounded,
                            title: 'Study Material',
                            subtitle: 'PDF, Video, PPT',
                            iconColor: const Color(0xFF8F94FB),
                            onTap: () {},
                          ),
                          _buildDashboardTile(
                            icon: Icons.psychology_rounded,
                            title: 'AI Quiz',
                            subtitle: '${activeQuizzes.length} Available',
                            iconColor: const Color(0xFFFFB800),
                            onTap: () {
                              Navigator.of(context).push(
                                SmoothPageRoute(page: const StudentQuizScreen()),
                              );
                            },
                          ),
                          _buildDashboardTile(
                            icon: Icons.groups_rounded,
                            title: 'My Team',
                            subtitle: data['team_name'] ?? 'Veervaan',
                            iconColor: AppColors.accentTeal,
                            onTap: () {},
                          ),
                          _buildDashboardTile(
                            icon: Icons.fact_check_rounded,
                            title: 'Attendance',
                            subtitle: '${data['attendance_pct'] ?? 98.5}% Sync',
                            iconColor: const Color(0xFF00D2FF),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Today's Task Card
                      const Text(
                        "Today's Task",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      NeuCard(
                        padding: const EdgeInsets.all(16),
                        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.4)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.videocam_rounded,
                                color: AppColors.primaryOrange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Drone Cinematic Shoot',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Due: 12 Nov • 100 Marks',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  SmoothPageRoute(page: const SubmitWorkScreen()),
                                );
                              },
                              child: const Text('Submit', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Bubble Bottom Navigation
            FloatingBubbleNav(
              currentIndex: _navIndex,
              items: const [
                NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
                NavItem(icon: Icons.menu_book_rounded, label: 'Learning'),
                NavItem(icon: Icons.task_alt_rounded, label: 'Tasks'),
                NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
                NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
              ],
              onTap: (index) {
                setState(() => _navIndex = index);
                if (index == 2) {
                  Navigator.of(context).push(SmoothPageRoute(page: const SubmitWorkScreen()));
                } else if (index == 3) {
                  Navigator.of(context).push(SmoothPageRoute(page: const ChatScreen()));
                } else if (index == 4) {
                  _showProfileSheet(auth);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return NeuCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Student Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 10),
            Text('ID: ${auth.userId ?? 'STU_DFM_001'}', style: const TextStyle(color: AppColors.accentCyan)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
              title: const Text('Logout', style: TextStyle(color: AppColors.accentRed)),
              onTap: () async {
                Navigator.of(ctx).pop();
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
      ),
    );
  }
}

