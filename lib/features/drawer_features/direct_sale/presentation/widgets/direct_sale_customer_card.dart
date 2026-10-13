import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/direct_sale_models.dart';
import 'direct_sale_card.dart';

class DirectSaleCustomerCard extends StatelessWidget {
  const DirectSaleCustomerCard({
    super.key,
    required this.customer,
    this.onChange,
  });

  final DirectSaleCustomer customer;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final saved = customer.isSaved;
    final color = saved ? AppColors.primary : AppColors.orange0;
    return DirectSaleCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: saved ? AppColors.blue4 : AppColors.orange1,
            child: Icon(Icons.person_outline_rounded, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  context.strings.direct_sale_customer,
                  style: Styles.textStyle12.copyWith(color: AppColors.grey4),
                ),
                if (MediaQuery.textScalerOf(context).scale(12) > 15)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        saved
                            ? customer.name
                            : context.strings.direct_sale_cash_customer,
                        style: Styles.textStyle18.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                      DirectSaleCustomerBadge(saved: saved),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          saved
                              ? customer.name
                              : context.strings.direct_sale_cash_customer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Styles.textStyle18.copyWith(
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DirectSaleCustomerBadge(saved: saved),
                    ],
                  ),
                if (customer.phone?.trim().isNotEmpty == true)
                  Text(
                    customer.phone!,
                    textDirection: TextDirection.ltr,
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.grey4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          if (onChange != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.black1,
                backgroundColor: AppColors.grey5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                context.strings.direct_sale_change_customer,
                style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DirectSaleCustomerBadge extends StatelessWidget {
  const DirectSaleCustomerBadge({super.key, required this.saved});
  final bool saved;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: saved ? AppColors.blue4 : AppColors.orange1,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      saved
          ? context.strings.direct_sale_saved
          : context.strings.direct_sale_quick,
      style: Styles.textStyle12.copyWith(
        color: saved ? AppColors.primary : AppColors.orange0,
      ),
    ),
  );
}
