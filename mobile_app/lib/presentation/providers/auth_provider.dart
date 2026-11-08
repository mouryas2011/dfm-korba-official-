import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionToken;
  String _userRole = AppConstants.roleStudent;
  String? _userId;
  String? _userName;
  bool _isTempPassword = false;
  Map<String, dynamic>? _roleContext;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get sessionToken => _sessionToken;
  String get userRole => _userRole;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isTempPassword => _isTempPassword;
  Map<String, dynamic>? get roleContext => _roleContext;
  bool get isAuthenticated => _sessionToken != null;

  AuthProvider() {
    _restoreSession();
  }

  void _restoreSession() {
    _sessionToken = StorageService.getSessionToken();
    _userRole = StorageService.getUserRole() ?? AppConstants.roleStudent;
    _userId = StorageService.getUserId();
    final data = StorageService.getUserData();
    if (data != null) {
      _userName = data['full_name'];
      _roleContext = data['role_context'];
      _isTempPassword = data['is_temp_password'] == true;
    }
    notifyListeners();
  }

  /// Authenticate user (Admin, Teacher, Student, Team)
  Future<bool> login({
    required String identifier,
    required String password,
    required String loginType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionLogin,
      payload: {
        'identifier': identifier,
        'password': password,
        'login_type': loginType,
      },
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      _sessionToken = data['session_token'];
      _userRole = data['role'] ?? loginType;
      _userId = data['user_id'];
      _userName = data['full_name'];
      _isTempPassword = data['is_temp_password'] == true;
      _roleContext = data['role_context'];

      await StorageService.saveSession(
        token: _sessionToken!,
        role: _userRole,
        userId: _userId!,
        userData: data,
      );

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Change Temporary or Active Password
  Future<bool> changePassword({
    String? oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionChangePassword,
      sessionToken: _sessionToken,
      payload: {
        'old_password': oldPassword ?? '',
        'new_password': newPassword,
      },
    );

    _isLoading = false;

    if (response.success) {
      _isTempPassword = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Request OTP Reset
  Future<bool> requestOtpReset({
    required String mobileNumber,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionRequestOtpReset,
      payload: {
        'mobile_number': mobileNumber,
        'email': email,
      },
    );

    _isLoading = false;
    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP and commit new password
  Future<bool> verifyOtpAndReset({
    required String mobileNumber,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionVerifyOtpAndReset,
      payload: {
        'mobile_number': mobileNumber,
        'otp': otp,
        'new_password': newPassword,
      },
    );

    _isLoading = false;
    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearSession();
    _sessionToken = null;
    _userId = null;
    _userName = null;
    _roleContext = null;
    _isTempPassword = false;
    notifyListeners();
  }
}
