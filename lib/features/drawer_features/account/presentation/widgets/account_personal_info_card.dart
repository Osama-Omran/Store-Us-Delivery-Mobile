import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/cubit/account_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/account/presentation/widgets/account_surface_card.dart';

class AccountPersonalInfoCard extends StatelessWidget {
  const AccountPersonalInfoCard({super.key});

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.strings.account_feature_unavailable)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AccountCubit.get(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return AccountSurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.strings.account_my_data,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.black1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showUnavailable(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.blue4,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text(context.strings.account_edit_data),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: context.strings.account_name, value: user.name),
          const SizedBox(height: 14),
          _InfoRow(
            label: context.strings.phone_number,
            value: user.phone,
            isLtr: true,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: context.strings.email,
            value: user.email,
            isLtr: true,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: context.strings.account_employee_number,
            value: user.employeeId,
            isLtr: true,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _showUnavailable(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.grey3, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.strings.account_change_password,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.black1,
                  fontWeight: FontWeight.w700,
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
  const _InfoRow({required this.label, this.value, this.isLtr = false});

  final String label;
  final String? value;
  final bool isLtr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            maxLines: 2,
            style: Styles.textStyle14.copyWith(color: AppColors.grey4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value?.trim().isNotEmpty == true ? value! : '—',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            textDirection: isLtr ? TextDirection.ltr : null,
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
