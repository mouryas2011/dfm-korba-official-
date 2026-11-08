import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _selectedBatchId = 'BTC_DFM_01';
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      context.read<AttendanceProvider>().fetchBatchRoster(
        token: token,
        batchId: _selectedBatchId,
        date: _selectedDate,
      );
    });
  }

  Future<void> _handleSave() async {
    final token = context.read<AuthProvider>().sessionToken;
    final attProv = context.read<AttendanceProvider>();

    final ok = await attProv.saveAttendance(
      token: token,
      batchId: _selectedBatchId,
      date: _selectedDate,
      courseId: 'CRS_DRONE',
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance synchronized with Google Sheet.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save attendance.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final att = context.watch<AttendanceProvider>();
    final roster = att.roster;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Mark Batch Attendance'),
        actions: [
          TextButton(
            onPressed: () => att.markAllPresent(),
            child: const Text('All Present', style: TextStyle(color: AppColors.accentTeal)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Batch & Date Selector Bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkInset,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accentCyan),
                      SizedBox(width: 8),
                      Text('Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('Batch: $_selectedBatchId', style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Student Roster List
            Expanded(
              child: att.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: roster.length,
                      itemBuilder: (ctx, idx) {
                        final item = roster[idx];
                        final isPresent = item['status'] == 'PRESENT';

                        return NeuCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.surfaceDarkInset,
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['full_name'] ?? 'Student',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    Text(
                                      'ID: ${item['student_id']}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => att.toggleStatus(idx),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? AppColors.accentTeal.withOpacity(0.18)
                                        : AppColors.accentRed.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isPresent ? AppColors.accentTeal : AppColors.accentRed,
                                    ),
                                  ),
                                  child: Text(
                                    isPresent ? 'PRESENT' : 'ABSENT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isPresent ? AppColors.accentTeal : AppColors.accentRed,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Save Attendance CTA
            Padding(
              padding: const EdgeInsets.all(16),
              child: NeuButton(
                label: 'Save & Sync Attendance to Sheet',
                isLoading: att.isLoading,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
