import 'package:flutter/material.dart';

import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_entry.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

class TopRankAvatar extends StatelessWidget {
  const TopRankAvatar({
    super.key,
    required this.entry,
    required this.role,
    this.size = 48,
    this.isWinner = false,
  });

  final TopRankEntry entry;
  final TopRankRole role;
  final double size;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final isVehicle = role == TopRankRole.vehicles;
    final isWarehouse = role == TopRankRole.warehouses;

    final initials = entry.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join();

    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isWinner ? AppColors.blue4 : AppColors.grey5,
        shape: BoxShape.circle,
        border: Border.all(
          color: isWinner ? AppColors.primary : AppColors.grey3,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: isVehicle || isWarehouse
          ? Icon(
              isVehicle
                  ? Icons.directions_car_outlined
                  : Icons.warehouse_outlined,
              size: size * .44,
              color: AppColors.primary,
            )
          : Text(
              initials.isEmpty ? '?' : initials,
              style: Styles.base.copyWith(
                color: AppColors.primary,
                fontSize: size * .27,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
