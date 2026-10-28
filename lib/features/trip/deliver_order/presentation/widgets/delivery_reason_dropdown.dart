import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
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
    this.cubit,
  });

  final DeliveryReasonCategory category;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool enabled;
  final DeliveryReasonsCubit? cubit;

  @override
  State<DeliveryReasonDropdown> createState() => _DeliveryReasonDropdownState();
}

class _DeliveryReasonDropdownState extends State<DeliveryReasonDropdown> {
  late final DeliveryReasonsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? getIt<DeliveryReasonsCubit>();
    _cubit.loadReasons();
  }

  @override
  void dispose() {
    if (widget.cubit == null) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is DeliveryReasonsLoading ||
            state is DeliveryReasonsInitial) {
          return _stateSurface(
            const Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is DeliveryReasonsFailure) {
          return _stateSurface(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.strings.delivery_reasons_load_failed,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.red1,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.enabled ? () => _cubit.loadReasons() : null,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.strings.delivery_reasons_retry),
                ),
              ],
            ),
          );
        }

        final options = (state as DeliveryReasonsSuccess).data.forCategory(
          widget.category,
        );
        if (options.isEmpty) {
          return _stateSurface(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.strings.delivery_reasons_empty,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.grey4,
                    height: 1.5,
                  ),
                ),
                if (widget.cubit != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton.icon(
                      onPressed: widget.enabled
                          ? () => _cubit.loadReasons(force: true)
                          : null,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(context.strings.delivery_reasons_retry),
                    ),
                  ),
              ],
            ),
          );
        }

        // DropdownButton requires a unique value. No normalization is allowed.
        final uniqueOptions = options.toSet().toList(growable: false);
        final selected = uniqueOptions.contains(widget.value)
            ? widget.value
            : null;
        return DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          style: Styles.textStyle14.copyWith(color: AppColors.black1),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: Styles.textStyle14,
            filled: true,
            fillColor: AppColors.white0,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.grey3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.grey3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
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

  Widget _stateSurface(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white0,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.grey3),
    ),
    child: child,
  );
}
