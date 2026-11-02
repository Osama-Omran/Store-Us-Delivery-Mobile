import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/helpers/utils/app_assets.dart';
import 'package:storeus_delivery/core/helpers/utils/app_update_config.dart';
import 'package:storeus_delivery/core/helpers/utils/force_update_services.dart';
import 'package:storeus_delivery/core/helpers/utils/setup_get.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

Future<void> showOptionalUpdateDialog(
  BuildContext context,
  AppUpdateResult update,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => OptionalUpdateDialog(update: update),
);

class OptionalUpdateDialog extends StatefulWidget {
  const OptionalUpdateDialog({super.key, required this.update});

  final AppUpdateResult update;

  @override
  State<OptionalUpdateDialog> createState() => _OptionalUpdateDialogState();
}

class _OptionalUpdateDialogState extends State<OptionalUpdateDialog> {
  bool _isOpeningStore = false;
  bool _storeOpenFailed = false;

  Future<void> _openStore() async {
    setState(() {
      _isOpeningStore = true;
      _storeOpenFailed = false;
    });
    final opened = await getIt<ForceUpdateServices>().openStore(
      widget.update.storeUrl,
    );
    if (!mounted) return;
    setState(() {
      _isOpeningStore = false;
      _storeOpenFailed = !opened;
    });
  }

  Future<void> _retryStore() async {
    setState(() {
      _isOpeningStore = true;
      _storeOpenFailed = false;
    });
    final update = await getIt<ForceUpdateServices>().checkForUpdate(
      refreshRemoteConfig: true,
    );
    final opened = await getIt<ForceUpdateServices>().openStore(
      update.storeUrl,
    );
    if (!mounted) return;
    setState(() {
      _isOpeningStore = false;
      _storeOpenFailed = !opened;
    });
  }

  Future<void> _later() async {
    await getIt<ForceUpdateServices>().dismissOptionalUpdate(
      widget.update.latestVersion,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: AppColors.white0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.forceUpdate,
                  height: MediaQuery.sizeOf(context).height * .28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  context.strings.optional_update_title,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle22.copyWith(
                    color: AppColors.black0,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.strings.optional_update_description,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.grey1,
                    height: 1.6,
                  ),
                ),
                if (_storeOpenFailed) ...[
                  const SizedBox(height: 12),
                  Text(
                    context.strings.update_store_unavailable,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(color: AppColors.red1),
                  ),
                  TextButton(
                    onPressed: _isOpeningStore ? null : _retryStore,
                    child: Text(context.strings.update_retry),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _isOpeningStore ? null : _openStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0d6875),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isOpeningStore
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white0,
                            ),
                          )
                        : Text(
                            context.strings.update_now,
                            style: Styles.textStyle18.copyWith(
                              color: AppColors.white0,
                            ),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: _later,
                  child: Text(
                    context.strings.update_later,
                    style: Styles.textStyle16.copyWith(color: AppColors.grey1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
