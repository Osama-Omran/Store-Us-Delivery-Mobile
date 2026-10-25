import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/routing/routes_names.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../cubit/direct_sale_cubit.dart';

void goBackFromDirectSale(BuildContext context) {
  if (DirectSaleCubit.get(context).goBack()) return;
  if (context.canPop()) {
    context.pop();
  } else {
    context.goNamed(RoutesNames.layout);
  }
}

class DirectSalePage extends StatelessWidget {
  const DirectSalePage({
    super.key,
    required this.child,
    required this.footer,
    this.newCustomer = false,
  });

  final Widget child;
  final Widget footer;
  final bool newCustomer;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.grey0,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.grey3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 72,
                    vertical: 16,
                  ),
                  child: Column(
                    spacing: 2,
                    children: [
                      Text(
                        newCustomer
                            ? context.strings.direct_sale_new_customer
                            : context.strings.direct_sale,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle20.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                      Text(
                        newCustomer
                            ? context.strings.direct_sale_new_customer_subtitle
                            : context.strings.direct_sale_subtitle,
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.grey4,
                        ),
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  child: IconButton(
                    key: const ValueKey('direct-sale-back'),
                    tooltip: context.strings.back,
                    onPressed: () => goBackFromDirectSale(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.white0,
                      side: BorderSide(color: AppColors.grey3),
                      fixedSize: const Size(44, 44),
                    ),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      textDirection: TextDirection.ltr,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
    bottomNavigationBar: footer,
  );
}

class DirectSaleFooter extends StatelessWidget {
  const DirectSaleFooter({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon = false,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool trailingIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.white0,
      border: Border(top: BorderSide(color: AppColors.grey3)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white0,
                disabledBackgroundColor: AppColors.blue0,
                disabledForegroundColor: AppColors.white0,
                shadowColor: AppColors.primary.withValues(alpha: .25),
                elevation: 4,
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: Styles.textStyle18.copyWith(fontFamily: 'cairo'),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !trailingIcon) ...[
                    Icon(icon, size: 22, textDirection: TextDirection.ltr),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                  if (icon != null && trailingIcon) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 22, textDirection: TextDirection.ltr),
                  ],
                ],
              ),
            ),
            if (secondaryLabel != null)
              TextButton(
                onPressed: onSecondaryPressed,
                child: Text(
                  secondaryLabel!,
                  style: Styles.textStyle16.copyWith(color: AppColors.grey4),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
