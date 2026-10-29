import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/cubit/trip_customers_cubit.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/cubit/trip_customers_state.dart';
import 'package:storeus_delivery/features/drawer_features/customers/presentation/screens/trip_customer_orders_screen.dart';

import 'trip_customer_card.dart';
import 'trip_customers_header.dart';
import 'trip_customers_message.dart';
import 'trip_customers_shimmer.dart';

class TripCustomersBody extends StatefulWidget {
  const TripCustomersBody({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<TripCustomersBody> createState() => _TripCustomersBodyState();
}

class _TripCustomersBodyState extends State<TripCustomersBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: ColoredBox(
      color: AppColors.grey0,
      child: Column(
        children: [
          TripCustomersHeader(onBack: widget.onBack),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => TripCustomersCubit.get(context).load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 17, 20, 115),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.strings.trip_customers_search_hint,
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
                        borderSide: const BorderSide(color: AppColors.grey3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.grey3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  BlocBuilder<TripCustomersCubit, TripCustomersState>(
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
                      final loading =
                          state.status == TripCustomersStatus.loading;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (loading)
                            const TripCustomersShimmer()
                          else if (state.status == TripCustomersStatus.failure)
                            TripCustomersMessage(
                              message:
                                  (state.errorMessage?.trim().isNotEmpty ??
                                      false)
                                  ? state.errorMessage!
                                  : context.strings.trip_customers_load_failed,
                              icon: Icons.wifi_off_outlined,
                              buttonText: context.strings.trip_customers_retry,
                              onRetry: () =>
                                  context.read<TripCustomersCubit>().load(),
                            )
                          else if (state.status == TripCustomersStatus.initial)
                            TripCustomersMessage(
                              message: context.strings.trip_customers_loading,
                              icon: Icons.groups_outlined,
                            )
                          else if (items.isEmpty)
                            TripCustomersMessage(
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

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
