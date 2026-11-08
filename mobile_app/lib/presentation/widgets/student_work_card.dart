import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'neumorphic_card.dart';

class StudentWorkCard extends StatelessWidget {
  final String title;
  final String studentOrTeamName;
  final String fileName;
  final String mimeType;
  final num? marks;
  final String? feedback;
  final VoidCallback? onTap;

  const StudentWorkCard({
    Key? key,
    required this.title,
    required this.studentOrTeamName,
    required this.fileName,
    required this.mimeType,
    this.marks,
    this.feedback,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVideo = mimeType.contains('video') || fileName.endsWith('.mp4');

    return NeuCard(
      onTap: onTap,
      margin: const EdgeInsets.only(right: 14),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview thumbnail container
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkInset,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Icon(
                      isVideo ? Icons.videocam_rounded : Icons.photo_camera_back_rounded,
                      size: 40,
                      color: AppColors.accentCyan.withOpacity(0.5),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVideo ? 'VIDEO' : 'IMAGE',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ),
                  ),
                  if (marks != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$marks/100',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    studentOrTeamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.accentTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (feedback != null && feedback!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '"$feedback"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
