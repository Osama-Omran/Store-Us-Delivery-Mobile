
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/account/data/models/me_response.dart';

class AccountPersonalInfoCard extends StatelessWidget {
  const AccountPersonalInfoCard({
    super.key,
    required this.user,
  });

  final AccountUser user;

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.strings.account_feature_unavailable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        spacing: 18,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.account_my_data,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.black1,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showUnavailable(context),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue4,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    context.strings.account_edit_data,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          _InfoRow(
            label: context.strings.account_name,
            value: user.name,
          ),
          _InfoRow(
            label: context.strings.phone_number,
            value: user.phone,
            isLtr: true,
          ),
          _InfoRow(
            label: context.strings.email,
            value: user.email,
            isLtr: true,
          ),
          _InfoRow(
            label: context.strings.account_employee_number,
            value: user.employeeId,
            isLtr: true,
          ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => _showUnavailable(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.grey3,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                context.strings.account_change_password,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.black1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLtr = false,
  });

  final String label;
  final String? value;
  final bool isLtr;

  @override
  Widget build(BuildContext context) {
    final displayValue =
    value?.trim().isNotEmpty == true ? value! : '—';

    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            displayValue,
            textAlign: TextAlign.left,
            textDirection:
            isLtr ? TextDirection.ltr : TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle14.copyWith(
              color: AppColors.black1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
