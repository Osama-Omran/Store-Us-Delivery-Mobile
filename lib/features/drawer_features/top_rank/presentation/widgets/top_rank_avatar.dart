import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';

class TopRankAvatar extends StatelessWidget {
  const TopRankAvatar({
    super.key,
    required this.entry,
    this.size = 44,
    this.isWinner = false,
  });

  final TopRankEntry entry;
  final double size;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final initials = entry.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join();

    final placeholder = Center(
      child: Text(
        initials,
        textDirection: TextDirection.rtl,
        style: Styles.textStyle16.copyWith(
          fontSize: size * 0.3,
          color: isWinner ? AppColors.rankTeal : AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(isWinner ? 2 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWinner ? AppColors.rankTealLight : AppColors.blue4,
        border: isWinner
            ? Border.all(color: AppColors.rankTeal, width: 2)
            : null,
      ),
      child: ClipOval(
        child: entry.portraitAsset == null
            ? placeholder
            : Image.asset(
                entry.portraitAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
