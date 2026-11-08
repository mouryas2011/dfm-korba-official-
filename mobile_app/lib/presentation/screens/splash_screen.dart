import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/drone_loading_indicator.dart';
import '../../core/animations/page_transitions.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'role_selection_screen.dart';
import 'student_dashboard_screen.dart';
import 'team_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'force_password_change_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Pre-fetch public home data
    context.read<DashboardProvider>().fetchPublicHomeData();

    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated) {
      if (auth.isTempPassword) {
        Navigator.of(context).pushReplacement(
          SmoothPageRoute(page: const ForcePasswordChangeScreen()),
        );
        return;
      }

      switch (auth.userRole) {
        case 'STUDENT':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const StudentDashboardScreen()),
          );
          break;
        case 'TEAM':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const TeamDashboardScreen()),
          );
          break;
        case 'TEACHER':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const TeacherDashboardScreen()),
          );
          break;
        case 'ADMIN':
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const AdminDashboardScreen()),
          );
          break;
        default:
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const RoleSelectionScreen()),
          );
      }
    } else {
      Navigator.of(context).pushReplacement(
        SmoothPageRoute(page: const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background Gradient with ambient aviation blue
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF080D1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // DFM Korba Official Logo Badge
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/dfm_korba_logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceDark,
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            size: 60,
                            color: AppColors.accentCyan,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DFM KORBA',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Drone Film Making Korba',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Skill Development Learning & Competition Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const DroneLoadingIndicator(
                  size: 54,
                  message: 'Loading secure environment...',
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'Learn > Practice > Create > Compete > Share > Grow',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
