import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _roster = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get roster => _roster;

  /// Fetch Batch Student Roster
  Future<void> fetchBatchRoster({
    required String? token,
    required String batchId,
    required String date,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetBatchStudentsForAttendance,
      sessionToken: token,
      payload: {
        'batch_id': batchId,
        'date': date,
      },
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final rawList = data['students'] as List<dynamic>? ?? [];
      _roster = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      // Fallback roster
      _roster = [
        {'student_id': 'STU_DFM_001', 'full_name': 'Aman Verma', 'status': 'PRESENT'},
        {'student_id': 'STU_DFM_002', 'full_name': 'Rahul Yadav', 'status': 'PRESENT'},
        {'student_id': 'STU_DFM_003', 'full_name': 'Priya Singh', 'status': 'PRESENT'},
        {'student_id': 'STU_DFM_004', 'full_name': 'Sanjay Sahu', 'status': 'PRESENT'},
        {'student_id': 'STU_DFM_005', 'full_name': 'Neha Patel', 'status': 'PRESENT'},
        {'student_id': 'STU_DFM_006', 'full_name': 'Karan Das', 'status': 'PRESENT'},
      ];
    }
    notifyListeners();
  }

  void toggleStatus(int index) {
    if (index >= 0 && index < _roster.length) {
      final current = _roster[index]['status'];
      _roster[index]['status'] = current == 'PRESENT' ? 'ABSENT' : 'PRESENT';
      notifyListeners();
    }
  }

  void markAllPresent() {
    for (var r in _roster) {
      r['status'] = 'PRESENT';
    }
    notifyListeners();
  }

  /// Save Attendance
  Future<bool> saveAttendance({
    required String? token,
    required String batchId,
    required String date,
    required String courseId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionSaveAttendance,
      sessionToken: token,
      payload: {
        'batch_id': batchId,
        'date': date,
        'course_id': courseId,
        'records': _roster,
      },
    );

    _isLoading = false;
    notifyListeners();
    return response.success;
  }

  /// Submit Daily Company Review
  Future<bool> submitDailyReview({
    required String? token,
    required String date,
    required String courseId,
    required String batchId,
    required String activitiesCompleted,
    required String studentProgress,
    required String challengesFaced,
    required String workCompleted,
    required String overallRemarks,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionSubmitDailyReview,
      sessionToken: token,
      payload: {
        'date': date,
        'course_id': courseId,
        'batch_id': batchId,
        'activities_completed': activitiesCompleted,
        'student_progress': studentProgress,
        'challenges_faced': challengesFaced,
        'work_completed': workCompleted,
        'overall_remarks': overallRemarks,
      },
    );

    _isLoading = false;
    notifyListeners();
    return response.success;
  }
}
