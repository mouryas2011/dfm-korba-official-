import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/notice_bar.dart';
import '../widgets/top_team_card.dart';
import '../widgets/student_leaderboard_card.dart';
import '../widgets/student_work_card.dart';
import '../widgets/neumorphic_card.dart';
import 'role_selection_screen.dart';
import 'public_gallery_screen.dart';
import 'public_leaderboard_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  int _activeNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchPublicHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final data = dash.publicHomeData ?? {};

    final notices = (data['notices'] as List<dynamic>?) ?? [];
    final topTeam = data['top_team'] as Map<String, dynamic>?;
    final topStudents = (data['top_students'] as List<dynamic>?) ?? [];
    final gallery = (data['gallery'] as List<dynamic>?) ?? [];
    final courses = (data['courses'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.accentCyan),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/dfm_korba_logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, st) =>
                      const Icon(Icons.flight_takeoff_rounded, color: AppColors.primaryOrange, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'DFM KORBA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                SmoothPageRoute(page: const RoleSelectionScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.orangeCtaGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().fetchPublicHomeData(),
        color: AppColors.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner: Learn Drone Film Making
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.droneHeaderGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Learn',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentTeal.withOpacity(0.5)),
                          ),
                          child: const Text(
                            '100% FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Drone Film Making',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hands-on Learning • Real Projects • Team Competition',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHeroTag(Icons.flight_rounded, 'DGCA Rules'),
                        const SizedBox(width: 8),
                        _buildHeroTag(Icons.camera_alt_rounded, '4K Aerial Cine'),
                        const SizedBox(width: 8),
                        _buildHeroTag(Icons.emoji_events_rounded, 'Competitions'),
                      ],
                    ),
                  ],
                ),
              ),

              // Section 2: Important Notice Bar
              if (notices.isNotEmpty)
                NoticeBar(
                  title: notices[0]['title'] ?? 'Notice',
                  category: notices[0]['category'] ?? 'GENERAL_NOTICE',
                  onTap: () => _showNoticeDetails(notices[0]),
                ),

              const SizedBox(height: 12),

              // 4 Quick Action Badges (Courses, Gallery, Top Teams, Top Students)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.layers_rounded,
                        label: 'Courses',
                        color: AppColors.accentCyan,
                        onTap: () => _showCoursesSheet(courses),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: const Color(0xFFC084FC),
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(page: const PublicGalleryScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.emoji_events_rounded,
                        label: 'Top Teams',
                        color: AppColors.accentGold,
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(page: const PublicLeaderboardScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.military_tech_rounded,
                        label: 'Top Students',
                        color: AppColors.accentTeal,
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(page: const PublicLeaderboardScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: Top Team of the Week
              if (topTeam != null)
                TopTeamCard(
                  teamName: topTeam['team_name'] ?? 'Veervaan',
                  totalMarks: topTeam['total_team_marks'] ?? 485,
                  performancePct: (topTeam['performance_pct'] is num)
                      ? (topTeam['performance_pct'] as num).toDouble()
                      : 97.0,
                  rank: topTeam['rank'] ?? 1,
                  members: (topTeam['members'] as List<dynamic>?) ?? [],
                ),

              const SizedBox(height: 18),

              // Section 4: Top 5 Students Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Top 5 Students',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Batch 01 Leaderboard',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (topStudents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Leaderboard updating...', style: TextStyle(color: AppColors.textMuted)),
                  ),
                )
              else
                ...List.generate(
                  topStudents.length > 5 ? 5 : topStudents.length,
                  (index) {
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
                  },
                ),

              const SizedBox(height: 22),

              // Section 5: Student Work Gallery
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Student Work Gallery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Approved Creative Work',
                      style: TextStyle(fontSize: 12, color: AppColors.accentCyan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: gallery.isEmpty
                    ? Center(
                        child: Text(
                          'No approved work published yet.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gallery.length,
                        itemBuilder: (ctx, idx) {
                          final item = gallery[idx];
                          return StudentWorkCard(
                            title: item['title'] ?? item['task_title'] ?? 'Practical Reel',
                            studentOrTeamName: item['student_or_team_name'] ?? 'Creator',
                            fileName: item['file_name'] ?? 'footage.mp4',
                            mimeType: item['mime_type'] ?? 'video/mp4',
                            marks: item['marks'],
                            feedback: item['feedback'],
                          );
                        },
                      ),
              ),

              const SizedBox(height: 22),

              // Section 6: Available Skill Courses
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: const Text(
                  'Available Skill Courses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...courses.map((c) => NeuCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.accentCyan, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['course_name'] ?? 'Skill Course',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${c['code'] ?? 'DFM'} • ${c['total_modules'] ?? 6} Modules • 100% Free',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkInset,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.accentCyan),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(dynamic notice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(notice['title'] ?? 'Notice', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          notice['content'] ?? '',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCoursesSheet(List<dynamic> courses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDarkElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Skill Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Skill development courses in Korba are 100% free for students.',
                style: TextStyle(fontSize: 12, color: AppColors.accentTeal),
              ),
              const SizedBox(height: 16),
              ...courses.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: AppColors.surfaceDarkInset,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const Icon(Icons.flight_takeoff_rounded, color: AppColors.accentCyan),
                      title: Text(c['course_name'] ?? 'Skill Course', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${c['code'] ?? 'DFM'} • ${c['total_modules'] ?? 6} Modules', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      trailing: const Text('FREE', style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('DFM Korba', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Skill Development Center', style: TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle),
            ListTile(
              leading: const Icon(Icons.home_rounded, color: AppColors.accentCyan),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.school_rounded, color: AppColors.accentCyan),
              title: const Text('Courses', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _showCoursesSheet(courses);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.accentCyan),
              title: const Text('Student Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  SmoothPageRoute(page: const PublicGalleryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_rounded, color: AppColors.accentCyan),
              title: const Text('Leaderboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  SmoothPageRoute(page: const PublicLeaderboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppColors.accentCyan),
              title: const Text('About DFM Korba', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0 • Strict No-Certificate Policy',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

