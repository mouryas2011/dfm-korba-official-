import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class QuizProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _generatedQuestions = [];
  Map<String, dynamic>? _lastQuizResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get generatedQuestions => _generatedQuestions;
  Map<String, dynamic>? get lastQuizResult => _lastQuizResult;

  /// Teacher triggers Gemini AI question generation
  Future<bool> generateAiQuestions({
    required String? token,
    required String courseId,
    required String topic,
    int questionCount = 5,
    String difficulty = 'INTERMEDIATE',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGenerateAiQuiz,
      sessionToken: token,
      payload: {
        'course_id': courseId,
        'topic': topic,
        'question_count': questionCount,
        'difficulty': difficulty,
      },
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      _generatedQuestions = data['questions'] as List<dynamic>? ?? [];
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Teacher approves & schedules the quiz
  Future<bool> approveAndScheduleQuiz({
    required String? token,
    required String title,
    required String courseId,
    required String batchId,
    required int durationMinutes,
    required int passMarks,
    required List<dynamic> questions,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionApproveScheduleQuiz,
      sessionToken: token,
      payload: {
        'title': title,
        'course_id': courseId,
        'batch_id': batchId,
        'duration_minutes': durationMinutes,
        'pass_marks': passMarks,
        'questions': questions,
      },
    );

    _isLoading = false;
    notifyListeners();
    return response.success;
  }

  /// Student submits quiz attempt with auto-grading
  Future<bool> submitQuizAttempt({
    required String? token,
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionSubmitQuizAttempt,
      sessionToken: token,
      payload: {
        'quiz_id': quizId,
        'answers': answers,
      },
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _lastQuizResult = response.data as Map<String, dynamic>;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
}

