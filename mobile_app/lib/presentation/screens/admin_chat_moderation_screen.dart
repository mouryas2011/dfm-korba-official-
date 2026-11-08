import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/neumorphic_card.dart';

class AdminChatModerationScreen extends StatefulWidget {
  const AdminChatModerationScreen({Key? key}) : super(key: key);

  @override
  State<AdminChatModerationScreen> createState() => _AdminChatModerationScreenState();
}

class _AdminChatModerationScreenState extends State<AdminChatModerationScreen> {
  final List<Map<String, dynamic>> _flaggedMessages = [
    {
      'id': 'MSG_FLG_001',
      'channel': 'SQUAD: TM_VEERVAAN',
      'sender_name': 'Rohan Kumar',
      'sender_id': 'STU_DFM_019',
      'message': 'Stop taking credit for my drone flight shots or I will delete the project file!',
      'flag_reason': 'HARASSMENT / THREAT',
      'flagged_by': 'STU_DFM_001 (Aman Verma)',
      'timestamp': 'Today, 11:20 AM',
      'status': 'PENDING',
    },
    {
      'id': 'MSG_FLG_002',
      'channel': 'BATCH: BTC_DFM_01',
      'sender_name': 'Vikram Patel',
      'sender_id': 'STU_DFM_044',
      'message': 'Check out this external link for paid certificates: https://fake-cert.example.com',
      'flag_reason': 'POLICY VIOLATION (PAID CERTIFICATE SPAM)',
      'flagged_by': 'AUTO_MODERATOR',
      'timestamp': 'Yesterday, 04:15 PM',
      'status': 'PENDING',
    },
  ];

  void _deleteMessage(int index) {
    setState(() {
      _flaggedMessages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message deleted from chat records and audit log saved.'),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }

  void _dismissFlag(int index) {
    setState(() {
      _flaggedMessages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flag dismissed. Message kept intact.'),
        backgroundColor: AppColors.accentTeal,
      ),
    );
  }

  void _muteUser(String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName has been muted for 24 hours across all chat channels.'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Chat Moderation & Safety'),
      ),
      body: SafeArea(
        child: _flaggedMessages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified_user_rounded, size: 56, color: AppColors.accentTeal),
                    SizedBox(height: 12),
                    Text(
                      'All Clear',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Zero active chat safety flags in the queue.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _flaggedMessages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _flaggedMessages[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: NeuCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accentRed.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.accentRed.withOpacity(0.4)),
                                ),
                                child: Text(
                                  msg['flag_reason'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentRed,
                                  ),
                                ),
                              ),
                              Text(
                                msg['timestamp'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Channel: ${msg['channel']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sender: ${msg['sender_name']} (${msg['sender_id']})',
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDarkInset,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              '"${msg['message']}"',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reported by: ${msg['flagged_by']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.accentRed),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.delete_forever_rounded, color: AppColors.accentRed, size: 16),
                                  label: const Text('Delete', style: TextStyle(color: AppColors.accentRed, fontSize: 12)),
                                  onPressed: () => _deleteMessage(idx),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primaryOrange),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.volume_off_rounded, color: AppColors.primaryOrange, size: 16),
                                  label: const Text('Mute 24h', style: TextStyle(color: AppColors.primaryOrange, fontSize: 12)),
                                  onPressed: () => _muteUser(msg['sender_name'] as String),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentTeal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                  label: const Text('Dismiss', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  onPressed: () => _dismissFlag(idx),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
