import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/offline_cache/offline_cache_connectivity.dart';

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
            color: const Color(0xFFFFF0D8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1C482)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFB86600),
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.showingSavedData
                      ? 'غير متصل — تعرض بيانات محفوظة${savedLabel == null ? '' : ' من $savedLabel'}'
                      : 'لا يوجد اتصال بالإنترنت — قد لا تتوفر بعض البيانات',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Color(0xFF8B5100),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
