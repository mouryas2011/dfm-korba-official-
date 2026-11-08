import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/neumorphic_button.dart';

class StudentQuizScreen extends StatefulWidget {
  const StudentQuizScreen({Key? key}) : super(key: key);

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _secondsLeft = 15 * 60; // 15 minutes
  Timer? _timer;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  bool _isSubmitted = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question_id': 'QQ_001',
      'question_text': 'According to DGCA India Drone Rules, what is the maximum permissible altitude for drone operations in the Green Zone without ATC clearance?',
      'options': [
        'A. 200 feet (60 meters)',
        'B. 400 feet (120 meters)',
        'C. 500 feet (150 meters)',
        'D. 1000 feet (300 meters)',
      ],
      'correct': 'B',
      'explanation': 'In Indian Green Zones, flights up to 400 feet AGL are permitted without prior ATC permission.'
    },
    {
      'question_id': 'QQ_002',
      'question_text': 'Which camera gimbal move creates a cinematic "Orbit Shot" around a subject?',
      'options': [
        'A. Flying straight up while tilting down',
        'B. Flying horizontally in a circle while yawing to keep subject centered',
        'C. Flying backwards through an obstacle',
        'D. Stationary hovering at 50% throttle',
      ],
      'correct': 'B',
      'explanation': 'An orbit requires coordinated roll and opposite yaw to track around a central point.'
    },
    {
      'question_id': 'QQ_003',
      'question_text': 'What shutter speed rule is standard for capturing natural cinematic motion blur at 24 fps?',
      'options': [
        'A. 1/24 second',
        'B. 1/48 or 1/50 second (180-degree rule)',
        'C. 1/500 second',
        'D. 1/1000 second',
      ],
      'correct': 'B',
      'explanation': 'The 180-degree rule dictates setting shutter speed to roughly double the frame rate.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitQuiz() {
    _timer?.cancel();
    setState(() => _isSubmitted = true);

    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correct']) {
        score += 2;
      }
    }

    final auth = context.read<AuthProvider>();
    final quizProv = context.read<QuizProvider>();

    final answersPayload = _selectedAnswers.entries.map((e) {
      return {
        'question_id': _questions[e.key]['question_id'],
        'answer': e.value,
      };
    }).toList();

    quizProv.submitQuizAttempt(
      token: auth.sessionToken,
      quizId: 'QZ_2026_01',
      answers: answersPayload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    if (_isSubmitted) {
      return _buildResultScreen();
    }

    final q = _questions[_currentQuestionIndex];
    final options = q['options'] as List<String>;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Bi-Weekly AI Quiz'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkInset,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryOrange),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: AppColors.primaryOrange, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              NeuCard(
                padding: const EdgeInsets.all(18),
                surfaceColor: AppColors.surfaceDarkElevated,
                child: Text(
                  q['question_text'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(options.length, (optIdx) {
                final letter = String.fromCharCode(65 + optIdx); // A, B, C, D
                final isSelected = _selectedAnswers[_currentQuestionIndex] == letter;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[_currentQuestionIndex] = letter;
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryOrange : AppColors.borderSubtle,
                      width: isSelected ? 1.6 : 1.0,
                    ),
                    surfaceColor: isSelected ? AppColors.surfaceDarkInset : AppColors.surfaceDark,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primaryOrange : AppColors.surfaceDarkInset,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryOrange : AppColors.borderSubtle,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            options[optIdx],
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: NeuButton(
                        label: 'Previous',
                        color: AppColors.surfaceDark,
                        onPressed: () {
                          setState(() => _currentQuestionIndex--);
                        },
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    child: NeuButton(
                      label: _currentQuestionIndex == _questions.length - 1 ? 'Submit Quiz' : 'Next Question',
                      onPressed: () {
                        if (_currentQuestionIndex == _questions.length - 1) {
                          _submitQuiz();
                        } else {
                          setState(() => _currentQuestionIndex++);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correct']) {
        score += 2;
      }
    }
    final maxScore = _questions.length * 2;
    final pct = ((score / maxScore) * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.goldTrophyGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.military_tech_rounded, size: 54, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored $score / $maxScore ($pct%)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accentCyan),
              ),
              const SizedBox(height: 10),
              const Text(
                'Marks have been recorded into your cumulative evaluation sheet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              NeuButton(
                label: 'Back to Dashboard',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
