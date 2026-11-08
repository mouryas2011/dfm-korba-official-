import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/animations/star_bounce_animator.dart';
import 'neumorphic_card.dart';

class TopTeamCard extends StatelessWidget {
  final String teamName;
  final num totalMarks;
  final double performancePct;
  final int rank;
  final List<dynamic> members;
  final VoidCallback? onTap;

  const TopTeamCard({
    Key? key,
    required this.teamName,
    required this.totalMarks,
    required this.performancePct,
    this.rank = 1,
    this.members = const [],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      surfaceColor: AppColors.surfaceDarkElevated,
      border: Border.all(color: AppColors.accentGold.withOpacity(0.4), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldTrophyGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Team of the Week',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Team $teamName',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StarBounceAnimator(score: performancePct, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          // Stats Row
          Row(
            children: [
              _buildMiniStat('Score', '$totalMarks / 500', AppColors.primaryOrange),
              const SizedBox(width: 12),
              _buildMiniStat('Rank', '#$rank', AppColors.accentCyan),
              const SizedBox(width: 12),
              _buildMiniStat('Members', '${members.length}', AppColors.accentTeal),
            ],
          ),
          const SizedBox(height: 14),
          // Team Member Avatar Stack
          Row(
            children: [
              SizedBox(
                height: 36,
                width: 140,
                child: Stack(
                  children: List.generate(
                    members.length > 5 ? 5 : members.length,
                    (index) => Positioned(
                      left: index * 22.0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceDark, width: 2),
                          color: AppColors.surfaceDarkInset,
                        ),
                        child: Center(
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: const [
                  Text(
                    'Squad Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.accentCyan,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceDarkInset,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
