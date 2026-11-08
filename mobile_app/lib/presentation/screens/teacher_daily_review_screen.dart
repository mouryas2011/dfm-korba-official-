import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/neumorphic_text_field.dart';
import '../widgets/neumorphic_button.dart';

class TeacherDailyReviewScreen extends StatefulWidget {
  const TeacherDailyReviewScreen({Key? key}) : super(key: key);

  @override
  State<TeacherDailyReviewScreen> createState() => _TeacherDailyReviewScreenState();
}

class _TeacherDailyReviewScreenState extends State<TeacherDailyReviewScreen> {
  final _activitiesController = TextEditingController(
    text: 'Conducted waypoint navigation and return-to-home fail-safe drilling under gusty wind conditions.',
  );
  final _studentProgressController = TextEditingController(
    text: 'All 18 attending students passed pre-flight motor check and gimbal stabilization routines.',
  );
  final _challengesController = TextEditingController(
    text: 'High wind velocity (20 km/h) restricted flight duration to 15-minute bursts.',
  );
  final _workCompletedController = TextEditingController(
    text: 'Recorded 4K sunset reveal shots and archived unedited reels to Drive.',
  );
  final _remarksController = TextEditingController(
    text: 'Satisfactory flight discipline; Team Veervaan demonstrated excellent crew synchronization.',
  );

  @override
  void dispose() {
    _activitiesController.dispose();
    _studentProgressController.dispose();
    _challengesController.dispose();
    _workCompletedController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final token = context.read<AuthProvider>().sessionToken;
    final attProv = context.read<AttendanceProvider>();

    final ok = await attProv.submitDailyReview(
      token: token,
      date: DateTime.now().toIso8601String().split('T')[0],
      courseId: 'CRS_DRONE',
      batchId: 'BTC_DFM_01',
      activitiesCompleted: _activitiesController.text.trim(),
      studentProgress: _studentProgressController.text.trim(),
      challengesFaced: _challengesController.text.trim(),
      workCompleted: _workCompletedController.text.trim(),
      overallRemarks: _remarksController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily Company Review submitted successfully.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attProv = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Daily Company Review'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'End-of-Day Operational Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Directly logged into project owner’s Daily Review Google Sheet.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              NeuTextField(
                controller: _activitiesController,
                labelText: '1. Activities Completed (Practicals & Theory)',
                hintText: 'Enter flight and lesson activities...',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              NeuTextField(
                controller: _studentProgressController,
                labelText: '2. Student Progress & Competencies',
                hintText: 'Enter student observation notes...',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              NeuTextField(
                controller: _challengesController,
                labelText: '3. Challenges Faced (Equipment, Weather, Logistics)',
                hintText: 'Enter challenges...',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              NeuTextField(
                controller: _workCompletedController,
                labelText: '4. Work Completed & Deliverables',
                hintText: 'Enter footage/units completed...',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              NeuTextField(
                controller: _remarksController,
                labelText: '5. Overall Teacher Remarks',
                hintText: 'Instructor final remarks...',
                maxLines: 2,
              ),
              const SizedBox(height: 28),
              NeuButton(
                label: 'Submit Daily Review Report',
                isLoading: attProv.isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
