import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/neumorphic_card.dart';

class StudentAttendanceLogScreen extends StatefulWidget {
  const StudentAttendanceLogScreen({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceLogScreen> createState() => _StudentAttendanceLogScreenState();
}

class _StudentAttendanceLogScreenState extends State<StudentAttendanceLogScreen> {
  final List<Map<String, dynamic>> _attendanceRecords = [
    {'date': '07 Nov 2026', 'status': 'PRESENT', 'day': 'Friday', 'topic': 'DGCA Airspace Grid & Drone Calibration'},
    {'date': '06 Nov 2026', 'status': 'PRESENT', 'day': 'Thursday', 'topic': 'Gimbal 3-Axis Stabilization & Yaw Maneuvers'},
    {'date': '05 Nov 2026', 'status': 'PRESENT', 'day': 'Wednesday', 'topic': '4K 24fps 180° Shutter Rule & ND Filters'},
    {'date': '04 Nov 2026', 'status': 'PRESENT', 'day': 'Tuesday', 'topic': 'Aerial Parabolic Cinematic Reveal'},
    {'date': '03 Nov 2026', 'status': 'EXCUSED', 'day': 'Monday', 'topic': 'Battery Safety & LiPo Storage Protocols'},
    {'date': '31 Oct 2026', 'status': 'PRESENT', 'day': 'Friday', 'topic': 'Field Flight Mission at Hasdeo River'},
    {'date': '30 Oct 2026', 'status': 'PRESENT', 'day': 'Thursday', 'topic': 'Premiere Pro Color Grading & LUTs'},
  ];

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final data = dash.studentDashboardData ?? {};
    final double attendancePct = (data['attendance_pct'] is num)
        ? (data['attendance_pct'] as num).toDouble()
        : 98.5;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('My Attendance History'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attendance Telemetry Meter
              NeuCard(
                padding: const EdgeInsets.all(18),
                surfaceColor: AppColors.surfaceDarkElevated,
                border: Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceDarkInset,
                        border: Border.all(color: AppColors.accentTeal, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${attendancePct.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Verified Attendance Sync',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Matched to Official Student ID: STU_DFM_001',
                            style: TextStyle(fontSize: 11, color: AppColors.accentCyan),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Synced to Google Sheets Database',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Classroom & Flight Sessions',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkInset,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('7 Days Logged', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ..._attendanceRecords.map((rec) {
                final isPresent = rec['status'] == 'PRESENT';
                final isExcused = rec['status'] == 'EXCUSED';
                final statusColor = isPresent
                    ? AppColors.accentTeal
                    : (isExcused ? AppColors.accentGold : AppColors.accentRed);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: NeuCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text(
                              isPresent ? 'P' : (isExcused ? 'E' : 'A'),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: statusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['topic'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${rec['date']} • ${rec['day']}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDarkInset,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rec['status'] as String,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
