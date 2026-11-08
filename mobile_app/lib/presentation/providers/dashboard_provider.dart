import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;

  // Public Home Data
  Map<String, dynamic>? _publicHomeData;

  // Role Dashboard Data
  Map<String, dynamic>? _studentDashboardData;
  Map<String, dynamic>? _teamDashboardData;
  Map<String, dynamic>? _teacherDashboardData;
  Map<String, dynamic>? _adminDashboardData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get publicHomeData => _publicHomeData;
  Map<String, dynamic>? get studentDashboardData => _studentDashboardData;
  Map<String, dynamic>? get teamDashboardData => _teamDashboardData;
  Map<String, dynamic>? get teacherDashboardData => _teacherDashboardData;
  Map<String, dynamic>? get adminDashboardData => _adminDashboardData;

  /// Fetch Public Home Data (No login required)
  Future<void> fetchPublicHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetPublicHomeData,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _publicHomeData = response.data as Map<String, dynamic>;
    } else {
      // Fallback robust offline baseline matching spec
      _publicHomeData = _getFallbackPublicHomeData();
    }
    notifyListeners();
  }

  /// Fetch Student Personal Dashboard
  Future<void> fetchStudentDashboard(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetStudentDashboard,
      sessionToken: token,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _studentDashboardData = response.data as Map<String, dynamic>;
    } else {
      _studentDashboardData = _getFallbackStudentDashboardData();
    }
    notifyListeners();
  }

  /// Fetch Team Portal Dashboard
  Future<void> fetchTeamDashboard(String? token) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetTeamDashboard,
      sessionToken: token,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _teamDashboardData = response.data as Map<String, dynamic>;
    } else {
      _teamDashboardData = _getFallbackTeamDashboardData();
    }
    notifyListeners();
  }

  /// Fetch Teacher Command Dashboard
  Future<void> fetchTeacherDashboard(String? token) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetTeacherDashboard,
      sessionToken: token,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _teacherDashboardData = response.data as Map<String, dynamic>;
    } else {
      _teacherDashboardData = _getFallbackTeacherDashboardData();
    }
    notifyListeners();
  }

  /// Fetch Admin System Dashboard
  Future<void> fetchAdminDashboard(String? token) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetAdminDashboard,
      sessionToken: token,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _adminDashboardData = response.data as Map<String, dynamic>;
    } else {
      _adminDashboardData = _getFallbackAdminDashboardData();
    }
    notifyListeners();
  }

  // --- Resilient Offline Baseline Data (Matching Infographic Spec) ---

  Map<String, dynamic> _getFallbackPublicHomeData() {
    return {
      'notices': [
        {
          'category': 'GENERAL_NOTICE',
          'title': 'Next Competition: Cinematic Drone Short Film - 18 Nov 2026',
          'content': 'Open to all enrolled batches. Prepare 3-minute cinematic story treatments.'
        },
        {
          'category': 'COMMON_TASK_NOTICE',
          'title': 'Practical Flight Schedule: 07:00 AM Weather Window',
          'content': 'Low wind speed window confirmed for outdoor flight practicals.'
        }
      ],
      'top_team': {
        'team_id': 'TM_VEERVAAN',
        'team_name': 'Veervaan',
        'total_team_marks': 485,
        'performance_pct': 97.0,
        'rank': 1,
        'member_count': 6,
        'members': [
          {'full_name': 'Aman Verma', 'role_in_team': 'Pilot'},
          {'full_name': 'Rahul Yadav', 'role_in_team': 'Gimbal'},
          {'full_name': 'Priya Singh', 'role_in_team': 'Editor'},
          {'full_name': 'Sanjay Sahu', 'role_in_team': 'Spotter'},
          {'full_name': 'Neha Patel', 'role_in_team': 'Sound'},
          {'full_name': 'Karan Das', 'role_in_team': 'Story'},
        ]
      },
      'top_students': [
        {'rank': 1, 'student_name': 'Aman Verma', 'team_name': 'Veervaan', 'course_name': 'Drone Film Making', 'marks': 490, 'attendance_pct': 98.5},
        {'rank': 2, 'student_name': 'Rahul Yadav', 'team_name': 'Veervaan', 'course_name': 'Drone Film Making', 'marks': 475, 'attendance_pct': 96.0},
        {'rank': 3, 'student_name': 'Priya Singh', 'team_name': 'Veervaan', 'course_name': 'Drone Film Making', 'marks': 468, 'attendance_pct': 95.0},
        {'rank': 4, 'student_name': 'Rohan Gupta', 'team_name': 'Garuda', 'course_name': 'Drone Film Making', 'marks': 455, 'attendance_pct': 94.0},
        {'rank': 5, 'student_name': 'Ananya Das', 'team_name': 'Garuda', 'course_name': 'Drone Film Making', 'marks': 448, 'attendance_pct': 93.0},
      ],
      'gallery': [
        {
          'title': 'Sunset River Reveal',
          'student_or_team_name': 'Team Veervaan',
          'file_name': 'drone_sunset.mp4',
          'mime_type': 'video/mp4',
          'marks': 98,
          'feedback': 'Smooth exposure transition and rock-solid gimbal stabilization.'
        },
        {
          'title': 'Mountain Orbit Cine Reel',
          'student_or_team_name': 'Aman Verma',
          'file_name': 'mountain_orbit.mp4',
          'mime_type': 'video/mp4',
          'marks': 95,
          'feedback': 'Precise coordinated roll-yaw flight control.'
        }
      ],
      'courses': [
        {'course_id': 'CRS_DRONE', 'course_name': 'Drone Film Making', 'code': 'DFM', 'total_modules': 6},
        {'course_id': 'CRS_MOBILE_REP', 'course_name': 'Mobile Repairing', 'code': 'MRH', 'total_modules': 5},
        {'course_id': 'CRS_FRONT_OFFICE', 'course_name': 'Front Office Executive', 'code': 'FOE', 'total_modules': 4},
      ]
    };
  }

  Map<String, dynamic> _getFallbackStudentDashboardData() {
    return {
      'student_id': 'STU_DFM_001',
      'full_name': 'Aman Verma',
      'course_name': 'Drone Film Making',
      'batch_name': 'DFM Batch 01',
      'team_name': 'Veervaan',
      'performance_pct': 92.0,
      'cumulative_marks': 490,
      'attendance_pct': 98.5,
      'rank_in_batch': 1,
      'total_tasks_count': 12,
      'quizzes_count': 5,
      'tasks': [
        {
          'task_id': 'TSK_001',
          'title': 'Drone Cinematic Shoot',
          'description': 'Capture 3 smooth cinematic sunset movements.',
          'task_type': 'TEAM',
          'deadline': '2026-11-12T18:00:00Z',
          'max_marks': 100,
          'submission_status': 'NOT_SUBMITTED'
        }
      ],
      'active_quizzes': [
        {
          'quiz_id': 'QZ_2026_01',
          'title': 'DGCA Indian Airspace Regulations',
          'total_questions': 5,
          'duration_minutes': 15,
          'max_marks': 10
        }
      ]
    };
  }

  Map<String, dynamic> _getFallbackTeamDashboardData() {
    return {
      'team_id': 'TM_VEERVAAN',
      'team_name': 'Veervaan',
      'total_team_marks': 485,
      'performance_pct': 97.0,
      'rank': 1,
      'members': [
        {'student_id': 'STU_DFM_001', 'full_name': 'Aman Verma', 'role_in_team': 'Leader / Pilot'},
        {'student_id': 'STU_DFM_002', 'full_name': 'Rahul Yadav', 'role_in_team': 'Gimbal Operator'},
        {'student_id': 'STU_DFM_003', 'full_name': 'Priya Singh', 'role_in_team': 'Editor & Colorist'},
        {'student_id': 'STU_DFM_004', 'full_name': 'Sanjay Sahu', 'role_in_team': 'Flight Safety Spotter'},
        {'student_id': 'STU_DFM_005', 'full_name': 'Neha Patel', 'role_in_team': 'Sound Recordist'},
        {'student_id': 'STU_DFM_006', 'full_name': 'Karan Das', 'role_in_team': 'Storyboard Artist'},
      ],
      'tasks': [
        {'task_id': 'TSK_001', 'title': 'Drone Cinematic Sunset Shoot', 'deadline': '12 Nov', 'max_marks': 100}
      ]
    };
  }

  Map<String, dynamic> _getFallbackTeacherDashboardData() {
    return {
      'full_name': 'Vikram Sharma',
      'batches_count': 4,
      'students_count': 68,
      'tasks_count': 12,
      'competitions_count': 6,
      'pending_reviews_count': 3,
    };
  }

  Map<String, dynamic> _getFallbackAdminDashboardData() {
    return {
      'courses_count': 8,
      'teachers_count': 12,
      'students_count': 248,
      'teams_count': 28,
      'batches_count': 10,
    };
  }
}

