import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/neumorphic_text_field.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';

class TeacherAiQuizScreen extends StatefulWidget {
  const TeacherAiQuizScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAiQuizScreen> createState() => _TeacherAiQuizScreenState();
}

class _TeacherAiQuizScreenState extends State<TeacherAiQuizScreen> {
  final _topicController = TextEditingController(
    text: 'DGCA Indian Drone Regulations & 180-Degree Cinematic Shutter Rule',
  );
  int _questionCount = 5;
  String _difficulty = 'INTERMEDIATE';

  Future<void> _handleGenerate() async {
    final token = context.read<AuthProvider>().sessionToken;
    final quizProv = context.read<QuizProvider>();

    final ok = await quizProv.generateAiQuestions(
      token: token,
      courseId: 'CRS_DRONE',
      topic: _topicController.text.trim(),
      questionCount: _questionCount,
      difficulty: _difficulty,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Questions generated! Review below.')),
      );
    }
  }

  Future<void> _handleSchedule() async {
    final token = context.read<AuthProvider>().sessionToken;
    final quizProv = context.read<QuizProvider>();

    if (quizProv.generatedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate questions first.')),
      );
      return;
    }

    final ok = await quizProv.approveAndScheduleQuiz(
      token: token,
      title: 'Bi-Weekly Evaluation Quiz: ${_topicController.text.split('&')[0].trim()}',
      courseId: 'CRS_DRONE',
      batchId: 'BTC_DFM_01',
      durationMinutes: 15,
      passMarks: 6,
      questions: quizProv.generatedQuestions,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz approved and scheduled for enrolled students!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProv = context.watch<QuizProvider>();
    final questions = quizProv.generatedQuestions;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('AI Quiz Generator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gemini AI Question Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Generates curriculum-grounded questions every 15 days. Questions require teacher review and approval before students can take the quiz.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              NeuTextField(
                controller: _topicController,
                labelText: 'Curriculum Topic / Module Scope',
                hintText: 'Enter topic for quiz...',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Question Count', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDarkInset,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: DropdownButton<int>(
                            value: _questionCount,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceDark,
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            items: [5, 10, 15].map((cnt) {
                              return DropdownMenuItem<int>(value: cnt, child: Text('$cnt Questions'));
                            }).toList(),
                            onChanged: (val) => setState(() => _questionCount = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Difficulty', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDarkInset,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: DropdownButton<String>(
                            value: _difficulty,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceDark,
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            items: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'].map((d) {
                              return DropdownMenuItem<String>(value: d, child: Text(d));
                            }).toList(),
                            onChanged: (val) => setState(() => _difficulty = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              NeuButton(
                label: 'Generate Questions with Gemini AI ✨',
                isLoading: quizProv.isLoading,
                onPressed: _handleGenerate,
              ),
              const SizedBox(height: 28),

              // Generated Questions Review Section
              if (questions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generated Questions (${questions.length})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const Text('Teacher Review Required', style: TextStyle(fontSize: 11, color: AppColors.accentGold)),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(questions.length, (idx) {
                  final q = questions[idx];
                  return NeuCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${idx + 1}. ${q['question_text']}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text('Correct: ${q['correct_answer']}', style: const TextStyle(fontSize: 12, color: AppColors.accentTeal, fontWeight: FontWeight.w700)),
                        if (q['explanation'] != null)
                          Text('Why: ${q['explanation']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                NeuButton(
                  label: 'Approve & Schedule Quiz for Batch  ✓',
                  color: AppColors.accentTeal,
                  onPressed: _handleSchedule,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

