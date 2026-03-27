import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/tutor_model.dart';

/// Card tutor untuk list discovery maupun tampilan online tutors
class TutorCard extends StatelessWidget {
  final TutorModel tutor;
  final VoidCallback onTap;
  final bool compact;

  const TutorCard({
    super.key,
    required this.tutor,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: compact
            ? const EdgeInsets.only(right: 16)
            : const EdgeInsets.only(bottom: 12),
        width: compact ? 160 : double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: compact ? _buildCompact() : _buildFull(),
      ),
    );
  }

  /// Tampilan compact untuk horizontal scroll (dashboard)
  Widget _buildCompact() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _buildAvatar(40),
          const SizedBox(width: 8),
          if (tutor.isOnline)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        tutor.fullName,
        style: AppTextStyles.bodySemiBold,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      Text(
        tutor.subjects.take(2).join(', '),
        style: AppTextStyles.caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.star, color: Color(0xFFF4A200), size: 14),
          const SizedBox(width: 2),
          Text(
            tutor.rating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    ],
  );

  /// Tampilan full untuk daftar tutor
  Widget _buildFull() => Row(
    children: [
      _buildAvatar(52),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tutor.fullName, style: AppTextStyles.heading3),
                const SizedBox(width: 6),
                if (tutor.isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onlineGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Online',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.onlineGreen,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              tutor.subjects.take(3).join(' • '),
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF4A200), size: 14),
                Text(
                  ' ${tutor.rating.toStringAsFixed(1)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(' (${tutor.totalReviews})', style: AppTextStyles.caption),
                const Spacer(),
                Text(
                  'Rp${(tutor.pricePerHour / 1000).toStringAsFixed(0)}rb/jam',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildAvatar(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.blueLight],
      ),
      borderRadius: BorderRadius.circular(size / 3),
    ),
    alignment: Alignment.center,
    child: tutor.avatarUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(size / 3),
            child: Image.network(
              tutor.avatarUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          )
        : Text(
            tutor.fullName[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.4,
            ),
          ),
  );
}
