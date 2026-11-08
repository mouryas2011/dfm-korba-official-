import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  List<dynamic> _rooms = [];
  List<dynamic> _currentRoomMessages = [];
  String? _activeRoomId;

  bool get isLoading => _isLoading;
  List<dynamic> get rooms => _rooms;
  List<dynamic> get currentRoomMessages => _currentRoomMessages;
  String? get activeRoomId => _activeRoomId;

  /// Fetch Chat Channels
  Future<void> fetchChatRooms(String? token) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetChatRooms,
      sessionToken: token,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _rooms = response.data as List<dynamic>;
    } else {
      _rooms = [
        {
          'room_id': 'CR_TM_VEERVAAN',
          'title': 'Team Veervaan Squad Chat',
          'room_type': 'TEAM_GROUP',
        },
        {
          'room_id': 'CR_BATCH_01',
          'title': 'DFM Batch 01 Main Group',
          'room_type': 'BATCH_GROUP',
        }
      ];
    }
    notifyListeners();
  }

  /// Poll messages for an active room
  Future<void> pollMessages(String? token, String roomId) async {
    _activeRoomId = roomId;

    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionGetMessages,
      sessionToken: token,
      payload: {'room_id': roomId},
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      _currentRoomMessages = data['messages'] as List<dynamic>? ?? [];
    } else if (_currentRoomMessages.isEmpty) {
      _currentRoomMessages = [
        {
          'message_id': 'MSG_001',
          'sender_name': 'Aman Verma',
          'content': 'Hey team, flight footage uploaded for review!',
          'created_at': '10:30 AM',
          'sender_user_id': 'USR_STU_01'
        },
        {
          'message_id': 'MSG_002',
          'sender_name': 'Rahul Yadav',
          'content': 'Checked the 4K gimbal roll, looks super smooth!',
          'created_at': '10:35 AM',
          'sender_user_id': 'USR_STU_02'
        }
      ];
    }
    notifyListeners();
  }

  /// Send Message
  Future<bool> sendMessage({
    required String? token,
    required String roomId,
    required String content,
  }) async {
    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionSendMessage,
      sessionToken: token,
      payload: {
        'room_id': roomId,
        'content': content,
        'message_type': 'TEXT',
      },
    );

    if (response.success && response.data != null) {
      final msg = (response.data as Map<String, dynamic>)['message'];
      _currentRoomMessages.add(msg);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Report message for moderation
  Future<bool> reportMessage({
    required String? token,
    required String messageId,
    required String reason,
  }) async {
    final response = await _apiClient.postAction(
      action: ApiEndpoints.actionReportMessage,
      sessionToken: token,
      payload: {
        'message_id': messageId,
        'reason': reason,
      },
    );
    return response.success;
  }
}

