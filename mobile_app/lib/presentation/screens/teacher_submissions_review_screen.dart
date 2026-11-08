import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/neumorphic_text_field.dart';

class TeacherSubmissionsReviewScreen extends StatefulWidget {
  final String submissionId;
  final String taskTitle;
  final String submitterName;
  final String submitterType; // 'TEAM' or 'STUDENT'

  const TeacherSubmissionsReviewScreen({
    Key? key,
    this.submissionId = 'SUB_001',
    this.taskTitle = 'Drone Cinematic Sunset Shoot',
    this.submitterName = 'Team Veervaan',
    this.submitterType = 'TEAM',
  }) : super(key: key);

  @override
  State<TeacherSubmissionsReviewScreen> createState() =>
      _TeacherSubmissionsReviewScreenState();
}

class _TeacherSubmissionsReviewScreenState
    extends State<TeacherSubmissionsReviewScreen> {
  final _marksController = TextEditingController(text: '95');
  final _feedbackController = TextEditingController(
    text: 'Rock-solid gimbal horizon and exceptional exposure ramp across the sunset reveal.',
  );
  bool _publishToGallery = true;
  String _decision = 'APPROVED';

  // Individual Student breakdown for team submissions
  final List<Map<String, dynamic>> _teamCrew = [
    {'student_id': 'STU_DFM_001', 'name': 'Aman Verma', 'role': 'Pilot in Command', 'marks': '95'},
    {'student_id': 'STU_DFM_002', 'name': 'Rahul Yadav', 'role': 'Gimbal Operator', 'marks': '92'},
    {'student_id': 'STU_DFM_003', 'name': 'Priya Singh', 'role': 'Colorist & Editor', 'marks': '96'},
  ];

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleCommit() async {
    final token = context.read<AuthProvider>().sessionToken;
    final taskProv = context.read<TaskProvider>();

    final awardedMarks = num.tryParse(_marksController.text) ?? 90;
    final breakdown = _teamCrew.map((c) {
      return {
        'student_id': c['student_id'],
        'role': c['role'],
        'marks': num.tryParse(c['marks'].toString()) ?? awardedMarks,
      };
    }).toList();

    final ok = await taskProv.reviewSubmission(
      token: token,
      submissionId: widget.submissionId,
      decision: _decision,
      awardedMarks: awardedMarks,
      feedback: _feedbackController.text.trim(),
      publishToGallery: _publishToGallery,
      individualBreakdown: widget.submitterType == 'TEAM' ? breakdown : null,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission evaluated! Dual marks recorded.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Review & Grade Submission'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryOrange),
                ),
                child: Text(
                  'SUBMISSION ID: ${widget.submissionId}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryOrange),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.taskTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                'Submitter: ${widget.submitterName} (${widget.submitterType})',
                style: const TextStyle(fontSize: 12, color: AppColors.accentCyan),
              ),
              const SizedBox(height: 18),

              // Mock Video Preview Player Tile
              NeuCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkInset,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.play_circle_fill_rounded, size: 52, color: AppColors.primaryOrange),
                                SizedBox(height: 6),
                                Text('Play 4K Flight Footage (324 MB)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('03:14 / 4K 60fps', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('drone_shoot.mp4 (Google Drive)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.accentCyan),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Decision Selector
              const Text('Evaluation Decision', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: ['APPROVED', 'REJECTED', 'RESUBMISSION_REQ'].map((d) {
                  final isSel = _decision == d;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: isSel,
                      selectedColor: d == 'APPROVED'
                          ? AppColors.accentTeal
                          : (d == 'REJECTED' ? AppColors.accentRed : AppColors.primaryOrange),
                      backgroundColor: AppColors.surfaceDarkInset,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSel ? Colors.white : AppColors.textSecondary,
                      ),
                      onSelected: (val) => setState(() => _decision = d),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Team Atomic Marks Input
              NeuTextField(
                controller: _marksController,
                labelText: widget.submitterType == 'TEAM' ? 'Team Atomic Score (Max 100)' : 'Student Marks (Max 100)',
                hintText: 'Enter marks (e.g. 95)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.military_tech_rounded,
              ),

              const SizedBox(height: 16),

              // Individual Crew Marks Breakdown (If team submission)
              if (widget.submitterType == 'TEAM') ...[
                const Text(
                  'Individual Crew Marks (Dual Marks Engine)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ..._teamCrew.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NeuCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                  Text('Role: ${c['role']}', style: const TextStyle(fontSize: 11, color: AppColors.accentCyan)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDarkInset,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${c['marks']} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryOrange)),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Constructive Critique / Feedback
              NeuTextField(
                controller: _feedbackController,
                labelText: 'Teacher Critique & Feedback',
                hintText: 'Provide technical and compositional guidance...',
                maxLines: 3,
                prefixIcon: Icons.rate_review_rounded,
              ),

              const SizedBox(height: 16),

              // Publish to Public Gallery Switch
              NeuCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Publish to Public Gallery', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Featured on public showcase home feed', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    Switch(
                      value: _publishToGallery,
                      activeColor: AppColors.primaryOrange,
                      onChanged: (v) => setState(() => _publishToGallery = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              NeuButton(
                label: 'Commit Evaluation & Dual Marks  ✓',
                isLoading: taskProv.isLoading,
                onPressed: _handleCommit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
