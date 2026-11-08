import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/student_leaderboard_card.dart';
import '../widgets/top_team_card.dart';

class PublicLeaderboardScreen extends StatefulWidget {
  const PublicLeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<PublicLeaderboardScreen> createState() => _PublicLeaderboardScreenState();
}

class _PublicLeaderboardScreenState extends State<PublicLeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final data = dash.publicHomeData ?? {};
    final topTeam = data['top_team'] as Map<String, dynamic>?;
    final topStudents = (data['top_students'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Performance Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.groups_rounded), text: 'Top Squads'),
            Tab(icon: Icon(Icons.person_rounded), text: 'Top Students'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Teams
          RefreshIndicator(
            onRefresh: () => context.read<DashboardProvider>().fetchPublicHomeData(),
            color: AppColors.primaryOrange,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                if (topTeam != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: const [
                        Icon(Icons.emoji_events_rounded, color: AppColors.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Reigning Champion Squad',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  TopTeamCard(
                    teamName: topTeam['team_name'] ?? 'Veervaan',
                    totalMarks: topTeam['total_team_marks'] ?? 485,
                    performancePct: (topTeam['performance_pct'] is num)
                        ? (topTeam['performance_pct'] as num).toDouble()
                        : 97.0,
                    rank: topTeam['rank'] ?? 1,
                    members: (topTeam['members'] as List<dynamic>?) ?? [],
                  ),
                  const SizedBox(height: 12),
                ],

                // Secondary Teams Podium
                _buildTeamRankTile(
                  rank: 2,
                  teamName: 'Garuda Cine Squad',
                  score: '462 / 500',
                  pct: '92.4%',
                  membersCount: 5,
                  color: AppColors.accentSilver,
                ),
                _buildTeamRankTile(
                  rank: 3,
                  teamName: 'Pawanputra Flyers',
                  score: '448 / 500',
                  pct: '89.6%',
                  membersCount: 6,
                  color: AppColors.accentBronze,
                ),
                _buildTeamRankTile(
                  rank: 4,
                  teamName: 'SkyHawks Korba',
                  score: '430 / 500',
                  pct: '86.0%',
                  membersCount: 5,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Tab 2: Students
          RefreshIndicator(
            onRefresh: () => context.read<DashboardProvider>().fetchPublicHomeData(),
            color: AppColors.primaryOrange,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.military_tech_rounded, color: AppColors.accentCyan, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Student Merit Standings',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (topStudents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Standings syncing...', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                else
                  ...List.generate(topStudents.length, (index) {
                    final s = topStudents[index];
                    return StudentLeaderboardCard(
                      rank: s['rank'] ?? (index + 1),
                      studentName: s['student_name'] ?? s['full_name'] ?? 'Student',
                      courseName: s['course_name'] ?? 'Drone Film Making',
                      teamName: s['team_name'] ?? 'Independent',
                      marks: s['marks'] ?? 450,
                      attendancePct: (s['attendance_pct'] is num)
                          ? (s['attendance_pct'] as num).toDouble()
                          : 98.0,
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRankTile({
    required int rank,
    required String teamName,
    required String score,
    required String pct,
    required int membersCount,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: NeuCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$membersCount Members • Dual Marks Registered',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  pct,
                  style: const TextStyle(fontSize: 11, color: AppColors.accentTeal, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

