import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_cubit.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_reasons_state.dart';

/// Displays the exact reasons returned by the API as single-select chips.
/// `onChanged` receives the original reason, including any trailing spaces.
/// The existing class name is retained to keep its current callers working.
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

  Color get _selectedColor =>
      widget.category == DeliveryReasonCategory.cancellation
          ? AppColors.red1
          : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryReasonsCubit, DeliveryReasonsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is DeliveryReasonsLoading ||
            state is DeliveryReasonsInitial) {
          return const _ReasonsShimmer();
        }

        if (state is DeliveryReasonsFailure) {
          return _message(
            context.strings.delivery_reasons_load_failed,
            isError: true,
          );
        }

        final reasons = (state as DeliveryReasonsSuccess)
            .data
            .forCategory(widget.category)
            .toSet()
            .toList(growable: false);

        if (reasons.isEmpty) {
          return _message(context.strings.delivery_reasons_empty);
        }

        return Semantics(
          label: widget.label,
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 8,
              runSpacing: 9,
              alignment: WrapAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                for (final reason in reasons)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: _ReasonChip(
                      reason: reason,
                      selected: widget.value == reason,
                      selectedColor: _selectedColor,
                      enabled: widget.enabled,
                      onTap: () => widget.onChanged(reason),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _message(String message, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey5,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Styles.textStyle14.copyWith(
              color: isError ? AppColors.red1 : AppColors.grey4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
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
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.reason,
    required this.selected,
    required this.selectedColor,
    required this.enabled,
    required this.onTap,
  });

  final String reason;
  final bool selected;
  final Color selectedColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: selected ? selectedColor : AppColors.white0,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? selectedColor : AppColors.grey3,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Text(
              reason,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Styles.textStyle15.copyWith(
                color: selected ? AppColors.white0 : AppColors.black1,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonsShimmer extends StatelessWidget {
  const _ReasonsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey3,
      highlightColor: AppColors.white0,
      child: Wrap(
        spacing: 8,
        runSpacing: 9,
        children: [
          for (final width in <double>[155, 122, 180, 132, 110])
            Container(
              width: width,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.white0,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
        ],
      ),
    );
  }
}
