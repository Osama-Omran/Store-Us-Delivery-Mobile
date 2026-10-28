import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

/// Always displays raw API values; selection is never translated or normalized.
class DeliveryReasonDropdown extends StatefulWidget {
  const DeliveryReasonDropdown({
    super.key,
    required this.category,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  final DeliveryReasonCategory category;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool enabled;

  @override
  State<DeliveryReasonDropdown> createState() => _DeliveryReasonDropdownState();
}

class _DeliveryReasonDropdownState extends State<DeliveryReasonDropdown> {
  late final DeliveryReasonsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<DeliveryReasonsCubit>()..loadReasons();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is DeliveryReasonsLoading || state is DeliveryReasonsInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DeliveryReasonsFailure) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.strings.delivery_reasons_load_failed,
                style: TextStyle(color: AppColors.red1),
              ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _cubit.loadReasons,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.strings.delivery_reasons_retry),
              ),
            ],
          );
        }

        final options = (state as DeliveryReasonsSuccess)
            .data.forCategory(widget.category);
        if (options.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(context.strings.delivery_reasons_empty),
          );
        }

        // DropdownButton requires a unique value. No normalization is allowed.
        final uniqueOptions = options.toSet().toList(growable: false);
        final selected = uniqueOptions.contains(widget.value) ? widget.value : null;
        return DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          hint: Text(context.strings.delivery_reasons_select),
          items: [
            for (final reason in uniqueOptions)
              DropdownMenuItem<String>(
                value: reason,
                child: Text(reason, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: widget.enabled ? widget.onChanged : null,
        );
      },
    );
  }
}
