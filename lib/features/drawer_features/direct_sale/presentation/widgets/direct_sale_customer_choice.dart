import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import 'direct_sale_card.dart';
import 'direct_sale_customer_card.dart';

class DirectSaleCustomerChoice extends StatelessWidget {
  const DirectSaleCustomerChoice({
    super.key,
    required this.title,
    required this.subtitle,
    required this.saved,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final bool saved;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: DirectSaleCard(
        selected: selected,
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: saved ? AppColors.blue4 : AppColors.orange1,
              child: Icon(
                saved ? Icons.person_add_alt : Icons.person_outline,
                color: saved ? AppColors.primary : AppColors.orange0,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Styles.textStyle18.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                      DirectSaleCustomerBadge(saved: saved),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: Styles.textStyle14.copyWith(color: AppColors.grey4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_outline
                  : Icons.chevron_left_rounded,
              color: selected ? AppColors.primary : AppColors.grey4,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    ),
  );
}
