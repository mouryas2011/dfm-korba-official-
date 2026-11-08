/**
 * DFM KORBA OFFICIAL APP - CHAT SERVICE
 * Adaptive polling, scoped channels (P2P, Team, Batch), and content moderation.
 */

var ChatService = (function() {

  /**
   * Get authorized chat rooms for a user.
   */
  function getUserChatRooms(user) {
    var memberships = DatabaseService.findRows('ChatMembers', function(m) {
      return m.user_id === user.user_id && m.status !== 'REMOVED';
    });

    var roomIds = memberships.map(function(m) { return m.room_id; });
    var allRooms = DatabaseService.getAllRows('ChatRooms');

    var authorizedRooms = allRooms.filter(function(r) {
      return roomIds.indexOf(r.room_id) !== -1 && r.status === 'ACTIVE';
    });

    return authorizedRooms;
  }

  /**
   * Poll messages for a specific room with since_id.
   */
  function getMessages(user, data) {
    var roomId = data.room_id;
    var limit = Number(data.limit) || 50;
    var sinceId = data.since_id;

    // Verify membership
    var membership = DatabaseService.findRows('ChatMembers', function(m) {
      return m.room_id === roomId && m.user_id === user.user_id && m.status !== 'REMOVED';
    });
    if (membership.length === 0 && user.role !== 'ADMIN') {
      throw new Error("Access denied. You are not a member of this chat channel.");
    }

    var allMessages = DatabaseService.findRows('Messages', function(m) {
      return m.room_id === roomId && m.status !== 'REMOVED_BY_MOD';
    });

    var filtered = allMessages;
    if (sinceId) {
      var foundIndex = -1;
      for (var i = 0; i < allMessages.length; i++) {
        if (allMessages[i].message_id === sinceId) {
          foundIndex = i;
          break;
        }
      }
      if (foundIndex !== -1) {
        filtered = allMessages.slice(foundIndex + 1);
      }
    }

    // Return last N messages
    if (filtered.length > limit) {
      filtered = filtered.slice(filtered.length - limit);
    }

    return {
      room_id: roomId,
      messages: filtered
    };
  }

  /**
   * Send Message.
   */
  function sendMessage(user, data) {
    var roomId = data.room_id;
    var content = String(data.content || '').trim();
    var msgType = data.message_type || 'TEXT';

    if (!content && !data.media_drive_id) {
      throw new Error("Message cannot be empty.");
    }

    // Verify membership
    var membership = DatabaseService.findRows('ChatMembers', function(m) {
      return m.room_id === roomId && m.user_id === user.user_id && m.status !== 'REMOVED';
    });
    if (membership.length === 0 && user.role !== 'ADMIN') {
      throw new Error("You are not authorized to post in this room.");
    }

    var messageId = DatabaseService.generateId('MSG');
    var msgObj = {
      message_id: messageId,
      room_id: roomId,
      sender_user_id: user.user_id,
      sender_name: user.full_name,
      message_type: msgType,
      content: content,
      media_drive_id: data.media_drive_id || '',
      is_flagged: false,
      status: 'NORMAL'
    };

    DatabaseService.insertRow('Messages', msgObj);

    return {
      success: true,
      message: msgObj
    };
  }

  /**
   * Report inappropriate message for moderation.
   */
  function reportMessage(user, data) {
    var messageId = data.message_id;
    var reason = data.reason || 'Reported by user';

    var msg = DatabaseService.findRowByKey('Messages', 'message_id', messageId);
    if (!msg) throw new Error("Message not found.");

    DatabaseService.updateRow('Messages', 'message_id', messageId, {
      is_flagged: true,
      status: 'FLAGGED'
    });

    // Log in ActivityLogs
    DatabaseService.insertRow('ActivityLogs', {
      log_id: DatabaseService.generateId('LOG'),
      user_id: user.user_id,
      user_role: user.role,
      action: 'CHAT_MESSAGE_FLAGGED',
      details: JSON.stringify({ message_id: messageId, reason: reason }),
      ip_address: 'APP_CLIENT'
    });

    return {
      success: true,
      message: "Message reported for administrative review."
    };
  }

  return {
    getUserChatRooms: getUserChatRooms,
    getMessages: getMessages,
    sendMessage: sendMessage,
    reportMessage: reportMessage
  };
})();
