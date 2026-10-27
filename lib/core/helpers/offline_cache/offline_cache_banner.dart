import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

/// Mount near the top of LayoutScreen to clearly identify stale data.
class OfflineCacheBanner extends StatelessWidget {
  const OfflineCacheBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OfflineCacheViewState>(
      valueListenable: OfflineCacheStatus.instance,
      builder: (context, state, _) {
        if (!state.noNetwork && !state.showingSavedData) {
          return const SizedBox.shrink();
        }
        final savedAt = state.savedAt;
        final savedLabel = savedAt == null
            ? null
            : '${savedAt.year}/${savedAt.month.toString().padLeft(2, '0')}/'
                  '${savedAt.day.toString().padLeft(2, '0')} '
                  '${savedAt.hour.toString().padLeft(2, '0')}:'
                  '${savedAt.minute.toString().padLeft(2, '0')}';
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.offlineBannerBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.offlineBannerBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.offlineBannerIcon,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.showingSavedData
                      ? (savedLabel == null
                            ? context.strings.offline_saved_data
                            : context.strings.offline_saved_data_since(
                                savedLabel,
                              ))
                      : context.strings.offline_data_unavailable,
                  textDirection: TextDirection.rtl,
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.offlineBannerText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
