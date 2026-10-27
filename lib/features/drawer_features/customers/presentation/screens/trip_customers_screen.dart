import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/cubit/trip_customers_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/cubit/trip_customers_state.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/screens/trip_customer_orders_screen.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/widgets/trip_customer_card.dart';

class TripCustomersScreen extends StatelessWidget {
  const TripCustomersScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TripCustomersCubit>(
      create: (_) => getIt<TripCustomersCubit>()..load(),
      child: _TripCustomersBody(onBack: onBack),
    );
  }
}

class _TripCustomersBody extends StatefulWidget {
  const _TripCustomersBody({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_TripCustomersBody> createState() => _TripCustomersBodyState();
}

class _TripCustomersBodyState extends State<_TripCustomersBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<TripCustomersCubit, TripCustomersState>(
        builder: (context, state) {
          final items = state.customers
              .where((customer) {
                if (_query.trim().isEmpty) return true;
                final q = _normalize(_query);
                return _normalize(customer.name).contains(q) ||
                    _normalize(customer.phone).contains(q) ||
                    _normalize(customer.address).contains(q);
              })
              .toList(growable: false);
          final loading = state.status == TripCustomersStatus.loading;

          return ColoredBox(
            color: AppColors.grey0,
            child: Column(
              children: [
                // Header lives inside Layout's persistent bottom navigation.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.grey0,
                    border: Border(bottom: BorderSide(color: AppColors.grey3)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onBack,
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 19,
                              ),
                              tooltip: context.strings.trip_customers_back,
                            ),
                            Expanded(
                              child: Text(
                                context.strings.trip_customers_title,
                                textAlign: TextAlign.center,
                                style: Styles.textStyle22.copyWith(
                                  color: AppColors.black1,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: loading
                                  ? null
                                  : () => context
                                        .read<TripCustomersCubit>()
                                        .load(),
                              icon: const Icon(Icons.refresh_rounded, size: 23),
                              tooltip: context.strings.trip_customers_refresh,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.tripNumber.isEmpty
                              ? context.strings.trip_customers_count(
                                  state.customers.length,
                                )
                              : context.strings.trip_customers_summary(
                                  context.strings.trip_customers_count(
                                    state.customers.length,
                                  ),
                                  state.tripNumber,
                                ),
                          textAlign: TextAlign.center,
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.grey4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<TripCustomersCubit>().load(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 17, 20, 115),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText:
                                context.strings.trip_customers_search_hint,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.grey4,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.white0,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 17,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.grey3,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.grey3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 55),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (state.status == TripCustomersStatus.failure)
                          _MessageBlock(
                            message:
                                (state.errorMessage?.trim().isNotEmpty ?? false)
                                ? state.errorMessage!
                                : context.strings.trip_customers_load_failed,
                            icon: Icons.wifi_off_outlined,
                            buttonText: context.strings.trip_customers_retry,
                            onRetry: () =>
                                context.read<TripCustomersCubit>().load(),
                          )
                        else if (state.status == TripCustomersStatus.initial)
                          _MessageBlock(
                            message: context.strings.trip_customers_loading,
                            icon: Icons.groups_outlined,
                          )
                        else if (items.isEmpty)
                          _MessageBlock(
                            message: state.customers.isEmpty
                                ? context.strings.trip_customers_empty
                                : context.strings.trip_customers_no_results,
                            icon: Icons.person_search_rounded,
                          )
                        else
                          for (final customer in items) ...[
                            TripCustomerCard(
                              customer: customer,
                              onOrders:
                                  (state.tripId == null ||
                                      customer.ordersCount == 0)
                                  ? null
                                  : () => _openCustomerOrders(
                                      context,
                                      state.tripId!,
                                      customer,
                                    ),
                            ),
                            const SizedBox(height: 13),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openCustomerOrders(
    BuildContext context,
    int tripId,
    TripCustomer customer,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TripCustomerOrdersScreen(tripId: tripId, customer: customer),
      ),
    );
  }

  String _normalize(String text) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = text.toLowerCase().trim();
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
    }
    return result;
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.message,
    required this.icon,
    this.buttonText,
    this.onRetry,
  });
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Icon(icon, size: 45, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          context.localizedErrorMessage(message),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 13),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(buttonText ?? ''),
          ),
        ],
      ],
    ),
  );
}
