import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_models.dart';

extension TreasuryTabLabels on TreasuryTab {
  String label(BuildContext context) => switch (this) {
    TreasuryTab.wallet => context.strings.treasury_wallet,
    TreasuryTab.vehicleGoods => context.strings.treasury_vehicle_goods,
  };
}

class TreasuryTabs extends StatelessWidget {
  const TreasuryTabs({super.key, required this.value, required this.onChanged});

  final TreasuryTab value;
  final ValueChanged<TreasuryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          for (final tab in TreasuryTab.values)
            Expanded(
              child: Semantics(
                selected: tab == value,
                button: true,
                child: Material(
                  color: tab == value ? AppColors.primary : AppColors.white0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: tab == value ? AppColors.primary : AppColors.grey3,
                    ),
                  ),
                  child: InkWell(
                    key: ValueKey('treasury-tab-${tab.name}'),
                    onTap: () => onChanged(tab),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 60),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.label(context),
                        textAlign: TextAlign.center,
                        style: Styles.textStyle18.copyWith(
                          color: tab == value
                              ? AppColors.white0
                              : AppColors.grey4,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

