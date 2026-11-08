import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neumorphic_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('About DFM Korba'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Brand Emblem
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/dfm_korba_logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, st) => Container(
                            color: AppColors.surfaceDark,
                            child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primaryOrange, size: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'DFM KORBA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Drone Film Making & Skill Development Center',
                      style: TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Strict No-Certificate Policy Notice
              NeuCard(
                padding: const EdgeInsets.all(16),
                surfaceColor: const Color(0xFF1F1215),
                border: Border.all(color: AppColors.accentRed.withOpacity(0.5)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x33FF3366),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_outlined, color: AppColors.accentRed, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Strict No-Certificate Policy',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'This platform is dedicated solely to hands-on learning, practical challenges, and competitive growth. DFM Korba does NOT issue, generate, or sell any certificates.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 100% Free Learning Pledge
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.workspace_premium_rounded, color: AppColors.accentTeal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '100% Free Skill Development',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our courses in Drone Film Making, Mobile Hardware Repair, and Front Office are completely free of charge for registered students in Korba, Chhattisgarh. We focus on real-world projects, team squad collaboration, and practical industry readiness.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Aviation Compliance
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flight_rounded, color: AppColors.accentCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DGCA Drone Flight Safety & Ethics',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All flight training and aerial videography challenges adhere to DGCA Drone Rules 2021. Students operate within approved Green Zones below 400 ft (120m) AGL under certified instructor supervision.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Application Build v1.0.0 (Clean Architecture)',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Korba, Chhattisgarh • India',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
