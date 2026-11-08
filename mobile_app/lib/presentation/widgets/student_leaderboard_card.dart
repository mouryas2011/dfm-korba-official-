import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'neumorphic_card.dart';

class StudentLeaderboardCard extends StatelessWidget {
  final int rank;
  final String studentName;
  final String courseName;
  final String teamName;
  final num marks;
  final double attendancePct;

  const StudentLeaderboardCard({
    Key? key,
    required this.rank,
    required this.studentName,
    required this.courseName,
    required this.teamName,
    required this.marks,
    this.attendancePct = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color rankColor = AppColors.textSecondary;
    if (rank == 1) rankColor = AppColors.accentGold;
    if (rank == 2) rankColor = const Color(0xFFC0C0C0);
    if (rank == 3) rankColor = const Color(0xFFCD7F32);

    return NeuCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withOpacity(0.15) : AppColors.surfaceDarkInset,
              shape: BoxShape.circle,
              border: Border.all(
                color: rank <= 3 ? rankColor : AppColors.borderSubtle,
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: rank <= 3 ? rankColor : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$teamName • $courseName',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$marks pts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                ),
              ),
              Text(
                '${attendancePct.toStringAsFixed(0)}% Att.',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

