import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import 'submit_work_screen.dart';

class TeamDashboardScreen extends StatefulWidget {
  const TeamDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      context.read<DashboardProvider>().fetchTeamDashboard(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final data = dash.teamDashboardData ?? {};

    final teamName = data['team_name'] ?? 'Veervaan';
    final totalMarks = data['total_team_marks'] ?? 485;
    final performancePct = data['performance_pct'] ?? 97.0;
    final members = (data['members'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('Team : $teamName'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Squad Hero Banner with members illustration & #1 Trophy
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.2),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Member silhouettes / photo banner
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldTrophyGradient,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FFB800),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.black87,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '#1 RANKED SQUAD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentGold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Team $teamName',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Row (485 Total Marks, 97.0% Performance, 6 Members)
              Row(
                children: [
                  _buildStatCard('Total Marks', '$totalMarks', AppColors.primaryOrange),
                  const SizedBox(width: 10),
                  _buildStatCard('Performance', '${performancePct.toString()}%', AppColors.accentCyan),
                  const SizedBox(width: 10),
                  _buildStatCard('Members', '${members.length}', AppColors.accentTeal),
                ],
              ),

              const SizedBox(height: 24),

              // Navigation List Items
              _buildActionTile(
                icon: Icons.task_alt_rounded,
                title: 'Team Tasks',
                badgeText: '3',
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(
                      page: const SubmitWorkScreen(taskTitle: 'Team Task: Cinematic Short Film'),
                    ),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.assignment_ind_rounded,
                title: 'Member Contribution',
                onTap: () => _showMembersModal(members),
              ),
              _buildActionTile(
                icon: Icons.file_upload_rounded,
                title: 'Team Submissions',
                onTap: () {
                  Navigator.of(context).push(
                    SmoothPageRoute(page: const SubmitWorkScreen()),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.military_tech_rounded,
                title: 'Team Score & Ranking',
                subtitle: 'Rank #1 in DFM Batch 01',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: NeuCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badgeText,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkInset,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showMembersModal(List<dynamic> members) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Squad Member Roles & Credits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 14),
            ...members.map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceDarkInset,
                    child: Icon(Icons.person_rounded, color: AppColors.accentCyan),
                  ),
                  title: Text(m['full_name'] ?? 'Member', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(m['role_in_team'] ?? 'Crew Member', style: const TextStyle(color: AppColors.accentTeal, fontSize: 12)),
                )),
          ],
        ),
      ),
    );
  }
}
