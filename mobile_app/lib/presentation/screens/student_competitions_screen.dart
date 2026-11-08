import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neumorphic_card.dart';

class StudentCompetitionsScreen extends StatefulWidget {
  const StudentCompetitionsScreen({Key? key}) : super(key: key);

  @override
  State<StudentCompetitionsScreen> createState() =>
      _StudentCompetitionsScreenState();
}

class _StudentCompetitionsScreenState extends State<StudentCompetitionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _competitions = [
    {
      'competition_id': 'CMP_2026_01',
      'title': 'Cinematic Drone Short Film 2026',
      'scope': 'Inter-Batch Grand Tournament',
      'status': 'ACTIVE',
      'start_date': '10 Nov 2026',
      'end_date': '18 Nov 2026',
      'max_marks': 500,
      'enrolled_teams': 14,
      'description':
          'Create a 3-minute cinematic story showcasing Korba nature, industrial landmarks, or river confluences. Must include 3 technical flight movements (reveal, orbit, top-down grid).',
      'rules': [
        'Video duration: 2:45 to 3:15 minutes in 4K or 1080p 60fps.',
        'Royalty-free music only with synchronized sound design.',
        'All team members must have recorded roles on submission ticket.',
        'Strict compliance with DGCA Green Zone flight ceiling (max 400 ft AGL).'
      ],
      'my_team_status': 'REGISTERED (Team Veervaan)',
    },
    {
      'competition_id': 'CMP_2026_02',
      'title': 'Precision Flight Obstacle & Waypoint Sprint',
      'scope': 'Practical Flight Mastery',
      'status': 'UPCOMING',
      'start_date': '24 Nov 2026',
      'end_date': '26 Nov 2026',
      'max_marks': 200,
      'enrolled_teams': 8,
      'description':
          'Manual throttle and yaw control challenge navigating tight tree lines and slalom gates under gusty airfield wind conditions.',
      'rules': [
        'Single battery run per team pilot.',
        'Stopwatch timing with gate penalty seconds.',
        'Failsafe RTH test mandatory before takeoff.'
      ],
      'my_team_status': 'REGISTRATION OPEN',
    },
    {
      'competition_id': 'CMP_2026_00',
      'title': 'Golden Hour Sunset Aerial Photography',
      'scope': 'Solo & Squad Visual Challenge',
      'status': 'COMPLETED',
      'start_date': '15 Oct 2026',
      'end_date': '22 Oct 2026',
      'max_marks': 300,
      'enrolled_teams': 18,
      'description':
          'RAW DNG dynamic range challenge capturing maximum cloud detail and shadow exposure at dusk.',
      'rules': ['RAW capture only.', 'No AI synthetic generation allowed.'],
      'my_team_status': 'RANK #1 (485 / 500 Pts)',
    },
  ];

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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Tournaments & Competitions'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Active & Upcoming'),
            Tab(text: 'Tournament Hall of Fame'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompetitionsList(isActiveTab: true),
          _buildHallOfFame(),
        ],
      ),
    );
  }

  Widget _buildCompetitionsList({required bool isActiveTab}) {
    final list = _competitions
        .where((c) => isActiveTab ? c['status'] != 'COMPLETED' : c['status'] == 'COMPLETED')
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final cmp = list[idx];
        final isActive = cmp['status'] == 'ACTIVE';

        return NeuCard(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          surfaceColor: AppColors.surfaceDarkElevated,
          border: Border.all(
            color: isActive ? AppColors.accentCyan : AppColors.borderSubtle,
            width: isActive ? 1.4 : 1.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryOrange.withOpacity(0.18)
                          : AppColors.surfaceDarkInset,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? AppColors.primaryOrange : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      cmp['status'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isActive ? AppColors.primaryOrange : AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    '${cmp['start_date']} – ${cmp['end_date']}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cmp['title'],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cmp['scope'],
                style: const TextStyle(fontSize: 11, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                cmp['description'],
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              // Rules box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkInset,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Official Tournament Rules:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    ...(cmp['rules'] as List<String>).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.accentCyan, fontSize: 11)),
                              Expanded(
                                child: Text(r, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Stakes', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text(
                        '${cmp['max_marks']} Marks',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.accentGold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentCyan),
                    ),
                    child: Text(
                      cmp['my_team_status'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHallOfFame() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NeuCard(
          padding: const EdgeInsets.all(18),
          surfaceColor: AppColors.surfaceDarkElevated,
          border: Border.all(color: AppColors.accentGold, width: 1.5),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.goldTrophyGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.black87, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'Golden Hour Sunset Challenge 2026',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Champion Squad: Team Veervaan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentGold),
              ),
              const SizedBox(height: 2),
              const Text(
                'Score: 485 / 500 Points • 97.0% Evaluation',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('Pilot: Aman Verma', style: TextStyle(fontSize: 10, color: AppColors.accentCyan)),
                  Text('Gimbal: Rahul Yadav', style: TextStyle(fontSize: 10, color: AppColors.accentCyan)),
                  Text('Colorist: Priya Singh', style: TextStyle(fontSize: 10, color: AppColors.accentCyan)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

