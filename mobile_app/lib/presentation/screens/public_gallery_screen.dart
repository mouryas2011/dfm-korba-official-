import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/student_work_card.dart';

class PublicGalleryScreen extends StatefulWidget {
  const PublicGalleryScreen({Key? key}) : super(key: key);

  @override
  State<PublicGalleryScreen> createState() => _PublicGalleryScreenState();
}

class _PublicGalleryScreenState extends State<PublicGalleryScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Cinematic 4K',
    'Drone Reels',
    'Practical Challenges',
    'Color Grading',
  ];

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final gallery = (dash.publicHomeData?['gallery'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Approved Student Works'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accentCyan),
            onPressed: () => context.read<DashboardProvider>().fetchPublicHomeData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Chips
            Container(
              height: 46,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.orangeCtaGradient : null,
                        color: isSelected ? null : AppColors.surfaceDarkInset,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gallery Grid
            Expanded(
              child: gallery.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, size: 54, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No published student projects yet.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Approved practical works will appear here.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (ctx, idx) {
                        final item = gallery[idx];
                        return StudentWorkCard(
                          title: item['title'] ?? item['task_title'] ?? 'Practical Reel',
                          studentOrTeamName: item['student_or_team_name'] ?? 'Team Veervaan',
                          fileName: item['file_name'] ?? 'footage.mp4',
                          mimeType: item['mime_type'] ?? 'video/mp4',
                          marks: item['marks'],
                          feedback: item['feedback'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

