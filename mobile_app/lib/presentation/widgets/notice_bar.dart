import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NoticeBar extends StatelessWidget {
  final String title;
  final String category; // 'GENERAL_NOTICE' or 'COMMON_TASK_NOTICE'
  final VoidCallback? onTap;

  const NoticeBar({
    Key? key,
    required this.title,
    this.category = 'GENERAL_NOTICE',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTaskNotice = category == 'COMMON_TASK_NOTICE';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isTaskNotice ? AppColors.accentCyan : AppColors.primaryOrange,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTaskNotice ? AppColors.accentCyan : AppColors.primaryOrange)
                  .withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isTaskNotice ? AppColors.accentCyan : AppColors.primaryOrange)
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTaskNotice ? Icons.assignment_late_rounded : Icons.campaign_rounded,
                size: 18,
                color: isTaskNotice ? AppColors.accentCyan : AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        isTaskNotice ? 'Task Alert' : 'Important Notice',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isTaskNotice
                              ? AppColors.accentCyan
                              : AppColors.primaryOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isTaskNotice
                              ? AppColors.accentCyan
                              : AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
