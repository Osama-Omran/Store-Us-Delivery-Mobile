
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class DeliveryCollectionSelector extends StatelessWidget {
  const DeliveryCollectionSelector({
    super.key,
    required this.collectPayment,
    required this.enabled,
    required this.onChanged,
  });

  final bool collectPayment;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.strings.delivery_collection_question,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
          ),
        ),
        const SizedBox(height: 12),
        _CollectionOption(
          title: context.strings.delivery_with_collection,
          subtitle: context.strings.delivery_with_collection_hint,
          icon: Icons.payments_outlined,
          selected: collectPayment,
          enabled: enabled,
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: 10),
        _CollectionOption(
          title: context.strings.delivery_without_collection,
          subtitle: context.strings.delivery_without_collection_hint,
          icon: Icons.local_shipping_outlined,
          selected: !collectPayment,
          enabled: enabled,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _CollectionOption extends StatelessWidget {
  const _CollectionOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .6,
      child: Material(
        color: selected ? AppColors.blue4 : AppColors.white0,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.grey3,
                width: selected ? 1.7 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey4,
                  size: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.black1,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.grey4,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
