import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class TaskProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  List<dynamic> _tasks = [];

  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  List<dynamic> get tasks => _tasks;

  /// Fetch tasks
  Future<void> fetchTasks(String? token, {String? courseId, String? batchId}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetTasks,
      sessionToken: token,
      payload: {
        'course_id': courseId,
        'batch_id': batchId,
      },
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _tasks = response.data as List<dynamic>;
    }
    notifyListeners();
  }

  /// Upload Submission with Wavy Progress Track Animation updates
  Future<bool> uploadSubmission({
    required String? token,
    required String taskId,
    required String fileName,
    required String mimeType,
    required String base64Data,
    String? contributionNotes,
    String? submitterType,
  }) async {
    _isLoading = true;
    _uploadProgress = 0.05;
    notifyListeners();

    // Smooth wave progress animation driver
    final timer = Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (_uploadProgress < 0.85) {
        _uploadProgress += 0.08;
        notifyListeners();
      }
    });

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionUploadSubmissionFile,
      sessionToken: token,
      payload: {
        'task_id': taskId,
        'file_name': fileName,
        'mime_type': mimeType,
        'base64_data': base64Data,
        'contribution_notes': contributionNotes ?? '',
        'submitter_type': submitterType ?? 'STUDENT',
      },
    );

    timer.cancel();
    _uploadProgress = 1.0;
    _isLoading = false;
    notifyListeners();

    return response.success;
  }

  /// Teacher Review Submission & Dual Marks Recording
  Future<bool> reviewSubmission({
    required String? token,
    required String submissionId,
    required String decision,
    required num awardedMarks,
    required String feedback,
    required bool publishToGallery,
    List<Map<String, dynamic>>? individualBreakdown,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionReviewSubmission,
      sessionToken: token,
      payload: {
        'submission_id': submissionId,
        'decision': decision,
        'awarded_marks': awardedMarks,
        'feedback_comments': feedback,
        'publish_to_gallery': publishToGallery,
        'individual_breakdown': individualBreakdown,
      },
    );

    _isLoading = false;
    notifyListeners();
    return response.success;
  }
}

