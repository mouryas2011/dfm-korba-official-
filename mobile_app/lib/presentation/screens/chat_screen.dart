import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/neumorphic_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  String _selectedRoomId = 'CR_TM_VEERVAAN';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().sessionToken;
      final chat = context.read<ChatProvider>();
      chat.fetchChatRooms(token);
      chat.pollMessages(token, _selectedRoomId);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    final token = context.read<AuthProvider>().sessionToken;
    final chat = context.read<ChatProvider>();
    await chat.sendMessage(
      token: token,
      roomId: _selectedRoomId,
      content: text,
    );
  }

  void _showReportDialog(String msgId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Message', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Flag this message for instructor/admin moderation review?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final token = context.read<AuthProvider>().sessionToken;
              await context.read<ChatProvider>().reportMessage(
                token: token,
                messageId: msgId,
                reason: 'Inappropriate content',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message reported to moderators.')),
                );
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final messages = chat.currentRoomMessages;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Squad & Student Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Channels Selector
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRoomChip('CR_TM_VEERVAAN', 'Team Veervaan Squad'),
                  const SizedBox(width: 8),
                  _buildRoomChip('CR_BATCH_01', 'DFM Batch 01 Main'),
                  const SizedBox(width: 8),
                  _buildRoomChip('CR_P2P_01', 'Aman & Rahul (P2P)'),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),

            // Message Stream
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (ctx, idx) {
                  final m = messages[idx];
                  final isMe = m['sender_user_id'] == auth.userId ||
                      m['sender_name'] == auth.userName;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primaryOrange : AppColors.surfaceDarkElevated,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isMe ? 'You' : (m['sender_name'] ?? 'Peer'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isMe ? Colors.white.withOpacity(0.9) : AppColors.accentCyan,
                                ),
                              ),
                              if (!isMe) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _showReportDialog(m['message_id'] ?? 'MSG_01'),
                                  child: const Icon(Icons.flag_outlined, size: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['content'] ?? '',
                            style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['created_at'] != null ? m['created_at'].toString().split('T').last.substring(0, 5) : 'Just now',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkInset,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message to squad...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeCtaGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomChip(String id, String label) {
    final isSelected = _selectedRoomId == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRoomId = id);
        final token = context.read<AuthProvider>().sessionToken;
        context.read<ChatProvider>().pollMessages(token, id);
      },
      child: Chip(
        backgroundColor: isSelected ? AppColors.accentCyan.withOpacity(0.2) : AppColors.surfaceDarkInset,
        side: BorderSide(color: isSelected ? AppColors.accentCyan : AppColors.borderSubtle),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
