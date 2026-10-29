import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

import '../../data/models/direct_sale_models.dart';
import '../cubit/direct_sale_cubit.dart';
import '../cubit/direct_sale_state.dart';
import '../utils/direct_sale_input.dart';
import 'direct_sale_notice.dart';
import 'direct_sale_stock_shimmer.dart';

/// Shows the selected customer and opens a searchable customer list.
/// Uses the same POS options data and Cubit selection logic as before.
class DirectSaleCustomerPicker extends StatelessWidget {
  const DirectSaleCustomerPicker({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectSaleCubit, DirectSaleState>(
        buildWhen: (previous, current) =>
            previous.customer != current.customer ||
            previous.existingCustomers != current.existingCustomers ||
            previous.loadingVehicleStock != current.loadingVehicleStock ||
            previous.vehicleStockLoaded != current.vehicleStockLoaded ||
            previous.vehicleStockError != current.vehicleStockError,
        builder: (context, state) {
          if (state.loadingVehicleStock) {
            return const DirectSaleStockShimmer(customer: true);
          }

          if (state.vehicleStockError != null || !state.vehicleStockLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DirectSaleNotice(
                  error: state.vehicleStockError != null,
                  message: context.strings.direct_sale_pos_customers_load_failed,
                ),
                TextButton.icon(
                  onPressed: () =>
                      DirectSaleCubit.get(context).loadVehicleStock(force: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.strings.direct_sale_vehicle_stock_retry),
                ),
              ],
            );
          }

          final customer = state.customer;
          final hasCustomers = state.existingCustomers.isNotEmpty;
          if (!hasCustomers && customer?.isSaved != true) {
            return DirectSaleNotice(
              message: context.strings.direct_sale_pos_customers_empty,
            );
          }

          return Material(
            color: AppColors.white0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: customer?.isSaved == true
                    ? AppColors.primary
                    : AppColors.grey3,
                width: customer?.isSaved == true ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: hasCustomers ? () => _showCustomerList(context) : null,
              child: Semantics(
                button: hasCustomers,
                label: context.strings.direct_sale_pos_select_customer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.blue4,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          customer?.isSaved == true
                              ? Icons.person_rounded
                              : Icons.person_search_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer?.isSaved == true
                                  ? customer!.name
                                  : context.strings.direct_sale_pos_select_customer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.black1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (customer?.phone?.isNotEmpty == true)
                              Text(
                                customer!.phone!,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.grey4,
                                ),
                              )
                            else
                              Text(
                                customer?.isSaved == true
                                    ? context.strings.direct_sale_change_customer
                                    : context.strings.direct_sale_customer,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.grey4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        customer?.isSaved == true
                            ? Icons.check_circle_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: customer?.isSaved == true
                            ? AppColors.primary
                            : AppColors.grey4,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  void _showCustomerList(BuildContext context) {
    final cubit = DirectSaleCubit.get(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _CustomerListSheet(),
      ),
    );
  }
}

/// Local search query belongs to this sheet, not the feature Cubit.
class _CustomerListSheet extends StatefulWidget {
  const _CustomerListSheet();

  @override
  State<_CustomerListSheet> createState() => _CustomerListSheetState();
}

class _CustomerListSheetState extends State<_CustomerListSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = screenHeight - keyboardHeight - 64;
    final sheetHeight = availableHeight
        .clamp(160.0, screenHeight * .78)
        .toDouble();

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.grey3,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.strings.direct_sale_choose_customer,
                      style: Styles.textStyle20.copyWith(
                        color: AppColors.black1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.strings.direct_sale_customer_search_hint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .deleteButtonTooltip,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: AppColors.grey0,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.grey3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.grey3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<DirectSaleCubit, DirectSaleState>(
                buildWhen: (previous, current) =>
                    previous.existingCustomers != current.existingCustomers ||
                    previous.customer != current.customer,
                builder: (context, state) {
                  final query = normalizeDirectSaleDigits(_query).toLowerCase();
                  final customers = state.existingCustomers.where((customer) {
                    return customer.name.toLowerCase().contains(query) ||
                        (customer.phone != null &&
                            normalizeDirectSaleDigits(customer.phone!)
                                .contains(query));
                  }).toList(growable: false);

                  if (customers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 44,
                              color: AppColors.grey4,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.strings.direct_sale_customer_no_matches,
                              textAlign: TextAlign.center,
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.grey4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _CustomerListItem(customer: customers[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  const _CustomerListItem({required this.customer});

  final DirectSaleCustomer customer;

  @override
  Widget build(BuildContext context) {
    final selected =
        DirectSaleCubit.get(context).state.customer?.id == customer.id;
    return Material(
      color: selected ? AppColors.blue4 : AppColors.white0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.grey3,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          DirectSaleCubit.get(context).selectExistingCustomer(customer.id);
          Navigator.of(context).pop();
        },
        child: Semantics(
          button: true,
          selected: selected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.blue4,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.black1,
                        ),
                      ),
                      if (customer.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          customer.phone!,
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.grey3,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
